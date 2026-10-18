%% 实验三：非同步采样下幅度比与相位差估计

clear all; close all; clc;

% 参数设置（非同步采样）
f0 = 10.3;               % 信号频率（非整数，确保非同步采样）
fs = 50;                 % 采样频率（fs/f0 ≈ 4.854，非整数）
T = 1/fs;
t = 0:T:20;              % 采样时间20秒

a = 1.0;                 % 信号1幅度
b = 0.6;                 % 信号2幅度
theta1 = 0;              % 信号1初始相位
theta2 = pi/4;           % 信号2初始相位（相位差 = pi/4）

% 生成两个信号
x1 = a * cos(2*pi*f0*t + theta1);
x2 = b * cos(2*pi*f0*t + theta2);

% 使用firpm设计希尔伯特变换器
N = 80;
f = [0.05 0.95];
m = [1 1];
b_h = firpm(N, f, m, 'h');

% 通过希尔伯特变换器
x1_hat = filter(b_h, 1, x1);
x2_hat = filter(b_h, 1, x2);

% 由于滤波器有群延时，需要对齐信号
delay = N/2;
x1_aligned = x1(1:end-delay);
x2_aligned = x2(1:end-delay);
x1_hat_aligned = x1_hat(delay+1:end);
x2_hat_aligned = x2_hat(delay+1:end);

% 构造解析信号
v1 = x1_aligned + 1j * x1_hat_aligned;
v2 = x2_aligned + 1j * x2_hat_aligned;

% 提取幅度
A1 = abs(v1);
A2 = abs(v2);
R = A2 ./ A1;

% 提取相位（相位解缠绕）
phi1 = unwrap(angle(v1));
phi2 = unwrap(angle(v2));
delta_phi = phi2 - phi1;

% 取稳态部分（去除滤波器瞬态效应）
steady_start = 500;
t_steady = t(steady_start:end-delay);

R_steady = R(steady_start:end);
delta_phi_steady = delta_phi(steady_start:end);

% 计算统计值
R_mean = mean(R_steady);
R_std = std(R_steady);
delta_phi_mean = mean(delta_phi_steady);
delta_phi_std = std(delta_phi_steady);

fprintf('========== 估计结果 ==========\n');
fprintf('理论幅度比: %.2f\n', b/a);
fprintf('估计幅度比均值: %.4f\n', R_mean);
fprintf('幅度比标准差: %.4f\n', R_std);
fprintf('幅度比相对误差: %.2f%%\n', abs(R_mean - b/a)/(b/a)*100);
fprintf('\n');
fprintf('理论相位差: %.4f rad (%.2f°)\n', theta2-theta1, (theta2-theta1)*180/pi);
fprintf('估计相位差均值: %.4f rad\n', delta_phi_mean);
fprintf('相位差标准差: %.4f rad\n', delta_phi_std);
fprintf('相位差绝对误差: %.4f rad (%.2f°)\n', abs(delta_phi_mean - (theta2-theta1)), abs(delta_phi_mean - (theta2-theta1))*180/pi);

% 绘图
figure('Position', [100, 100, 1200, 800]);

% 子图1：原始信号
subplot(3,2,1);
plot(t(1:200), x1(1:200), 'b', 'LineWidth', 1.2); hold on;
plot(t(1:200), x2(1:200), 'r', 'LineWidth', 1.2);
title('原始信号（前200个采样点）');
xlabel('时间 / s'); ylabel('幅度');
legend('x_1(t)', 'x_2(t)');
grid on;

% 子图2：希尔伯特变换后的信号
subplot(3,2,2);
plot(t(1:200), x1_hat(1:200), 'b', 'LineWidth', 1.2); hold on;
plot(t(1:200), x2_hat(1:200), 'r', 'LineWidth', 1.2);
title('希尔伯特变换后信号');
xlabel('时间 / s'); ylabel('幅度');
legend('\hat{x}_1(t)', '\hat{x}_2(t)');
grid on;

% 子图3：提取的幅度
subplot(3,2,3);
plot(t_steady, A1(steady_start:end), 'b', 'LineWidth', 1); hold on;
plot(t_steady, A2(steady_start:end), 'r', 'LineWidth', 1);
title('提取的幅度（稳态段）');
xlabel('时间 / s'); ylabel('幅度');
legend('A_1', 'A_2');
grid on;

% 子图4：幅度比
subplot(3,2,4);
plot(t_steady, R_steady, 'g', 'LineWidth', 1.2); hold on;
plot(t_steady, ones(size(t_steady))*0.6, 'r--', 'LineWidth', 1.5);
title('估计的幅度比 R = A_2/A_1');
xlabel('时间 / s'); ylabel('幅度比');
legend('估计值', '理论值 0.6');
grid on;
ylim([0.5, 0.7]);

% 子图5：相位差
subplot(3,2,5);
plot(t_steady, delta_phi_steady, 'g', 'LineWidth', 1.2); hold on;
plot(t_steady, ones(size(t_steady))*pi/4, 'r--', 'LineWidth', 1.5);
title('估计的相位差 \Delta\theta = \phi_2 - \phi_1');
xlabel('时间 / s'); ylabel('相位差 / rad');
legend('估计值', '理论值 \pi/4');
grid on;
ylim([0.5, 1.0]);

% 子图6：相位差直方图
subplot(3,2,6);
histogram(delta_phi_steady, 50, 'FaceColor', 'm', 'EdgeColor', 'none');
hold on;
xline(pi/4, 'r--', 'LineWidth', 2);
title('相位差估计值分布（直方图）');
xlabel('相位差 / rad'); ylabel('频数');
legend('估计分布', '理论值');
grid on;

sgtitle('非同步采样下幅度比与相位差估计结果 (firpm设计)');