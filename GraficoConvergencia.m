function [] = GraficoConvergencia(graficoConvergencia, metodo)

convergencia = figure;
hold on
grid on

% Coluna 1 - Iteração XPF
% Coluna 2 - Iteração P XFDPF
% Coluna 3 - Iteração Q XFDPF
% Coluna 4 - Ângulo base
if metodo == 1
    plot(graficoConvergencia(:,4),graficoConvergencia(:,1),'k');    % Iteração XPF
elseif metodo == 2
    plot(graficoConvergencia(:,4),graficoConvergencia(:,2),'r');    % Iteração P XFDPF
    plot(graficoConvergencia(:,4),graficoConvergencia(:,3),'r-');   % Iteração Q XFDPF
end
xlabel('Complex normalization base angle');
ylabel('Iterations');
legend('XPF','P\theta XFDPF', 'QV XFDPF');

end