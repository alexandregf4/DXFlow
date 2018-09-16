function [D] = CalculaD(opcaoDesacoplado, l, c, barrasDeltaPQ, dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula D para a linha (l) e coluna (c) correspondente da
%%%% Jacopbiana.
%%%% Para que esta fun��o funcione corretamente, � necess�rio entrar os
%%%% �ndices l e c apenas para os mismatches dos ramos chave�veis e estados
%%%% dos �ngulos das barras. O tratamento deve ser feito externamente �
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
        indice_linha_chaveavel = l - (dadosEntrada.npq + dadosEntrada.npqv);
    end
    
%%%% Se a fun��o for utilizada no m�todo convencional
else
    
    if l <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                        % Erro se o �ndice do mismatch nao estiver entre os mismatches chave�veis
        error('Erro! �ndice l n�o pertence ao intervalo adequado dos mismatches!');
    else
        indice_mismatches = l - (2*dadosEntrada.npq+dadosEntrada.npv+2*dadosEntrada.npqv);
        indice_linha_chaveavel = (indice_mismatches)./2;                                            % Transforma��o do �ndice do vetor de mismatches para o �ndice das linhas chave�veis
    end
end

%%%% �NDICES DE COLUNA
%%%% Se a fun��o for utilizada no m�todo desacoplado
if ~isempty(opcaoDesacoplado)
    
    if c > dadosEntrada.npq+dadosEntrada.npqv                                                                            % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = barrasDeltaPQ(c,1);
    end
    
%%%% Se a fun��o for utilizada no m�todo convencional
else
    
    if c > 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                         % Erro se o �ndice do vetor de estados n�o estiver entre as vari�veis convencionais
        error('Erro! �ndice c n�o pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = barrasDeltaPQ(c,1);
    end
end

linha_utilizada = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel,1));                              % Linha chave�vel utilizada
barra_utilizada = dadosEntrada.barras(indice_xvar);                                                              % Barra utilizada

%% Calculo de D

if dadosEntrada.statusChaves(indice_linha_chaveavel) == 1                                % Se chave aberta (D apenas se aplica para chaves abertas)
    if barra_utilizada == dadosEntrada.de(linha_utilizada)                                   % Se a barra utilizada � igual a barra DE da linha utilizada
        D = 1;
    elseif barra_utilizada == dadosEntrada.para(linha_utilizada)                             % Se a barra utilizada � igual a barra PARA da linha utilizada
        D = -1;                                                             
    else                                                                        % Se a barra utilizada n�o � nem igual a barra DE nem a barra PARA da linha utilizada
        D = 0;
    end
else                                                                        % Se chave fechada
    D = 0;
end
end