%% 实验一（4）：firpm函数设计FIR希尔伯特变换器

clear all; close all; clc;

N = 60;                % 滤波器阶数
f = [0.05 0.95];       % 归一化通带边界 [0.05, 0.95]（避开直流和奈奎斯特频率）
m = [1 1];             % 通带内幅值响应为1
fs = 2000;             % 采样频率（Hz），用于绘图坐标

% 使用firpm设计希尔伯特变换器，'h'表示奇对称
b = firpm(N, f, m, 'h');

% 计算频率响应
[h, w] = freqz(b, 1, 512, fs);

% 绘图
figure('Position', [100, 100, 1000, 400]);

subplot(1,2,1);
plot(w, 20*log10(abs(h)), 'b', 'LineWidth', 1.5);
grid on;
xlabel('频率 / Hz');
ylabel('幅值 / dB');
title('Hilbert变换器幅频特性');
axis([0, 1000, -45, 10]);

subplot(1,2,2);
plot(w, angle(h)/pi*180, 'r', 'LineWidth', 1.5);
grid on;
xlabel('频率 / Hz');
ylabel('相角 / 度');
title('Hilbert变换器相频特性');
axis([0, 1000, -100, 100]);

sgtitle('firpm等波纹切比雪夫逼近设计 FIR 希尔伯特变换器 (N=60)');