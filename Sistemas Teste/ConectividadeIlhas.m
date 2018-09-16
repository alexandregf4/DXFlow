function [barrasIlha, linhasIlha] = ConectividadeIlhas(barraInteresse, Amod, dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Dada a matriz incidência e uma barra qualquer (verificação dos pivôs
%%%% nulos), esta função devolve todas as barras pertencentes à ilha na
%%%% qual a barra de entrada está.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 08/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Encontrando as pontas de cada ilha
contadorLinhaPontas = 1;
pontas = [];

for k=1:size(Amod,1)
   if length(find(Amod(k,:) ~= 0)) == 1
       pontas(contadorLinhaPontas,1) = k;
       contadorLinhaPontas = contadorLinhaPontas + 1;
   end
end

%% Algoritmo de busca pelas barras da ilha
barraEmAnalise = barraInteresse;                                                        % Variável que identifica a barra em análise nesta iteração do algoritmo
barrasAnalisadas = barraInteresse;                                                      % Vetor que grava as barras analisadas na iteração corrente e nas anteriores
linhasAnalisadas = [];                                                                  % Vetor que grava as linhas analisadas

[barrasAnalisadas, linhasAnalisadas] = AlgoritmoBuscaIlha(pontas, Amod, barraEmAnalise, barrasAnalisadas, linhasAnalisadas, dadosEntrada);

barrasIlha = unique(sort(barrasAnalisadas));
linhasIlha = unique(sort(linhasAnalisadas));                                            % GAMBIARRA - Quando há trechos em malha, a função retorna numeros repetidos

[tempLinhasIlha] = ReconstroiLinhasIlha(barrasIlha, dadosEntrada);
linhasIlha = [linhasIlha; tempLinhasIlha];
linhasIlha = unique(sort(linhasIlha));