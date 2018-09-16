function [vetor_resultado] = SomaNaN(vetor1, vetor2)
%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Função que soma dois vetores elemento a elemento levando em
%%%% consideração elementos NaN.
%%%% Apenas a soma NaN + NaN = NaN é considerada. NaN + número é
%%%% considerado erro.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 02/08/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Soma dos vetores considerando elementos NaN

if size(vetor1,1) ~= size(vetor2,1)                             % Erro se os tamanhos dos vetores forem diferentes
    error('Os tamanhos dos vetores são diferentes!\n\n');
end

if size(vetor1,2) ~= 1 || size(vetor2,2) ~= 1                   % Erro se os dados não forem vetores
    error('Os dados de entrada possuem mais de uma coluna! Apenas vetores com uma coluna são processados.\n\n');
end

for k=1:length(vetor1)                                          % Laço para soma dos vetores considerando elementos NaN
   if isnan(vetor1(k,1)) == 1 && isnan(vetor2(k,1)) == 1        % Se ambos os elementos são NaN
       vetor_resultado(k,1) = NaN;                                  % Resultado é NaN
   elseif isnan(vetor1(k,1)) == 0 && isnan(vetor2(k,1)) == 0    % Se ambos os elementos não são NaN
       vetor_resultado(k,1) = vetor1(k,1) + vetor2(k,1);            % Resultado é vetor1+vetor2
   elseif isnan(vetor1(k,1)) == 1 && isnan(vetor2(k,1)) == 0    % Se apenas o elemento do vetor 1 é NaN
       vetor_resultado(k,1) = vetor2(k,1);                          % Resultado é vetor2
   elseif isnan(vetor1(k,1)) == 0 && isnan(vetor2(k,1)) == 1    % Se apenas o elemento do vetor 2 é NaN
       vetor_resultado(k,1) = vetor1(k,1);                          % Resultado é vetor1
   end
end