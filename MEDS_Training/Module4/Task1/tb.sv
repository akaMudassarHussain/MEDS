module tb;
    logic a, b, x, y, z;

    and_gate dut (.a(a), .b(b), .y(y), .x(x), .z(z));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        a = 0; b = 0; #10;
        $display("a=%0b b=%0b x=%0b y=%0b z=%0b", a, b, x, y, z);
        a = 0; b = 1; #10;
        $display("a=%0b b=%0b x=%0b y=%0b z=%0b", a, b, x, y, z);
        a = 1; b = 0; #10;
        $display("a=%0b b=%0b x=%0b y=%0b z=%0b", a, b, x, y, z);
        a = 1; b = 1; #10;
        $display("a=%0b b=%0b x=%0b y=%0b z=%0b", a, b, x, y, z);

        $finish;
    end

endmodule
