module tb4;
    logic a, b, x, y, z;

    gate4 dut (.a(a), .b(b), .y(y), .x(x), .z(z));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb4);

        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end

endmodule
