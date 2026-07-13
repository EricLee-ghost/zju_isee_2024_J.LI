module note_timer(clk, beat, duration_to_load, timer_clear, timer_done);
    input clk;
    input beat; // 定时基准信号
    input[5:0] duration_to_load; // 音符的音长
    input timer_clear; // 清零信号
    output timer_done; // 计时结束
    reg[5:0] cnt = 0; // 计数

    assign timer_done = (cnt == (duration_to_load - 1)); // 计时结束

    always @ (posedge clk) begin
        if (timer_clear) cnt = 0; // 清零
        else begin
            if (beat) cnt = cnt + 1;
            else cnt = cnt; // 若 beat 高电平则计数，否则保持
        end
    end
endmodule
