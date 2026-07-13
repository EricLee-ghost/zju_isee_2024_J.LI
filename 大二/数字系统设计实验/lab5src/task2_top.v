module ModeComparator(a,b,m,y);
 input [8:0] a, b;
 input m;
 output[8:0] y;

 wire agb;
 comp #(.n(8))comp_inst(.a(a),.b(b),.agb(agb),.aeb(),.alb());

 mux_2to1 #(.n(8)) mux(.out(y),.in0(a),.in1(b),.addr(~(m^agb)));

endmodule
