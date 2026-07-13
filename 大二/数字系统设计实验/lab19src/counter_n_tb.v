`timescale 1ns / 1ps

module counter_n_tb;
    // Inputs
    reg clk;
    reg en;
    reg r;

    // Outputs
    wire co;
    wire[9:0] q;

    // Instantiate the Unit Under Test (UUT)
    counter_n #(.n(1000), .counter_bits(10)) uut (
        .clk(clk),
        .r(r),
        .en(en),
        .co(co),
        .q(q)
    );

    // tb
    initial begin
        clk = 0; r = 0; en = 0; // 初始化
        #(51) r = 1; // 复位
        #(100)r = 0; en = 1;
        #(800)
        repeat (1000)
        begin
            #(100*3)  en = 1; // 使能
            # 100  en = 0;
        end
        #100 $stop;
    end

    //clock
    always #50 clk = ~clk;
endmodule
