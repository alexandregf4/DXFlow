function [barrasAnalisadas, linhasAnalisadas] = AlgoritmoBuscaIlha(pontas, Amod, barraEmAnalise, barrasAnalisadas, linhasAnalisadas, dadosEntrada)
     
%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Este algoritmo busca todas as barras conectadas à barra em análise,
%%%% gravando o número de todas as barras e linhas conectadas.
%%%% A função é chamada de forma recursiva para que todas as barras de uma
%%%% ilha sejam descobertas e listadas.
%%%%
%%%%
%%%% v1 - 08/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Linhas conectadas à barra analisada
linhasConectadas = dadosEntrada.linhas(find(Amod(barraEmAnalise,:) ~= 0));

%%%% Retirada das linhas conectadas iguais às linhas já analisadas
if ~isempty(linhasAnalisadas)
    [linhasConectadas] = DeletaBarrasAnalisadas(linhasConectadas, linhasAnalisadas);    
end

%%%% Para cada linha conectada à barra analisada...
for k=1:length(linhasConectadas)
    barrasConectadas = find(Amod(:,linhasConectadas(k,1)) ~= 0);                        % Barras conectadas à linha em análise

    [barrasConectadas] = DeletaBarrasAnalisadas(barrasConectadas, barrasAnalisadas);    % Retirada das barras conectadas que já foram analisadas anteriormente
    
    linhasAnalisadas(length(linhasAnalisadas)+1,1) = linhasConectadas(k,1);             % Vetor que grava as linhas analisadas
    
    %%%% Se ainda há barras que não foram analisadas...
    if ~isempty(barrasConectadas)
        for l=1:length(barrasConectadas)
            barraEmAnalise = barrasConectadas(l,1);
            
            %%%% Se a nova barra em análise é uma das pontas...
            if any(find(pontas == barraEmAnalise))
                %%%% Gravar a barra em análise e ir para a próxima barra conectada
                barrasAnalisadas(length(barrasAnalisadas)+1,1) = barraEmAnalise;
            else
                barrasAnalisadas(length(barrasAnalisadas)+1,1) = barraEmAnalise;
                [barrasAnalisadas, linhasAnalisadas] = AlgoritmoBuscaIlha(pontas, Amod, barraEmAnalise, barrasAnalisadas, linhasAnalisadas, dadosEntrada);
            end
        end
    end
end
end        