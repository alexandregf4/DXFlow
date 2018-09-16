function [deltaTheta, deltaTkm] = RemontaVetorXP(dadosEntrada, variavelDeltaXP, barrasMismatchesP, XP)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função transforma o vetor xP (delta) montado em blocos 
%%%% resultado da equação:
%%%%                          xP = BP^-1*mismatchesP
%%%%
%%%%                                  em
%%%%
%%%%                            [delta_theta1] (se for referência cai fora)
%%%%                            [delta_theta2]
%%%%                            [delta_theta3]
%%%%                            ........
%%%%                            [delta_thetan]
%%%%                                  e
%%%%                            [delta_t12]
%%%%                            [delta_t56]
%%%%                            ........
%%%%                            [delta_tkm]
%%%%
%%%% no vetor delta_theta com tamanho nb x 1 e no vetor delta_tkm com
%%%% tamanho nrc x 1.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%% v2 - 20/06/2015 / Tratamento de ramos chaveáveis adicionado
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Montagem dos vetores

if size(XP,1) ~= dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.npv+dadosEntrada.nrc           % Erro se o vetor xP tiver um tamanho inconsistente        
    error('O tamanho do vetor de entrada xP é diferente de npq+npqv+npv.\n\n');
end

if size(XP,2) ~= 1
    error('O dado de entrada possui mais de uma coluna!');
end

deltaTheta = zeros(dadosEntrada.nb,1);                                                          % Inicialização do vetor delta_theta com tamanho nb
deltaTkm = zeros(dadosEntrada.nl,1);                                                            % Inicialização do vetor delta_tkm com tamanho nrc

%%%% Laço para separação do vetor xP em theta
for k=1:length(XP)                                                                              % Laço para construção do vetor delta_theta
    
    indiceT = k - (dadosEntrada.npq + dadosEntrada.npqv + dadosEntrada.npv);
    
    if strcmp(variavelDeltaXP{k,1},'O')                                                         % Se nesta posição for theta
        deltaTheta(barrasMismatchesP(k)) = XP(k);                                                   % Vetor delta_theta recebe elemento do vetor dado de entrada
    elseif strcmp(variavelDeltaXP{k,1},'t')                                                     % Se nesta posição for t
        deltaTkm(dadosEntrada.linhasChaveaveis(indiceT,1),1) = XP(k);                               % Vetor delta_tkm recebe elemento do vetor dado de entrada
    else                                                                                        % Se não for theta nem t, exibir erro
        error('Tipo inválido no vetor variavel_delta_xP! Linha %d\n\n',k);
    end
end