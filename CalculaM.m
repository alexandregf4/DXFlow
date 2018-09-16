function [M] = CalculaM(k, m, dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula M para duas barras dadas, k e m.
%%%% A equação de cálculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%% v2 - 20/09/2014 / Adição de phikm como forma de generalizar o
%%%% equacionamento da derivada
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função ainda em fase de testes

%% Cálculo de M

M = 0;                                                              % Inicialização de M

if k == m                                                           % Cálculo de Mkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Definição do conjunto omegak (barras adjacentes à barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);    
    for x=1:length(omegak)
        % SOMATORIO Vm(Gkm*cos(thetakm) + Bkm*sin(thetakm))
        M = M + estadosRede.V(omegak(x)).*(dadosEntrada.G(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))) + dadosEntrada.B(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    M = estadosRede.V(k).*M;                                                    % Multiplicação do somatório por Vk
    
else                                                                % Cálculo de Mkm
    % -Vk*Vm*(Gkm*cos(thetakm) + Bkm*sin(thetakm))
    M = -estadosRede.V(k).*estadosRede.V(m).*(dadosEntrada.G(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)) + dadosEntrada.B(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)));
end
end