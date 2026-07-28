// weighted_rr_arbiter.sv
// Top-level weighted round-robin arbiter.
// priority_arbiter.sv handles the rotating pointer + priority-rotated encoder,
// weight_counter.sv handles per-requester credit, this module just wires
// them together and registers the grant.
//
// weight[i] is stored as raw+1, so a 2-bit field covers actual weights 1-4
// instead of wasting the weight=0 encoding.

module weighted_rr_arbiter #(
    parameter int N            = 4,
    parameter int WEIGHT_WIDTH = 2
)(
    input  logic                            clk,
    input  logic                            rst,          // synchronous, active-high
    input  logic [N-1:0]                    req,
    input  logic [N-1:0][WEIGHT_WIDTH-1:0]  weight,
    output logic [N-1:0]                    grant,
    output logic                            grant_valid
);

    localparam int IDXW = (N <= 1) ? 1 : $clog2(N);

    logic [IDXW-1:0] winner_idx;
    logic            winner_valid;
    logic            exhausted;
    logic            advance;

    priority_arbiter #(
        .N (N)
    ) u_priority_arbiter (
        .clk          (clk),
        .rst          (rst),
        .req          (req),
        .advance      (advance),
        .winner_idx   (winner_idx),
        .winner_valid (winner_valid)
    );

    weight_counter #(
        .N            (N),
        .WEIGHT_WIDTH (WEIGHT_WIDTH)
    ) u_weight_counter (
        .clk          (clk),
        .rst          (rst),
        .weight       (weight),
        .winner_idx   (winner_idx),
        .winner_valid (winner_valid),
        .exhausted    (exhausted)
    );

    // pointer advances once the current winner has spent its last credit;
    // a requester that just drops req is already skipped by the encoder,
    // so no separate "deassert" trigger is needed here
    always_comb begin
        advance = winner_valid && exhausted;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            grant       <= '0;
            grant_valid <= 1'b0;
        end else begin
            grant       <= '0;
            grant_valid <= winner_valid;
            if (winner_valid)
                grant[winner_idx] <= 1'b1;
        end
    end

endmodule