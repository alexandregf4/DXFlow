function [vetor_resultado] = SomaNaN(vetor1, vetor2)
%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Fun��o que soma dois vetores elemento a elemento levando em
%%%% considera��o elementos NaN.
%%%% Apenas a soma NaN + NaN = NaN � considerada. NaN + n�mero �
%%%% considerado erro.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 02/08/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Soma dos vetores considerando elementos NaN

if size(vetor1,1) ~= size(vetor2,1)                             % Erro se os tamanhos dos vetores forem diferentes
    error('Os tamanhos dos vetores s�o diferentes!\n\n');
end

if size(vetor1,2) ~= 1 || size(vetor2,2) ~= 1                   % Erro se os dados n�o forem vetores
    error('Os dados de entrada possuem mais de uma coluna! Apenas vetores com uma coluna s�o processados.\n\n');
end

for k=1:length(vetor1)                                          % La�o para soma dos vetores considerando elementos NaN
   if isnan(vetor1(k,1)) == 1 && isnan(vetor2(k,1)) == 1        % Se ambos os elementos s�o NaN
       vetor_resultado(k,1) = NaN;                                  % Resultado � NaN
   elseif isnan(vetor1(k,1)) == 0 && isnan(vetor2(k,1)) == 0    % Se ambos os elementos n�o s�o NaN
       vetor_resultado(k,1) = vetor1(k,1) + vetor2(k,1);            % Resultado � vetor1+vetor2
   elseif isnan(vetor1(k,1)) == 1 && isnan(vetor2(k,1)) == 0    % Se apenas o elemento do vetor 1 � NaN
       vetor_resultado(k,1) = vetor2(k,1);                          % Resultado � vetor2
   elseif isnan(vetor1(k,1)) == 0 && isnan(vetor2(k,1)) == 1    % Se apenas o elemento do vetor 2 � NaN
       vetor_resultado(k,1) = vetor1(k,1);                          % Resultado � vetor1
   end
end