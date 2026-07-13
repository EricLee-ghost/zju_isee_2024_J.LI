module mcu_ctrl(clk, reset, play_pause, next, song_done, play, reset_play, NextSong);
    input clk, reset;
    input play_pause; // play_pause 按钮
    input next; // next 按钮
    input song_done; // 乐曲播放结束
    output reg play;
    output reg reset_play; // 脉冲复位
    output reg NextSong; // 控制器输出
    parameter RESET = 0, PAUSE = 1, PLAY = 2, NEXT = 3; // 状态编码
    reg[1:0] state, nextstate; // 当前状态与下一个状态

    // 状态寄存器
    always @ (posedge clk) begin
        if (reset)
            state = RESET; // 只要按下 RESET 按钮即复位
        else
            state = nextstate; // 否则继续运行
    end

    // 下一个状态和输出
    always @ (*) begin
        play = 0; NextSong = 0; reset_play = 0; // 默认值设为0

        case (state)
            RESET: begin nextstate = PAUSE; reset_play = 1; NextSong = 0; end // RESET 状态

            PAUSE: begin
                if (play_pause) nextstate = PLAY;
                else begin
                    if (next) nextstate = NEXT;
                    else nextstate = PAUSE;
                end
            end // PAUSE 状态

            NEXT: begin nextstate = PLAY; NextSong = 1; reset_play = 1; end // NEXT 状态

            PLAY: begin
                play = 1;
                if (play_pause) nextstate = PAUSE;
                else begin
                     if (next) nextstate = NEXT;
                     else begin
                          if (song_done) nextstate = RESET;
                          else nextstate = PLAY;
                     end
                end
            end // PLAY 状态

            default: nextstate = RESET;
        endcase
    end
endmodule
