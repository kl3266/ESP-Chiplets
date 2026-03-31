#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_ROOT="$SCRIPT_DIR/logs"
VIVADO_BATCH_OPT=(-mode batch -quiet -notrace)

declare -A TOP_BY_BOARD=(
  [0]="top"
  [1]="top_satellite"
  [2]="top_satellite"
  [3]="top_satellite"
)

declare -A BIT_DIR_BY_BOARD=(
  [0]="mb_1_FA1"
  [1]="mb_1_FB1"
  [2]="mb_1_FA2"
  [3]="mb_1_FB2"
)

declare -A VIVADO_DIR_BY_BOARD=(
  [0]="vivado_0"
  [1]="vivado_1"
  [2]="vivado_2"
  [3]="vivado_3"
)

declare -A LOG_DIR_BY_BOARD=(
  [0]="logs/vivado_0"
  [1]="logs/vivado_1"
  [2]="logs/vivado_2"
  [3]="logs/vivado_3"
)

usage() {
  echo "Usage: $0 [0|1|2|3 ...]" >&2
}

validate_board() {
  local board="$1"
  [[ -n "${TOP_BY_BOARD[$board]:-}" ]]
}

cancel_jobs() {
  jobs -pr | xargs -r kill
  wait || true
}

on_interrupt() {
  echo "Interrupt received. Terminating all running builds..." >&2
  cancel_jobs
  exit 130
}

prepare_board() {
  local board="$1"
  local vivado_dir="${VIVADO_DIR_BY_BOARD[$board]}"
  local log_dir="${LOG_DIR_BY_BOARD[$board]}"
  local setup_log="$LOG_ROOT/synth_parallel_board${board}_setup.log"

  echo "[board${board}] preparing ${vivado_dir}"

  rm -rf "$SCRIPT_DIR/vivado" "$SCRIPT_DIR/logs/vivado"
  rm -rf "$SCRIPT_DIR/$vivado_dir" "$SCRIPT_DIR/$log_dir"

  if (cd "$SCRIPT_DIR" && make --no-print-directory BOARD_NUM="$board" INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-distclean vivado-setup) >"$setup_log" 2>&1; then
    mv "$SCRIPT_DIR/vivado" "$SCRIPT_DIR/$vivado_dir"
    if [[ -d "$SCRIPT_DIR/logs/vivado" ]]; then
      mkdir -p "$SCRIPT_DIR/logs"
      mv "$SCRIPT_DIR/logs/vivado" "$SCRIPT_DIR/$log_dir"
    else
      mkdir -p "$SCRIPT_DIR/$log_dir"
    fi
  else
    echo "[board${board}] setup failed; see $setup_log" >&2
    return 1
  fi
}

publish_bitstream() {
  local board="$1"
  local bit_dir="${BIT_DIR_BY_BOARD[$board]}"
  local vivado_dir="${VIVADO_DIR_BY_BOARD[$board]}"
  local top_name="${TOP_BY_BOARD[$board]}"
  local bit_path="$SCRIPT_DIR/$vivado_dir/esp-profpga-xcvu19p.runs/impl_1/${top_name}.bit"

  if [[ ! -f "$bit_path" ]]; then
    echo "[board${board}] bitstream not found at $bit_path" >&2
    return 1
  fi

  mkdir -p "$SCRIPT_DIR/$bit_dir"
  cp -f "$bit_path" "$SCRIPT_DIR/$bit_dir/top_fpga.bit"
}

run_board() {
  local board="$1"
  local vivado_dir="${VIVADO_DIR_BY_BOARD[$board]}"
  local log_dir="${LOG_DIR_BY_BOARD[$board]}"
  local run_log="$LOG_ROOT/synth_parallel_board${board}.log"

  echo "[board${board}] launching Vivado in $vivado_dir"
  if (
    cd "$SCRIPT_DIR/$vivado_dir" && \
    vivado "${VIVADO_BATCH_OPT[@]}" -source syn.tcl | tee "../$log_dir/vivado_syn.log"
  ) >"$run_log" 2>&1; then
    publish_bitstream "$board"
    echo "[board${board}] completed successfully"
  else
    echo "[board${board}] failed; see $run_log" >&2
    return 1
  fi
}

trap on_interrupt INT TERM

if ! command -v make >/dev/null 2>&1; then
  echo "make is required but was not found in PATH" >&2
  exit 1
fi

if ! command -v vivado >/dev/null 2>&1; then
  echo "vivado is required but was not found in PATH" >&2
  exit 1
fi

boards=()
if [[ $# -eq 0 ]]; then
  boards=(0 1 2 3)
else
  for board in "$@"; do
    if ! validate_board "$board"; then
      usage
      exit 1
    fi
    boards+=("$board")
  done
fi

mkdir -p "$LOG_ROOT"

for board in "${boards[@]}"; do
  prepare_board "$board"
done

for board in "${boards[@]}"; do
  run_board "$board" &
done

echo "All jobs submitted. Waiting for all jobs to be finished..."
echo "Hit control-c to terminate all jobs."

status=0
for _ in "${boards[@]}"; do
  if ! wait -n; then
    status=1
    break
  fi
done

if [[ "$status" -ne 0 ]]; then
  echo "At least one build failed. Terminating remaining jobs..." >&2
  cancel_jobs
  exit 1
fi

wait
