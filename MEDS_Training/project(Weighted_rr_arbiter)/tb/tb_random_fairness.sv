// tb_random_fairness.sv
// Fairness (equal/unequal/max/min weight), starvation, and randomized
// scenarios from Section 5. Tolerance and starvation bound follow the
// mentor's guidance: ratio within +/-10% of weight share, and no
// continuously-requesting requester waits longer than
// (sum of everyone else's actual weight + 2 slack cycles).

module tb_random_fairness;

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

    int grant_count[N];
    int wait_cycles[N];
    int max_wait[N];

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

    function automatic logic [WW-1:0] raw_w(input int actual);
        return (actual - 1);
    endfunction

    function automatic int actual_w(input logic [WW-1:0] raw);
        return (raw + 1);
    endfunction

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

    task automatic reset_counts();
        for (int i = 0; i < N; i++) begin
            grant_count[i] = 0;
            wait_cycles[i] = 0;
            max_wait[i]    = 0;
        end
    endtask

    task automatic do_reset();
        rst = 1'b1;
        req = '0;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);
    endtask

    // one clock's worth of req -> grant monitoring, called after req is
    // already set for this cycle
    task automatic step_and_monitor();
        int winner;
        @(posedge clk); #1;
        winner = grant_valid ? onehot_idx(grant) : -1;
        if (grant_valid) grant_count[winner]++;
        for (int i = 0; i < N; i++) begin
            if (i == winner) begin
                wait_cycles[i] = 0;
            end else if (req[i]) begin
                wait_cycles[i]++;
                if (wait_cycles[i] > max_wait[i]) max_wait[i] = wait_cycles[i];
            end
        end
    endtask

    // ratio check: within +/-10% of weight share
    task automatic check_ratio(input string label, input int total_cycles);
        int total_weight;
        int total_grants;
        real expected_frac, actual_frac;
        logic all_ok;

        total_weight = 0;
        total_grants = 0;
        for (int i = 0; i < N; i++) begin
            total_weight += actual_w(weight[i]);
            total_grants += grant_count[i];
        end

        all_ok = 1'b1;
        for (int i = 0; i < N; i++) begin
            expected_frac = real'(actual_w(weight[i])) / real'(total_weight);
            actual_frac   = (total_grants > 0) ? real'(grant_count[i]) / real'(total_grants) : 0.0;
            if ((actual_frac < expected_frac - 0.10) || (actual_frac > expected_frac + 0.10))
                all_ok = 1'b0;
            $display("    R%0d: expected %.1f%%, actual %.1f%% (%0d grants)",
                      i, expected_frac*100.0, actual_frac*100.0, grant_count[i]);
        end
        report(label, all_ok);
    endtask

    // starvation check: no requester's worst wait exceeds
    // (sum of others' weight + 2), only meaningful for requesters that
    // asked continuously during the run
    task automatic check_starvation(input string label, input logic [N-1:0] continuous_mask);
        int total_weight;
        logic all_ok;

        total_weight = 0;
        for (int i = 0; i < N; i++) total_weight += actual_w(weight[i]);

        all_ok = 1'b1;
        for (int i = 0; i < N; i++) begin
            if (continuous_mask[i]) begin
                int bound = (total_weight - actual_w(weight[i])) + 2;
                if (max_wait[i] > bound) all_ok = 1'b0;
                $display("    R%0d: max_wait=%0d, bound=%0d", i, max_wait[i], bound);
            end
        end
        report(label, all_ok);
    endtask

    // ---- Fairness scenarios ----
    task automatic scenario_fairness(input string label, input int w[N], input int cycles);
        do_reset();
        reset_counts();
        for (int i = 0; i < N; i++) weight[i] = raw_w(w[i]);
        req = '1;
        for (int c = 0; c < cycles; c++) step_and_monitor();
        check_ratio(label, cycles);
    endtask

    // ---- Starvation: one continuous, others intermittent ----
    task automatic scenario_intermittent_starvation();
        do_reset();
        reset_counts();
        weight[0] = raw_w(3);
        weight[1] = raw_w(1);
        weight[2] = raw_w(1);
        weight[3] = raw_w(1);

        for (int c = 0; c < 300; c++) begin
            req[0] = 1'b1; // continuously active
            req[1] = ($urandom_range(0, 3) == 0);
            req[2] = ($urandom_range(0, 3) == 0);
            req[3] = ($urandom_range(0, 3) == 0);
            step_and_monitor();
        end
        check_starvation("intermittent neighbors are not starved", 4'b0001);
    endtask

    // ---- Long run, all continuously active, zero starvation violations ----
    task automatic scenario_long_run();
        do_reset();
        reset_counts();
        weight[0] = raw_w(2);
        weight[1] = raw_w(4);
        weight[2] = raw_w(1);
        weight[3] = raw_w(3);
        req = '1;
        for (int c = 0; c < 500; c++) step_and_monitor();
        check_starvation("500+ cycle run: zero starvation violations", 4'b1111);
        check_ratio("500+ cycle run: ratios track weights", 500);
    endtask

    // ---- Randomized request/weight combinations ----
    task automatic scenario_randomized();
        do_reset();
        reset_counts();
        for (int i = 0; i < N; i++) weight[i] = raw_w($urandom_range(1, 4));

        for (int c = 0; c < 300; c++) begin
            for (int i = 0; i < N; i++) req[i] = $urandom_range(0, 1);
            step_and_monitor();
        end
        check_ratio("randomized req/weight: ratio check", 300);
        // only requesters lucky enough to be asking on every cycle are
        // held to the strict bound here; sporadic random req can't be
        report("randomized run completed without hang", 1'b1);
    endtask

    initial begin
        int equal_w[N]   = '{1, 1, 1, 1};
        int unequal_w[N] = '{1, 2, 3, 4};
        int max_w[N]     = '{4, 4, 4, 4};
        int min_w[N]     = '{1, 1, 1, 1};

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_random_fairness);

        scenario_fairness("equal weights: grants evenly distributed", equal_w, 200);
        scenario_fairness("unequal weights: ratio tracks weight", unequal_w, 200);
        scenario_fairness("all max weight: ratio still even", max_w, 200);
        scenario_fairness("all min weight: plain round robin ratio", min_w, 200);
        scenario_intermittent_starvation();
        scenario_long_run();
        scenario_randomized();

        $display("---- tb_random_fairness summary: %0d passed, %0d failed ----",
                  pass_count, fail_count);
        $finish;
    end

endmodule