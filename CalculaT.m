function [T] = CalculaT(opcaoDesacoplado, l, c, dadosEntrada, barrasDeltaPQ)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula T para a linha (l) e coluna (c) correspondente da
%%%% Jacopbiana.
%%%% Para que esta função funcione corretamente, é necessário entrar os
%%%% índices l e c apenas para os mismatches convencionais e estados
%%%% dos ramos chaveáveis. O tratamento deve ser feito externamente à
%%%% função.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 16/05/2015
%%%% v2 - 21/06/2015 / Modificado para o método desacoplado rápido
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Processamento dos índices de barra e linha

%%%% Se a função for utilizada no método desacoplado
if ~isempty(opcaoDesacoplado)
    
    if c <= dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.npv                                                        % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_linha_chaveavel = c - (dadosEntrada.npq + dadosEntrada.npqv+ dadosEntrada.npv);
    end
    
%%%% Se a função for utilizada no método convencional
else
    
    if c <= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                                    % Erro se o índice do vetor de estados não estiver entre as variáveis convencionais
        error('Erro! Índice c não pertence ao intervalo adequado do vetor de estados!');
    else
        indice_xvar = c - (2.*dadosEntrada.npq + 2.*dadosEntrada.npqv + dadosEntrada.npv);
    end
    
    indice_linha_chaveavel = (indice_xvar + 1)./2;                              % Transformação do índice do vetor de mismatches para o índice das linhas chaveáveis
end

linha_utilizada = dadosEntrada.linhas(dadosEntrada.linhasChaveaveis(indice_linha_chaveavel,1));          % Linha chaveável utilizada (estados)

%% Calculo de T

% Pk = Pkm + tkl = Pkm - tlk
% onde m E omega_k
%      l E tau_k

if dadosEntrada.de(linha_utilizada,1) == barrasDeltaPQ(l,1);                           % Se k = de -> tkl
    T = 1;
elseif dadosEntrada.para(linha_utilizada,1) == barrasDeltaPQ(l,1);                     % Se k = para -> tlk
    T = -1;
else                                                                        % Se k ~= de ou para
    T = 0;
end
end