module comp(a,b,agb,aeb,alb);
 parameter n=1;
 input[n-1:0] a, b;
 output reg agb;
 output reg aeb;
 output reg alb;

 always @(a or b)
 begin
 if(a>b) {agb,aeb,alb}=3'b100;
 else if(a==b) {agb,aeb,alb}=3'b010;
 else {agb,aeb,alb}=3'b001;
 end
endmodule
