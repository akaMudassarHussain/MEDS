module gates3(
    input logic a, b,
    output logic x, y, z
);

assign x = a | b;
assign y = a & b;
assign z = a ^ b;

endmodule
