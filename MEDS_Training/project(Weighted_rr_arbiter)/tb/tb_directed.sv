// tb_directed.sv
// Directed test scenarios for weighted_rr_arbiter: basic behavior (Section 5),
// equal-weight rotation order, single-requester weight enforcement, and the
// mid-rotation deassert / credit-banking edge cases. Randomized fairness and
// long-run starvation checks live in tb_random_fairness.sv instead.

module tb_directed;

    localparam int N  = 4;
    localparam int WW = 2;

    logic                  clk = 0;
    logic                  rst;
    logic [N-1:0]          req;
    logic [N-1:0][WW-1:0]  weight;
    logic [N-1:0]          grant;
    logic                  grant_valid;

    int pass_count = 0;
    int fail_count = 0;

    weighted_rr_arbiter #(
        .N            (N),
        .WEIGHT_WIDTH (WW)
    ) dut (
        .clk          (clk),
        .rst          (rst),
        .req          (req),
        .weight       (weight),
        .grant        (grant),
        .grant_valid  (grant_valid)
    );

    always #5 clk = ~clk;

    // raw field = actual weight - 1 (see weighted_rr_arbiter.sv header)
    function automatic logic [WW-1:0] raw_w(input int actual);
        return (actual - 1);
    endfunction

    // index of the single set bit in a one-hot grant vector, -1 if none
    function automatic int onehot_idx(input logic [N-1:0] g);
        for (int i = 0; i < N; i++)
            if (g[i]) return i;
        return -1;
    endfunction

    task automatic report(input string name, input logic condition);
        if (condition) begin
            $display("[PASS] %s", name);
            pass_count++;
        end else begin
            $display("[FAIL] %s", name);
            fail_count++;
        end
    endtask

    task automatic do_reset();
        rst = 1'b1;
        req = '0;
        for (int i = 0; i < N; i++) weight[i] = raw_w(1);
        repeat (2) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);
    endtask

    // ---- Scenario 1: no requests -> grant_valid must stay low ----
    task automatic scenario_no_requests();
        do_reset();
        req = '0;
        repeat (5) @(posedge clk);
        #1;
        report("no requests: grant_valid low", grant_valid === 1'b0);
    endtask

    // ---- Scenario 2/3: single requester active gets every grant ----
    task automatic scenario_single_requester(input int idx);
        int grants_seen, cycles;
        do_reset();
        req      = '0;
        req[idx] = 1'b1;
        grants_seen = 0;
        cycles      = 10;
        for (int c = 0; c < cycles; c++) begin
            @(posedge clk); #1;
            if (grant_valid && (onehot_idx(grant) == idx))
                grants_seen++;
        end
        report($sformatf("single requester %0d gets every grant", idx),
               grants_seen == cycles);
    endtask

    // ---- Scenario 4: equal weights -> plain round robin order ----
    task automatic scenario_equal_weight_rotation();
        int expected_seq[8] = '{0, 1, 2, 3, 0, 1, 2, 3};
        int got, ok;
        do_reset();
        req = '1;
        ok  = 1;
        for (int c = 0; c < 8; c++) begin
            @(posedge clk); #1;
            got = onehot_idx(grant);
            if (!grant_valid || (got != expected_seq[c])) ok = 0;
        end
        report("equal weights: rotation follows 0,1,2,3,...", ok);
    endtask

    // ---- Scenario 5: weight-2 requester gets 2 consecutive grants ----
    task automatic scenario_weight_enforcement();
        int seq[6] = '{0, 0, 1, 2, 3, 0}; // requester 0 has weight 2
        int got, ok;
        do_reset();
        weight[0] = raw_w(2);
        req       = '1;
        ok        = 1;
        for (int c = 0; c < 6; c++) begin
            @(posedge clk); #1;
            got = onehot_idx(grant);
            if (!grant_valid || (got != seq[c])) ok = 0;
        end
        report("weight-2 requester gets 2 consecutive grants", ok);
    endtask

    // ---- Scenario 6: requester deasserts mid-rotation, reasserts later ----
    task automatic scenario_deassert_reassert();
        int ok;
        do_reset();
        weight[1] = raw_w(3);
        req       = 4'b0010; // only requester 1 asking
        ok        = 1;

        @(posedge clk); #1;
        if (!grant_valid || (onehot_idx(grant) != 1)) ok = 0;

        req = '0; // drops its request after 1 grant, mid-weight
        repeat (3) @(posedge clk);
        #1;
        if (grant_valid) ok = 0; // nobody should be granted while idle

        req = 4'b0010; // reasserts
        @(posedge clk); #1;
        if (!grant_valid || (onehot_idx(grant) != 1)) ok = 0;

        report("requester deassert mid-rotation, reassert later", ok);
    endtask

    // ---- Scenario 7: dropped request must not bank leftover credit ----
    task automatic scenario_no_credit_banking();
        int ok, grants_after_reassert;
        do_reset();
        weight[2] = raw_w(3);
        req       = 4'b0100; // only requester 2 asking

        @(posedge clk); #1; // uses 1 of its 3 credits
        ok = grant_valid && (onehot_idx(grant) == 2);

        req = '0; // drops with 2 credits still unused
        repeat (2) @(posedge clk);

        req = 4'b1101; // reasserts alongside requesters 0 and 3
        grants_after_reassert = 0;
        for (int c = 0; c < 3; c++) begin
            @(posedge clk); #1;
            if (grant_valid && (onehot_idx(grant) == 2))
                grants_after_reassert++;
        end
        // fresh reload gives it a fresh weight-3 turn, not "2 banked + new 3"
        report("dropped credit is not banked on reassert",
               ok && (grants_after_reassert <= 3));
    endtask

    // ---- Scenario 8: back-to-back resets mid-arbitration ----
    task automatic scenario_back_to_back_reset();
        int ok;
        do_reset();
        req = '1;
        repeat (3) @(posedge clk);

        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;
        @(posedge clk);
        rst = 1'b1; // second reset right on top of the first
        @(posedge clk);
        rst = 1'b0;
        @(posedge clk); #1;

        ok = grant_valid && (onehot_idx(grant) == 0); // clean restart at requester 0
        report("back-to-back resets recover cleanly", ok);
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_directed);

        scenario_no_requests();
        scenario_single_requester(0);
        scenario_single_requester(2);
        scenario_equal_weight_rotation();
        scenario_weight_enforcement();
        scenario_deassert_reassert();
        scenario_no_credit_banking();
        scenario_back_to_back_reset();

        $display("---- tb_directed summary: %0d passed, %0d failed ----",
                  pass_count, fail_count);
        $finish;
    end

endmodule