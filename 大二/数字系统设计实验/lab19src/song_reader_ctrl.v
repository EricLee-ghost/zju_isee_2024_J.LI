module song_reader_ctrl(clk, reset, note_done, play, new_note);
    input clk, reset;
    input note_done; // 音符播放结束
    input play; // 高电平要求播放
    output reg new_note; // 新的音符需要播放

    parameter RESET=0,NEW_NOTE=1,WAIT=2,NEXT_NOTE=3;//状态编码
    reg [1:0] state,nextstate;


    always@(posedge clk) begin
        if(reset) state=RESET; // 若复位，则系统处于 RESET 状态
        else state=nextstate;
    end

    always@(*) begin//第二段，组合电路，下一状态和输出
        new_note=0;
        case (state)
            RESET: begin
                new_note=0;
                nextstate=(play==1)?NEW_NOTE:RESET;
            end  // RESET 状态

            NEW_NOTE: begin
                new_note=1;
                nextstate=WAIT;
            end // NEW_NOTE 状态

            WAIT: begin
                if (play) begin
                    if (note_done) nextstate = NEXT_NOTE;
                    else nextstate = WAIT;
                end
                else nextstate = RESET;
            end //WAIT状态

            NEXT_NOTE: begin
                new_note=0;
                nextstate=NEW_NOTE;
            end //NEXT_NOTE状态

            default: nextstate = RESET;
        endcase
    end
endmodule
