% 实验二：验证希尔伯特变换器的90°相移功能

clear all; close all; clc;

% 使用firpm设计希尔伯特变换器
N = 60;
f = [0.05 0.95];
m = [1 1];
fs = 2000;
b = firpm(N, f, m, 'h');

% 生成输入信号（时长0.2秒，共401个采样点）
t = 0:1/fs:0.2;
x = sin(2*pi*10*t);      % 10Hz正弦信号

% 滤波
y = filter(b, 1, x);

% 绘图
figure('Position', [100, 100, 800, 400]);

subplot(2,1,1);
plot(t, x, 'b', 'LineWidth', 1.5);
title('输入信号 x(t) = sin(2\pi\cdot10t)');
xlabel('时间 / s'); ylabel('幅度');
grid on;
axis([0, 0.2, -1.2, 1.2]);

subplot(2,1,2);
plot(t, y, 'r', 'LineWidth', 1.5);
title('输出信号（希尔伯特变换）');
xlabel('时间 / s'); ylabel('幅度');
grid on;
axis([0, 0.2, -1.2, 1.2]);

sgtitle('希尔伯特变换器90°相移验证 (firpm设计)');