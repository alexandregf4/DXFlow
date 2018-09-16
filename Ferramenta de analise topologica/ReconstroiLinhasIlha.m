function [vetorLinhasIlha] = ReconstroiLinhasIlha(vetorBarrasIlha, dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% A partir das barras encontradas para uma ilha, esta função encontra
%%%% suas respectivas linhas. Lembrando que as linhas chaveáveis abertas
%%%% que fazem fronteira com outras ilhas não são contabilizadas.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 28/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Reconstrução das linhas chaveáveis

contador = 1;

for k=1:length(vetorBarrasIlha)                                                                             % Combina uma barra do vetorBarrasIlha...
    for l=1:length(vetorBarrasIlha)                                                                         % Com outra barra do mesmo vetor...
        for m=1:dadosEntrada.nl                                                                             % Para pesquisar se há algum de-para correspondente
            if vetorBarrasIlha(k,1) ~= vetorBarrasIlha(l,1)                                                 % Se as duas barras analisadas NÃO são iguais
                if (vetorBarrasIlha(k,1) == dadosEntrada.de(m,1) && vetorBarrasIlha(l,1) == dadosEntrada.para(m,1)) || (vetorBarrasIlha(k,1) == dadosEntrada.para(m,1) && vetorBarrasIlha(l,1) == dadosEntrada.de(m,1))
                    vetorLinhasIlha(contador,1) = m;
                    contador = contador + 1;
                end
            end
        end
    end
end
vetorLinhasIlha = unique(sort(vetorLinhasIlha));
end