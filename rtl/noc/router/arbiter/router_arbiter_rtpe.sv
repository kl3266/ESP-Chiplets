module router_arbiter_rtpe (
    input  logic clk,
    input  logic rst,
    input  logic [3:0] request,
    input  logic forwarding_head,
    input  logic forwarding_tail,
    output logic [3:0] grant,
    output logic grant_valid
);

    logic grant_locked;
    logic [1:0] ptr;
    logic [3:0] nrequest;

    assign nrequest    = ~request;
    assign grant_valid = (|request) && !grant_locked;

    always_comb begin
        grant = 4'b0000;

        if (!grant_locked) begin
            unique case (ptr)
                2'd0: begin
                    grant[0] =  request[0];
                    grant[1] =  nrequest[0] &&  request[1];
                    grant[2] =  nrequest[0] &&  nrequest[1] &&  request[2];
                    grant[3] =  nrequest[0] &&  nrequest[1] &&  nrequest[2] && request[3];
                end

                2'd1: begin
                    grant[1] =  request[1];
                    grant[2] =  nrequest[1] &&  request[2];
                    grant[3] =  nrequest[1] &&  nrequest[2] &&  request[3];
                    grant[0] =  nrequest[1] &&  nrequest[2] &&  nrequest[3] && request[0];
                end

                2'd2: begin
                    grant[2] =  request[2];
                    grant[3] =  nrequest[2] &&  request[3];
                    grant[0] =  nrequest[2] &&  nrequest[3] &&  request[0];
                    grant[1] =  nrequest[2] &&  nrequest[3] &&  nrequest[0] && request[1];
                end

                2'd3: begin
                    grant[3] =  request[3];
                    grant[0] =  nrequest[3] &&  request[0];
                    grant[1] =  nrequest[3] &&  nrequest[0] &&  request[1];
                    grant[2] =  nrequest[3] &&  nrequest[0] &&  nrequest[1] && request[2];
                end

                default: begin
                    grant = 4'b0000;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            grant_locked <= 1'b0;
            ptr          <= 2'd0;
        end else begin
            if (forwarding_head) begin
                unique case (grant)
                    4'b0001: ptr <= 2'd1;
                    4'b0010: ptr <= 2'd2;
                    4'b0100: ptr <= 2'd3;
                    4'b1000: ptr <= 2'd0;
                    default: ptr <= ptr;
                endcase
            end

            if (forwarding_head && !forwarding_tail) begin
                grant_locked <= 1'b1;
            end else if (forwarding_tail) begin
                grant_locked <= 1'b0;
            end
        end
    end

`ifndef SYNTHESIS
    a_grant_onehot :
    assert property (@(posedge clk) disable iff (rst) $onehot0(grant))
    else $error("Fail: a_grant_onehot");

    a_grant_valid_matches_grant :
    assert property (@(posedge clk) disable iff (rst)
        grant_valid == (|grant))
    else $error("Fail: a_grant_valid_matches_grant");

    a_no_grant_when_locked :
    assert property (@(posedge clk) disable iff (rst)
        grant_locked |-> grant == 4'b0000)
    else $error("Fail: a_no_grant_when_locked");
`endif

endmodule
