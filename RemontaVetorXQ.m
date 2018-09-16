function [deltaV, deltaAkm, deltaUkm] = RemontaVetorXQ(dadosEntrada, variavelDeltaXQ, linhaAkm, barrasMismatchesQ, xQ)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o transforma o vetor xQ (delta) montado em blocos 
%%%% resultado da equa��o:
%%%%                           xQ = BQ^-1*mismatchesQ
%%%%
%%%%                            [delta_V1] (se for refer�ncia cai fora)
%%%%                            [delta_V2]
%%%%                            [delta_V3]
%%%%                            ..........
%%%%                            [delta_Vn]
%%%%                                e
%%%%                            [delta_akm]
%%%%                            [delta_akn]
%%%%                            ...........
%%%%                            [delta_akz]
%%%%                                  e
%%%%                            [delta_u12]
%%%%                            [delta_u56]
%%%%                            ........
%%%%                            [delta_ukm]
%%%%
%%%% nos vetores delta_theta com tamanho nb x 1, delta_akm com tamanho npqv
%%%% x 1 e delta_ukm com tamanho nrc x 1.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%% v2 - 20/06/2015 / Tratamento de ramos chave�veis adicionado
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Montagem dos vetores

if size(xQ,1) ~= dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.nrc                         % Erro se o vetor xP tiver um tamanho inconsistente    
    error('O tamanho do vetor de entrada xQ � diferente de npq+npqv.\n\n');
end

if size(xQ,2) ~= 1                                                                           % Erro se o dado de entrada n�o for vetor
    error('O dado de entrada possui mais de uma coluna!');
end

deltaV = zeros(dadosEntrada.nb,1);                                                           % Inicializa��o do vetor delta_V com tamanho nb
deltaAkm = zeros(dadosEntrada.nl,1);                                                         % Inicializa��o do vetor delta_akm com tamanho nl
deltaUkm = zeros(dadosEntrada.nl,1);                                                         % Inicializa��o do vetor delta_ukm com tamanho nrc

%%%% La�o para separa��o do vetor xQ em V e akm
for k=1:length(xQ)
    
    indiceU = k - dadosEntrada.npq+dadosEntrada.npqv;
    
    if strcmp(variavelDeltaXQ{k,1},'V')                                                     % Se nesta posi��o for V
        deltaV(barrasMismatchesQ(k)) = xQ(k);                                                   % Vetor delta_V recebe elemento do vetor dado de entrada
    elseif strcmp(variavelDeltaXQ{k,1},'a')                                                 % Se nesta posi��o for a
        for h=1:length(linhaAkm)                                                                % La�o para encontrar a linha do vetor akm correspondente ao para igual � barras_delta_PQ (barra do antigo vetor V na mesma posi��o)
            if para(linhaAkm(h)) == barrasMismatchesQ(k)
                break;
            end
        end
        deltaAkm(linhaAkm(h)) = xQ(k);                                                      % Vetor delta_akm recebe elemento do vetor dado de entrada
    elseif strcmp(variavelDeltaXQ{k,1},'u')                                                 % Se nesta posi��o for u
        deltaUkm(dadosEntrada.linhasChaveaveis(indiceU,1),1) = xQ(k);                       % Vetor delta_ukm recebe elemento do vetor dado de entrada
    else                                                                                    % Se n�o for nem theta, nem V, nem A, exibir erro
        error('Tipo inv�lido no vetor variavel_delta_x! Linha %d\n\n',k);
    end
end