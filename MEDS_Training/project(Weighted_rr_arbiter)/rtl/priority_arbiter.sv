// priority_arbiter.sv
// Rotating priority pointer + priority-rotated request encoder.

module priority_arbiter #(
    parameter int N = 4
)(
    input  logic                  clk,
    input  logic                  rst,        // synchronous, active-high
    input  logic [N-1:0]          req,
    input  logic                  advance,
    output logic [$clog2(N)-1:0]  winner_idx,
    output logic                  winner_valid
);

    localparam int IDXW = (N <= 1) ? 1 : $clog2(N);

    logic [IDXW-1:0] ptr_q;

    // advance to one past the winner, not ptr_q+1 -- with sparse req
    // patterns the winner can sit several steps ahead of the pointer
    always_ff @(posedge clk) begin
        if (rst)
            ptr_q <= '0;
        else if (advance)
            ptr_q <= (winner_idx == N-1) ? '0 : (winner_idx + 1'b1);
    end

    // scan from farthest offset to 0, overwriting on each match so the
    // closest asking requester (offset 0) wins
    always_comb begin
        winner_idx   = '0;
        winner_valid = 1'b0;
        for (int i = N-1; i >= 0; i--) begin
            automatic int idx = (ptr_q + i) % N;
            if (req[idx]) begin
                winner_idx   = idx[IDXW-1:0];
                winner_valid = 1'b1;
            end
        end
    end

endmodule