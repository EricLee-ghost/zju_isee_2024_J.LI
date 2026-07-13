module dds(k,clk,reset,sampling_pulse,sample,new_sample_ready);
    input clk,reset,sampling_pulse;
    input [21:0] k; //相位增量
    output [15:0] sample; //正弦信号
    output new_sample_ready;

    //中间变量
    wire[21:0] raw_addr; //地址处理输入
    wire[9:0] rom_addr; //地址处理输出
    wire[15:0] raw_data; //数据处理输入
    wire[15:0] data; //数据处理输出
    wire[21:0] sum; //加法器输出
    wire area; //区域

    //加法器得到sum
    full_adder adder0(.a(k), .b(raw_addr), .s(sum), .ci(1'b0), .co()); //进位输入设为0

    //D触发器得到raw_addr
    dffre #(.n(22)) dffre1(.clk(clk), .d(sum), .en(sampling_pulse), .r(reset), .q(raw_addr));

    //地址处理
    assign rom_addr[9:0] = raw_addr[20]?((raw_addr[20:10]==1024)?1023:(~raw_addr[19:10]+1)):raw_addr[19:10];

    //生成正弦
    sine_rom sin1(.clk(clk), .addr(rom_addr), .dout(raw_data));

    //D触发器生成area
    dffre #(.n(1)) dffre4(.clk(clk), .d(raw_addr[21]), .en(1'b1), .r(1'b0), .q(area));

    //数据处理
    assign data[15:0] = area?(~raw_data[15:0]+1):raw_data[15:0];

    //D触发器得到sample
    dffre #(.n(16)) dffre2(.clk(clk), .d(data), .en(sampling_pulse), .r(1'b0), .q(sample));

    //D触发器得到new_sample_ready
    dffre #(.n(1)) dffre3(.clk(clk), .d(sampling_pulse), .en(1'b1), .r(1'b0), .q(new_sample_ready));
endmodule
