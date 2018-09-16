function [U] = CalculaU(opcaoDesacoplado, l, c, dadosEntrada, barrasDeltaPQ)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula U para a linha (l) e coluna (c) correspondente da
%%%% Jacopbiana.
%%%% Para que esta fun��o funcione corretamente, � necess�rio entrar os
%%%% �ndices l e c apenas para os mismatches convencionais e estados
%%%% dos ramos chave�veis. O tratamento deve ser feito externamente �
%%%% fun��o.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 16/05/2015
%%%% v2 - 21/06/2015 / Modificado para o desacoplado r�pido
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Processamento dos �ndices de barra e linha

%%%% Se a fun��o for utilizada no m�todo desacoplado
if ~isempty(opcaoDesacoplado)
    
    if c <= dadosEntrada.npq+dadosEntrada.npqv                                                          % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_linha_chaveavel = c - (dadosEntrada.npq + dadosEntrada.npqv);
    end
    
%%%% Se a fun��o for utilizada no m�todo convencional
else
    
    if c <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                     % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = c - (2.*dadosEntrada.npq + 2.*dadosEntrada.npqv+ dadosEntrada.npv);
    end
    
    indice_linha_chaveavel = (indice_xvar)./2;                                                          % Transforma��o do �ndice do vetor de mismatches para o �ndice das linhas chave�veis
end

linha_utilizada = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel,1));         % Linha chave�vel utilizada (estados)

%% Calculo de U

% Qk = Qkm + ukl = Qkm - ulk
% onde m E omega_k
%      l E tau_k

if dadosEntrada.de(linha_utilizada,1) == barrasDeltaPQ(l,1);                            % Se k = de -> tkl
    U = 1;
elseif dadosEntrada.para(linha_utilizada,1) == barrasDeltaPQ(l,1);                      % Se k = para -> tlk
    U = -1;
else                                                                                    % Se k ~= de ou para
    U = 0;
end
end