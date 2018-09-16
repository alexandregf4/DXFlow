function [P] = CalculaP(opcaoDesacoplado, l, c, dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula O para a linha (l) e coluna (c) correspondente da
%%%% Jacopbiana.
%%%% Para que esta função funcione corretamente, é necessário entrar os
%%%% índices l e c apenas para os mismatches dos ramos chaveáveis e estados
%%%% dos ramos chaveáveis. O tratamento deve ser feito externamente à
%%%% função.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 16/05/2015
%%%% v2 - 21/06/2015 / Modificado para o desacoplado rápido
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Processamento dos índices de barra e linha

%%%% ÍNDICES DE LINHA
%%%% Se a função for utilizada no método desacoplado
if ~isempty(opcaoDesacoplado)
    
    if l <= dadosEntrada.npq+dadosEntrada.npqv                                                                                % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_linha_chaveavel_mismatches = l - (dadosEntrada.npq + dadosEntrada.npqv);
    end
    
%%%% Se a função for utilizada no método convencional
else
    
    if l <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                        % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_mismatches = l - (2.*dadosEntrada.npq + 2.*dadosEntrada.npqv + dadosEntrada.npv);
    end
    
    indice_linha_chaveavel_mismatches = (indice_mismatches)./2;                                     % Transformação do índice do vetor de mismatches para o índice das linhas chaveáveis
end

%%%% ÍNDICES DE COLUNA
%%%% Se a função for utilizada no método desacoplado
if ~isempty(opcaoDesacoplado)

    if c <= dadosEntrada.npq+dadosEntrada.npqv                                                                                % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_linha_chaveavel_xvar = c - (dadosEntrada.npq + dadosEntrada.npqv);
    end

else
    
    if c <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                        % Erro se o índice do vetor de estados não estiver as variáveis de estado dos ramos chaveáveis
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = c - (2.*dadosEntrada.npq + 2.*dadosEntrada.npqv + dadosEntrada.npv);
        indice_linha_chaveavel_xvar = (indice_xvar)./2;                                             % Transformação do índice do vetor xvar para o índice das linhas chaveáveis
    end
end

linha_utilizada_mismatch = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel_mismatches,1));          % Linha chaveável utilizada nos mismatches
linha_utilizada_xvar = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel_xvar,1));                    % Linha chaveável utilizada para o vetor de estados

%% Calculo de P

if dadosEntrada.statusChaves(indice_linha_chaveavel_mismatches) == 0                                         % Se chave fechada (P apenas se aplica para chaves fechadas)
    if linha_utilizada_xvar == linha_utilizada_mismatch                                             % Se a barra utilizada é igual a barra DE da linha utilizada
        P = 1;
    else                                                                                            % Se a barra utilizada não é nem igual a barra DE nem a barra PARA da linha utilizada
        P = 0;
    end
else                                                                                            % Se chave fechada
    P = 0;
end
end