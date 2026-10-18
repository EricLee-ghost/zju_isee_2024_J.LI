%% 实验一（3）：最优化设计——均方误差最小化逼近（firls函数）

clear all; close all; clc;

N = 60;                % 滤波器阶数
f = [0.05 0.95];       % 归一化通带边界
m = [1 1];             % 通带内理想幅频响应为1
fs = 2000;             % 采样频率（Hz），用于绘图坐标

% 使用firls设计希尔伯特变换器（均方误差最小化）
% 'h'表示奇对称（希尔伯特变换器）
b_firls = firls(N, f, m, 'h');

% 计算频率响应
[H_firls, w] = freqz(b_firls, 1, 512, fs);

H_firls_db = 20 * log10(abs(H_firls) + eps);
pha_firls = angle(H_firls);

% 绘图
figure('Position', [100, 100, 1000, 400]);

subplot(1,2,1);
plot(w, H_firls_db, 'b', 'LineWidth', 1.5);
grid on;
xlabel('频率 / Hz');
ylabel('幅值 / dB');
title('firls 幅频特性（均方误差最小化）');
axis([0, 1000, -45, 10]);

subplot(1,2,2);
plot(w, pha_firls/pi*180, 'r', 'LineWidth', 1.5);
grid on;
xlabel('频率 / Hz');
ylabel('相角 / 度');
title('firls 相频特性');
axis([0, 1000, -100, 100]);

sgtitle('均方误差最小化逼近设计 FIR 希尔伯特变换器 (firls, N=60)');