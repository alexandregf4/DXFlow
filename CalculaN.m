function [N] = CalculaN(k, m, dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula N para duas barras dadas, k e m.
%%%% A equação de cálculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função ainda em fase de testes

%% Cálculo de N

N = 0;                                                              % Inicialização de N

if k == m                                                           % Cálculo de Nkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Definição do conjunto omegak (barras adjacentes à barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);    
    for x=1:length(omegak)
        % SOMATORIO Vm(Gkm*cos(thetakm) + Bkm*sin(thetakm))
        N = N + estadosRede.V(omegak(x)).*(dadosEntrada.G(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))) + dadosEntrada.B(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    N = 2.*estadosRede.V(k).*dadosEntrada.G(k,k) + N;                                        % Soma da parcela independente ao somatório da equação
    
else                                                                % Cálculo de Nkm
    % Vk*(Gkm*cos(thetakm) + Bkm*sin(thetakm))
    N = estadosRede.V(k).*(dadosEntrada.G(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)) + dadosEntrada.B(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)));
end
end