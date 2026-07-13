`timescale 1ns / 1ps

module syn_tb;
    // Inputs
    reg clk;
    reg in;

    // Outputs
    wire out;

    // Instantiate the Unit Under Test (UUT)
    syn uut(
        .clk(clk),
        .in(in),
        .out(out)
    );

    // tb
    initial begin
        clk = 0; in = 0; // 初始化
        #(10) in = 0;
        #(10) in = 1;
        #(10) in = 0;
        repeat (20) // 时钟 1
        begin
            #(20*3) in = 1;
            #(20) in = 0;
        end
        repeat (30) // 时钟 2
        begin
            #(10) in = 1;
            #(10*2) in = 0;
        end
        #100 $stop;
    end

    //clock
    always #50 clk = ~clk; // clk时钟信号
endmodule
