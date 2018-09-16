function [D] = CalculaD(opcaoDesacoplado, l, c, barrasDeltaPQ, dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula D para a linha (l) e coluna (c) correspondente da
%%%% Jacopbiana.
%%%% Para que esta função funcione corretamente, é necessário entrar os
%%%% índices l e c apenas para os mismatches dos ramos chaveáveis e estados
%%%% dos ângulos das barras. O tratamento deve ser feito externamente à
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
        indice_linha_chaveavel = l - (dadosEntrada.npq + dadosEntrada.npqv);
    end
    
%%%% Se a função for utilizada no método convencional
else
    
    if l <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                        % Erro se o índice do mismatch nao estiver entre os mismatches chaveáveis
        error('Erro! Índice l não pertence ao intervalo adequado dos mismatches!');
    else
        indice_mismatches = l - (2*dadosEntrada.npq+dadosEntrada.npv+2*dadosEntrada.npqv);
        indice_linha_chaveavel = (indice_mismatches)./2;                                            % Transformação do índice do vetor de mismatches para o índice das linhas chaveáveis
    end
end

%%%% ÍNDICES DE COLUNA
%%%% Se a função for utilizada no método desacoplado
if ~isempty(opcaoDesacoplado)
    
    if c > dadosEntrada.npq+dadosEntrada.npqv                                                                            % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = barrasDeltaPQ(c,1);
    end
    
%%%% Se a função for utilizada no método convencional
else
    
    if c > 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                                         % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = barrasDeltaPQ(c,1);
    end
end

linha_utilizada = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel,1));                              % Linha chaveável utilizada
barra_utilizada = dadosEntrada.barras(indice_xvar);                                                              % Barra utilizada

%% Calculo de D

if dadosEntrada.statusChaves(indice_linha_chaveavel) == 1                                % Se chave aberta (D apenas se aplica para chaves abertas)
    if barra_utilizada == dadosEntrada.de(linha_utilizada)                                   % Se a barra utilizada é igual a barra DE da linha utilizada
        D = 1;
    elseif barra_utilizada == dadosEntrada.para(linha_utilizada)                             % Se a barra utilizada é igual a barra PARA da linha utilizada
        D = -1;                                                             
    else                                                                        % Se a barra utilizada não é nem igual a barra DE nem a barra PARA da linha utilizada
        D = 0;
    end
else                                                                        % Se chave fechada
    D = 0;
end
end