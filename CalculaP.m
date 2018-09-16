function [P] = CalculaP(opcaoDesacoplado, l, c, dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula O para a linha (l) e coluna (c) correspondente da
%%%% Jacopbiana.
%%%% Para que esta fun��o funcione corretamente, � necess�rio entrar os
%%%% �ndices l e c apenas para os mismatches dos ramos chave�veis e estados
%%%% dos ramos chave�veis. O tratamento deve ser feito externamente �
%%%% fun��o.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 16/05/2015
%%%% v2 - 21/06/2015 / Modificado para o desacoplado r�pido
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Processamento dos �ndices de barra e linha

%%%% �NDICES DE LINHA
%%%% Se a fun��o for utilizada no m�todo desacoplado
if ~isempty(opcaoDesacoplado)
    
    if l <= dadosEntrada.npq+dadosEntrada.npqv                                                                                % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_linha_chaveavel_mismatches = l - (dadosEntrada.npq + dadosEntrada.npqv);
    end
    
%%%% Se a fun��o for utilizada no m�todo convencional
else
    
    if l <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                        % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_mismatches = l - (2.*dadosEntrada.npq + 2.*dadosEntrada.npqv + dadosEntrada.npv);
    end
    
    indice_linha_chaveavel_mismatches = (indice_mismatches)./2;                                     % Transforma��o do �ndice do vetor de mismatches para o �ndice das linhas chave�veis
end

%%%% �NDICES DE COLUNA
%%%% Se a fun��o for utilizada no m�todo desacoplado
if ~isempty(opcaoDesacoplado)

    if c <= dadosEntrada.npq+dadosEntrada.npqv                                                                                % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_linha_chaveavel_xvar = c - (dadosEntrada.npq + dadosEntrada.npqv);
    end

else
    
    if c <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                        % Erro se o �ndice do vetor de estados n�o estiver as vari�veis de estado dos ramos chave�veis
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = c - (2.*dadosEntrada.npq + 2.*dadosEntrada.npqv + dadosEntrada.npv);
        indice_linha_chaveavel_xvar = (indice_xvar)./2;                                             % Transforma��o do �ndice do vetor xvar para o �ndice das linhas chave�veis
    end
end

linha_utilizada_mismatch = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel_mismatches,1));          % Linha chave�vel utilizada nos mismatches
linha_utilizada_xvar = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel_xvar,1));                    % Linha chave�vel utilizada para o vetor de estados

%% Calculo de P

if dadosEntrada.statusChaves(indice_linha_chaveavel_mismatches) == 0                                         % Se chave fechada (P apenas se aplica para chaves fechadas)
    if linha_utilizada_xvar == linha_utilizada_mismatch                                             % Se a barra utilizada � igual a barra DE da linha utilizada
        P = 1;
    else                                                                                            % Se a barra utilizada n�o � nem igual a barra DE nem a barra PARA da linha utilizada
        P = 0;
    end
else                                                                                            % Se chave fechada
    P = 0;
end
end