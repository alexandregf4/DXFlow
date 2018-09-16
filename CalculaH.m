function [H] = CalculaH(k, m, dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula H para duas barras dadas, k e m.
%%%% A equação de cálculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função ainda em fase de testes

%% Cálculo de H

H = 0;                                                              % Inicialização de H

if k == m                                                           % Cálculo de Hkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Definição do conjunto omegak (barras adjacentes à barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);
    for x=1:length(omegak)
        % SOMATORIO Vm(-Gkm*sin(thetakm) + Bkm*cos(thetakm))
        H = H + estadosRede.V(omegak(x)).*(-dadosEntrada.G(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))) + dadosEntrada.B(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    H = estadosRede.V(k).*H;                                        % Multiplicação do somatório por Vk
    
else                                                                % Cálculo de Hkm
    % Vk*Vm*(Gkm*sin(thetakm) - Bkm*cos(thetakm))
    H = estadosRede.V(k).*estadosRede.V(m).*(dadosEntrada.G(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)) - dadosEntrada.B(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)));
end
end