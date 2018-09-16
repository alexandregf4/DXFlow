function [linhasAdjacentes, barrasAdjacentes] = PesquisaAdjacentes(barraInteresse, dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função retorna a numeração das barras e linhas adjacentes à 
%%%% barra de interesse.
%%%% Esta função é interessante para a montagem da matriz Y e para o
%%%% cálculo de Pcalc e Qcalc.
%%%% A barra de interesse é a barra "k" da formulação. A função procura
%%%% as barras "m" adjacentes, montando o conjunto ômega k.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 06/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função testada

%% Pesquisa das barras adjacentes à barra de interesse

temp1 = find(dadosEntrada.A(barraInteresse,:)~=0);          % Vetor com os índices das linhas adjacentes à barra de interesse
A_temp = dadosEntrada.A(:,temp1);                           % Colunas da matriz de incidência mantendo apenas as linhas adjacentes à barra de interesse
linhasAdjacentes = dadosEntrada.linhas(temp1,1);            % Vetor com a numeração das linhas adjacentes à barra de interesse

barrasAdjacentes = zeros(length(linhasAdjacentes),1);       % Inicialização com zeros do vetor com a numeração de barras adjacentes à barra de interesse

for k=1:size(A_temp,2)                                      % Laço para procura das barras adjacentes à barra de interesse
    temp2 = find(A_temp(:,k)~=0);                           % Vetor com uma barra adjacente mais a barra de interesse
    temp2(temp2==barraInteresse) = [];                      % Retirada da barra de interesse do vetor temp2
    barrasAdjacentes(k,1) = dadosEntrada.barras(temp2,1);   % Gravação da barra adjacente encontrada ao vetor de barras adjacentes (ômega k)
end

barrasAdjacentes = sort(barrasAdjacentes);                  % Organização crescente do vetor de barras adjacentes à barra de interesse

end