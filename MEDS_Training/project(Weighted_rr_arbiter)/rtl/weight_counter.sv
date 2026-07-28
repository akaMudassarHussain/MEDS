// weight_counter.sv
// Tracks remaining credit for whichever requester priority_arbiter is
// currently favoring. Reloads when the winner changes, decrements when
// the same winner continues, and flags exhausted on the cycle that uses
// the last credit so the controller can advance the pointer.

// weight[i] is raw = actual_weight - 1, so effective_credit below adds
// the +1 back before comparing against the fields the arbiter passes in.

module weight_counter #(
    parameter int N            = 4,
    parameter int WEIGHT_WIDTH = 2
)(
    input  logic                            clk,
    input  logic                            rst,
    input  logic [N-1:0][WEIGHT_WIDTH-1:0]  weight,
    input  logic [$clog2(N)-1:0]            winner_idx,
    input  logic                            winner_valid,
    output logic                            exhausted
);

    localparam int IDXW = (N <= 1) ? 1 : $clog2(N);

    logic [WEIGHT_WIDTH:0] credit_q;        // credit left over from the previous cycle
    logic [IDXW-1:0]       prev_winner_q;
    logic                  prev_valid_q;

    logic [WEIGHT_WIDTH:0] effective_credit; // credit available for 'this' cycle's grant
    logic                  is_same_winner;

    always_comb begin
        is_same_winner = winner_valid && prev_valid_q && (winner_idx == prev_winner_q);

    
        //a new requester starts fresh at its full weight
        effective_credit = is_same_winner ? credit_q : ({1'b0, weight[winner_idx]} + 1'b1); // adding 1 because of offset encoding
                                           

        // this grant is about to spend the last unit of credit
        exhausted = winner_valid && (effective_credit == 1);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            credit_q      <= '0;   // all bits set to 0 regardless of width
            prev_winner_q <= '0;
            prev_valid_q  <= 1'b0;
        end else begin
            if (winner_valid)
                credit_q <= effective_credit - 1'b1;

            prev_winner_q <= winner_idx;
            prev_valid_q  <= winner_valid;
        end
    end

endmodule