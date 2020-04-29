module decoder2_4 ( a,x );

input [1:0] a;

output[3:0]x;


assign x[0] = (~a[0]) & (~a[1]);
assign x[2] = (~a[0]) & a[1];
assign x[1] = a[0] & (~a[1]);
assign x[3] = a[0] & a[1];

endmodule