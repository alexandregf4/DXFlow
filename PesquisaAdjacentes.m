function [linhasAdjacentes, barrasAdjacentes] = PesquisaAdjacentes(barraInteresse, dadosEntrada)

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o testada

%% Pesquisa das barras adjacentes � barra de interesse

temp1 = find(dadosEntrada.A(barraInteresse,:)~=0);          % Vetor com os �ndices das linhas adjacentes � barra de interesse
A_temp = dadosEntrada.A(:,temp1);                           % Colunas da matriz de incid�ncia mantendo apenas as linhas adjacentes � barra de interesse
linhasAdjacentes = dadosEntrada.linhas(temp1,1);            % Vetor com a numera��o das linhas adjacentes � barra de interesse

barrasAdjacentes = zeros(length(linhasAdjacentes),1);       % Inicializa��o com zeros do vetor com a numera��o de barras adjacentes � barra de interesse

for k=1:size(A_temp,2)                                      % La�o para procura das barras adjacentes � barra de interesse
    temp2 = find(A_temp(:,k)~=0);                           % Vetor com uma barra adjacente mais a barra de interesse
    temp2(temp2==barraInteresse) = [];                      % Retirada da barra de interesse do vetor temp2
    barrasAdjacentes(k,1) = dadosEntrada.barras(temp2,1);   % Grava��o da barra adjacente encontrada ao vetor de barras adjacentes (�mega k)
end

barrasAdjacentes = sort(barrasAdjacentes);                  % Organiza��o crescente do vetor de barras adjacentes � barra de interesse

end