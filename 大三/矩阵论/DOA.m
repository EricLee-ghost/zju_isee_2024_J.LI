% 生成单信源阵列观测数据和含一个干扰源的阵列观测数据
clear; clc; close all; 
set(groot,'defaultAxesFontName','Microsoft YaHei'); 
set(groot,'defaultTextFontName','Microsoft YaHei'); 

seed = 2026; % 随机种子
c = 1500; % 信号速度，单位m/s
f = 100; % 信号频率
wavelength = c/f; % 波长，单位m
N = 8; % 阵元数
d = wavelength/2; % 阵元间距
L = 200; % 观测次数
theta0 = -30; % 真实到达角，单位为度
snr_db = 15; % 每阵元信噪比，单位dB
angles = -90:0.1:90; % 候选角度

rng(seed,'twister'); % 固定随机种子
s = exp(1i*2*pi*rand(1,L)); % 生成L个幅值为1，相位随机的复信源信号值
noise = (randn(N,L) + 1i*randn(N,L))/sqrt(2); % 生成单位平均功率的复高斯噪声

index = (0:N-1).'; % 阵元编号：0、1、……、N-1
a0 = exp(1i*2*pi*(d/wavelength)*index*sind(theta0)); % 计算真实角度的方向矢量
noise_power = 10^(-snr_db/10); % 将dB表示的信噪比换算为噪声功率
x = a0*s + sqrt(noise_power)*noise; % 生成N×L观测矩阵

theta_i = 20; % 干扰源到达角，单位为度
sir_list = [20 10 5 0 -5]; % 需要比较的信干比，单位为dB
u = exp(1i*2*pi*rand(1,L)); % 生成L个幅值为1、相位随机的复干扰信号值
ai = exp(1i*2*pi*(d/wavelength)*index*sind(theta_i)); % 计算干扰源角度的方向矢量
x_interference = cell(1,numel(sir_list)); % 用元胞数组保存不同信干比下的观测矩阵

for k = 1:numel(sir_list) % 依次生成不同信干比下的含干扰观测数据
    sir_db = sir_list(k); % 当前信干比，单位为dB
    interference_power = 10^(-sir_db/10); % 由信干比计算干扰信号功率
    x_interference{k} = ... % 生成当前信干比下的N×L观测矩阵
        a0*s ... % 目标源信号
        + sqrt(interference_power)*ai*u ... % 干扰源信号
        + sqrt(noise_power)*noise; % 与单目标实验相同的噪声
end

fprintf('方向矢量形状：%d×%d\n',size(a0,1),size(a0,2)); 
fprintf('观测矩阵形状：%d×%d\n',size(x,1),size(x,2));
fprintf('候选角度个数：%d\n',numel(angles)); 
for k = 1:numel(sir_list) % 输出各组含干扰观测矩阵的形状
    fprintf('信干比%d dB时的观测矩阵形状：%d×%d\n', ...
        sir_list(k),size(x_interference{k},1),size(x_interference{k},2));
end

shown = min(40,L); % 绘制一个阵元的观测示例，取前40次观测
figure('Color','w','Position',[100 100 800 400]); 
plot(1:shown,real(x(1,1:shown)),'LineWidth',1.1); hold on; 
plot(1:shown,imag(x(1,1:shown)),'LineWidth',1.1); 
xlabel('观测序号'); 
ylabel('信号值'); 
title('第1个阵元的接收信号示例');
legend('实部','虚部','Location','northeast','FontName','Microsoft YaHei'); 
grid on; 
print(gcf,'reference.png','-dpng','-r200'); 

% =========================================================================
% 矩阵论大作业：目标源到达角估计 (问题3与问题4完整代码)
% =========================================================================
clear; clc; close all; 
set(groot,'defaultAxesFontName','Microsoft YaHei'); 
set(groot,'defaultTextFontName','Microsoft YaHei'); 

%% 1. 基础参数与数据生成
seed = 2026; 
c = 1500; 
f = 100; 
wavelength = c/f; 
N = 8; 
d = wavelength/2; 
L = 200; 
theta0 = -30; 
snr_db = 15; 
angles = -90:0.1:90; 

rng(seed,'twister'); 
s = exp(1i*2*pi*rand(1,L)); 
noise = (randn(N,L) + 1i*randn(N,L))/sqrt(2); 
index = (0:N-1).'; 
a0 = exp(1i*2*pi*(d/wavelength)*index*sind(theta0)); 
noise_power = 10^(-snr_db/10); 
x = a0*s + sqrt(noise_power)*noise; 

% 生成含干扰源的观测数据
theta_i = 20; 
sir_list = [20 10 5 0 -5]; 
u = exp(1i*2*pi*rand(1,L)); 
ai = exp(1i*2*pi*(d/wavelength)*index*sind(theta_i)); 
x_interference = cell(1,numel(sir_list)); 

for k = 1:numel(sir_list) 
    sir_db = sir_list(k); 
    interference_power = 10^(-sir_db/10); 
    x_interference{k} = a0*s + sqrt(interference_power)*ai*u + sqrt(noise_power)*noise; 
end

% 预先计算所有候选角度的方向矢量矩阵 A (N x length(angles))
A = exp(1i*2*pi*(d/wavelength)*index*sind(angles)); 

%% ================= 问题 3.1：单目标 DOA 估计 =================
AHX = A' * x; 
norm_x2 = norm(x, 'fro')^2; 
J = norm_x2 - sum(abs(AHX).^2, 2) / N; 
J_norm = (J / norm_x2).'; 

[Jmin, idx] = min(J_norm);
theta_hat = angles(idx);
err = abs(theta_hat - theta0);

fprintf('\n=== 问题 3.1 单目标 DOA 估计结果 ===\n');
fprintf('真实角度: %.2f°, 估计角度: %.2f°, 绝对误差: %.2f°\n', theta0, theta_hat, err);
fprintf('最小归一化残差 Jmin/||X||_F^2: %.4f\n\n', Jmin);

figure('Color','w');
plot(angles, J_norm, 'LineWidth', 1.5, 'DisplayName', '归一化残差'); hold on;
xline(theta0, 'r--', 'LineWidth', 1.5, 'DisplayName', '真实角度');
xline(theta_hat, 'g:', 'LineWidth', 1.5, 'DisplayName', '估计角度');
xlabel('角度/(°)'); ylabel('J(\theta)/||X||_F^2');
title('单目标 DOA 归一化残差曲线'); grid on; legend('Location','best');

%% ================= 问题 3.2：不同信噪比下的估计结果 =================
snr_list = [5, 15, 20];
figure('Color','w'); hold on;
fprintf('=== 问题 3.2 不同信噪比估计结果 ===\n');
for i = 1:length(snr_list)
    snr_curr = snr_list(i);
    x_curr = a0*s + sqrt(10^(-snr_curr/10))*noise; 
    
    AHX_curr = A' * x_curr;
    norm_x2_curr = norm(x_curr, 'fro')^2;
    J_curr = norm_x2_curr - sum(abs(AHX_curr).^2, 2) / N;
    J_norm_curr = (J_curr / norm_x2_curr).';
    
    [Jmin_curr, idx_curr] = min(J_norm_curr);
    theta_hat_curr = angles(idx_curr);
    err_curr = abs(theta_hat_curr - theta0);
    
    fprintf('SNR = %2d dB: 估计角度 = %6.2f°, 误差 = %5.2f°, Jmin/||X||^2 = %.4f\n', ...
        snr_curr, theta_hat_curr, err_curr, Jmin_curr);
    plot(angles, J_norm_curr, 'LineWidth', 1.2, 'DisplayName', sprintf('SNR = %d dB', snr_curr));
end
xline(theta0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
xlabel('角度/(°)'); ylabel('J(\theta)/||X||_F^2');
title('不同信噪比下的归一化残差曲线'); grid on; legend('Location','best');

%% ================= 问题 3.3：不同阵列孔径下的估计结果 =================
N_list = [4, 8, 12];
figure('Color','w'); hold on;
fprintf('\n=== 问题 3.3 不同阵列孔径估计结果 ===\n');
for i = 1:length(N_list)
    N_curr = N_list(i);
    index_curr = (0:N_curr-1).';
    
    a0_curr = exp(1i*2*pi*(d/wavelength)*index_curr*sind(theta0));
    A_curr = exp(1i*2*pi*(d/wavelength)*index_curr*sind(angles));
    
    % 采用与提供程序一致的公式，独立生成对应维度的噪声
    noise_curr = (randn(N_curr,L) + 1i*randn(N_curr,L))/sqrt(2);
    x_curr = a0_curr*s + sqrt(noise_power)*noise_curr;
    
    AHX_curr = A_curr' * x_curr;
    norm_x2_curr = norm(x_curr, 'fro')^2;
    J_curr = norm_x2_curr - sum(abs(AHX_curr).^2, 2) / N_curr;
    J_norm_curr = (J_curr / norm_x2_curr).';
    
    [Jmin_curr, idx_curr] = min(J_norm_curr);
    theta_hat_curr = angles(idx_curr);
    err_curr = abs(theta_hat_curr - theta0);
    aperture = (N_curr - 1) * d; 
    
    fprintf('N = %2d, 孔径 = %4.1f m: 估计角度 = %6.2f°, 误差 = %5.2f°, Jmin/||X||^2 = %.4f\n', ...
        N_curr, aperture, theta_hat_curr, err_curr, Jmin_curr);
    
    plot(angles, J_norm_curr, 'LineWidth', 1.2, 'DisplayName', sprintf('N = %d, 孔径 = %.1f m', N_curr, aperture));
end
xline(theta0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
xlabel('角度/(°)'); ylabel('J(\theta)/||X||_F^2');
title('不同阵列孔径下的归一化残差曲线'); grid on; legend('Location','best');

%% ================= 问题 4：干扰源对估计结果的影响 =================
figure('Color','w'); hold on;
fprintf('\n=== 问题 4 干扰源影响估计结果 ===\n');
for k = 1:numel(sir_list)
    X_interf = x_interference{k}; 
    
    AHX_interf = A' * X_interf;
    norm_X2_interf = norm(X_interf, 'fro')^2;
    J_interf = norm_X2_interf - sum(abs(AHX_interf).^2, 2) / N;
    J_norm_interf = (J_interf / norm_X2_interf).';
    
    [Jmin_interf, idx_interf] = min(J_norm_interf);
    theta_hat_interf = angles(idx_interf);
    err_interf = abs(theta_hat_interf - theta0);
    
    fprintf('SIR = %3d dB: 估计角度 = %6.2f°, 相对目标误差 = %5.2f°, Jmin/||X||^2 = %.4f\n', ...
        sir_list(k), theta_hat_interf, err_interf, Jmin_interf);
    plot(angles, J_norm_interf, 'LineWidth', 1.2, 'DisplayName', sprintf('SIR = %d dB', sir_list(k)));
end
xline(theta0, 'r--', 'LineWidth', 1.5, 'DisplayName', '目标源 -30°');
xline(theta_i, 'k:', 'LineWidth', 1.5, 'DisplayName', '干扰源 20°');
xlabel('角度/(°)'); ylabel('J(\theta)/||X||_F^2');
title('含干扰源时的归一化残差曲线'); grid on; legend('Location','best');