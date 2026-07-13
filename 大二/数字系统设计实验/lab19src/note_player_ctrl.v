module note_player_ctrl(clk, reset, play_enable, load_new_note, load, timer_clear, timer_done, note_done);
    input clk, reset;
    input play_enable; // 高电平表示播放
    input load_new_note; // 新的音符需要播放
    input timer_done; // 计时结束
    output reg load; // D触发器使能输入
    output reg timer_clear; // 清零信号
    output reg note_done; // 音符播放完毕

    parameter RESET = 0, WAIT = 1, DONE = 2, LOAD = 3; // 状态编码
    reg[1:0] state, nextstate;

    always@(posedge clk) begin
        if(reset) state=RESET; // 若复位，则处于 RESET 状态
        else state=nextstate;
    end

    always@(*) begin
        timer_clear=0;load=0;note_done=0; // 初始化
        case (state)
            RESET: begin
                timer_clear=1;
                nextstate=WAIT;
            end //RESET 状态

            WAIT: begin
                if (play_enable) begin
                    if (timer_done) nextstate = DONE;
                    else begin
                        if (load_new_note) nextstate = LOAD;
                        else nextstate = WAIT;
                    end
                end
                else nextstate = RESET;
            end //WAIT 状态

            DONE: begin
                timer_clear = 1; note_done = 1;
                nextstate = WAIT;
            end //DONE 状态

            LOAD: begin
                timer_clear = 1; load = 1;
                nextstate = WAIT;
            end //LOAD 状态

            default: nextstate = RESET; // 否则处于 RESET 状态
        endcase
    end
endmodule
