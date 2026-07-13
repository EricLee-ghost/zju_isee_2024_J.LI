module syn(clk, in, out);
    input clk, in;
    output out;
    reg q1, q2; // 两个D触发器的输出

    always @ (posedge clk) begin
        q1 <= in;
        q2 <= q1;
    end // 非阻塞赋值

    assign out = q1 && (~q2);
endmodule
