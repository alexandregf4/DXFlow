function [linhasAdjacentes, barrasAdjacentes] = ConjuntoOmegaK(barraInteresse, dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o retorna a numera��o das barras e linhas adjacentes � 
%%%% barra de interesse.
%%%% Esta fun��o � interessante para a montagem da matriz Y e para o
%%%% c�lculo de Pcalc e Qcalc.
%%%% A barra de interesse � a barra "k" da formula��o. A fun��o procura
%%%% as barras "m" adjacentes, montando o conjunto �mega k.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 06/07/2014
%%%% v2 - 09/05/2015 / Retirada dos ramos chave�veis para N�vel de Se��o de
%%%% Barras
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o testada

%% Pesquisa das barras adjacentes � barra de interesse

temp1 = find(dadosEntrada.A(barraInteresse,:)~=0);          % Vetor com os �ndices das linhas adjacentes � barra de interesse
tempA = dadosEntrada.A(:,temp1);                            % Colunas da matriz de incid�ncia mantendo apenas as linhas adjacentes � barra de interesse
linhasAdjacentes = dadosEntrada.linhas(temp1,1);            % Vetor com a numera��o das linhas adjacentes � barra de interesse

for k=1:length(dadosEntrada.linhasChaveaveis)
    linhasAdjacentes(linhasAdjacentes == dadosEntrada.linhasChaveaveis(k)) = [];    % Retirada dos ramos chave�veis do vetor de linhas adjacentes
end
          
barrasAdjacentes = zeros(length(linhasAdjacentes),1);       % Inicializa��o com zeros do vetor com a numera��o de barras adjacentes � barra de interesse

for k=1:size(tempA,2)                                       % La�o para procura das barras adjacentes � barra de interesse
    temp2 = find(tempA(:,k)~=0);                            % Vetor com uma barra adjacente mais a barra de interesse
    temp2(temp2==barraInteresse) = [];                      % Retirada da barra de interesse do vetor temp2
    barrasAdjacentes(k,1) = dadosEntrada.barras(temp2,1);   % Grava��o da barra adjacente encontrada ao vetor de barras adjacentes (�mega k)
end

barrasAdjacentes = sort(barrasAdjacentes);                  % Organiza��o crescente do vetor de barras adjacentes � barra de interesse

% La�o para retirar as barras adjacentes que pertencem a um ramo chave�vel
for l=1:length(dadosEntrada.linhasChaveaveis)
    if barraInteresse == dadosEntrada.de(dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(l)))
        barrasAdjacentes(barrasAdjacentes == dadosEntrada.para(dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(l)))) = [];
    elseif barraInteresse == dadosEntrada.para(dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(l)))
        barrasAdjacentes(barrasAdjacentes == dadosEntrada.de(dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(l)))) = [];
    end
end
end