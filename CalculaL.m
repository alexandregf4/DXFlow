function [L] = CalculaL(k, m, dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula L para duas barras dadas, k e m.
%%%% A equação de cálculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função ainda em fase de testes

%% Cálculo de L

L = 0;                                                              % Inicialização de L

if k == m                                                           % Cálculo de Lkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Definição do conjunto omegak (barras adjacentes à barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);    
    for x=1:length(omegak)
        % SOMATORIO Vm(Gkm*sin(thetakm) - Bkm*cos(thetakm))
        L = L + estadosRede.V(omegak(x)).*(dadosEntrada.G(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))) - dadosEntrada.B(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    L = -2.*estadosRede.V(k).*dadosEntrada.B(k,k) + L;                                       % Soma da parcela independente ao somatório da equação
    
else                                                                % Cálculo de Lkm
    % Vk*(Gkm*sin(thetakm) - Bkm*cos(thetakm))
    L = estadosRede.V(k).*(dadosEntrada.G(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)) - dadosEntrada.B(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)));
end
end