module song_over(clk, ci, duration, song_done);
    input clk, ci; // ci 为地址计数器进位，高电平表示乐曲结束
    input[5:0] duration; // song_rom 输出 duration
    output reg song_done; // 即 song_done，乐曲播放结束

    parameter PLAY = 0, OVER = 1; // 状态编码
    reg state, nextstate;

    // 状态寄存器
    always @ (posedge clk)
    begin
        if (ci)
        begin
            state = OVER; // 若计数器进位，则播放结束
        end
        else state = nextstate;
    end

    // 下一个状态和输出
    always @ (*)
    begin
        // 初始
        song_done=0;
        case (state)
            PLAY: begin
                    if (!duration) // 若duration为0，则播放结束
                    begin
                        nextstate = OVER;
                        song_done = 1;
                    end
                    else nextstate = PLAY;  // 否则继续播放
                  end
            OVER: begin
                    if (!duration) nextstate = OVER; // 若duration为0，则继续为OVER状态
                    else nextstate = PLAY; // 否则播放
                  end
            default: begin nextstate = OVER; song_done = 1; end
        endcase
    end
endmodule







