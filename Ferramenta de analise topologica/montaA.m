function [A] = montaA(dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta fun��o monta a matriz de incid�ncia barra-ramo a partir dos dados
%%%% de DE-PARA do sistema el�trico em estudo.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Montagem da matriz A

A = zeros(dadosEntrada.nb,dadosEntrada.nl);

for k=1:length(dadosEntrada.linhas)
    A(dadosEntrada.de(k),dadosEntrada.linhas(k)) = 1;
    A(dadosEntrada.para(k),dadosEntrada.linhas(k)) = -1;
end
end