module mcu (clk, reset, play_pause, next, song_done, play, reset_play, song);
    input clk;
    input reset;
    input play_pause;  // play_pause 按钮
    input next;  // next 按钮
    input song_done;  // 乐曲播放结束
    output play;
    output reset_play; // 脉冲复位
    output [1:0] song;  // 乐曲序号
    wire NextSong; // 控制器输出

    // 调用控制器
    mcu_ctrl ctrl0(.clk(clk), .reset(reset), .play_pause(play_pause), .next(next), .song_done(song_done), .play(play), .reset_play(reset_play), .NextSong(NextSong));

    // 调用2位二进制计数器
    counter_n #(.n(4), .counter_bits(2)) song_cnt(.clk(clk), .en(NextSong), .r(reset), .q(song), .co());
endmodule
