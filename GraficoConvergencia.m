function [] = GraficoConvergencia(graficoConvergencia, metodo)

convergencia = figure;
hold on
grid on

% Coluna 1 - Itera��o XPF
% Coluna 2 - Itera��o P XFDPF
% Coluna 3 - Itera��o Q XFDPF
% Coluna 4 - �ngulo base
if metodo == 1
    plot(graficoConvergencia(:,4),graficoConvergencia(:,1),'k');    % Itera��o XPF
elseif metodo == 2
    plot(graficoConvergencia(:,4),graficoConvergencia(:,2),'r');    % Itera��o P XFDPF
    plot(graficoConvergencia(:,4),graficoConvergencia(:,3),'r-');   % Itera��o Q XFDPF
end
xlabel('Complex normalization base angle');
ylabel('Iterations');
legend('XPF','P\theta XFDPF', 'QV XFDPF');

end