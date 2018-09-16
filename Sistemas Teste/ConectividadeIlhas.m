function [barrasIlha, linhasIlha] = ConectividadeIlhas(barraInteresse, Amod, dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Dada a matriz incid�ncia e uma barra qualquer (verifica��o dos piv�s
%%%% nulos), esta fun��o devolve todas as barras pertencentes � ilha na
%%%% qual a barra de entrada est�.
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
barraEmAnalise = barraInteresse;                                                        % Vari�vel que identifica a barra em an�lise nesta itera��o do algoritmo
barrasAnalisadas = barraInteresse;                                                      % Vetor que grava as barras analisadas na itera��o corrente e nas anteriores
linhasAnalisadas = [];                                                                  % Vetor que grava as linhas analisadas

[barrasAnalisadas, linhasAnalisadas] = AlgoritmoBuscaIlha(pontas, Amod, barraEmAnalise, barrasAnalisadas, linhasAnalisadas, dadosEntrada);

barrasIlha = unique(sort(barrasAnalisadas));
linhasIlha = unique(sort(linhasAnalisadas));                                            % GAMBIARRA - Quando h� trechos em malha, a fun��o retorna numeros repetidos

[tempLinhasIlha] = ReconstroiLinhasIlha(barrasIlha, dadosEntrada);
linhasIlha = [linhasIlha; tempLinhasIlha];
linhasIlha = unique(sort(linhasIlha));