function [barrasAnalisadas, linhasAnalisadas] = AlgoritmoBuscaIlha(pontas, Amod, barraEmAnalise, barrasAnalisadas, linhasAnalisadas, dadosEntrada)
     
%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Este algoritmo busca todas as barras conectadas � barra em an�lise,
%%%% gravando o n�mero de todas as barras e linhas conectadas.
%%%% A fun��o � chamada de forma recursiva para que todas as barras de uma
%%%% ilha sejam descobertas e listadas.
%%%%
%%%%
%%%% v1 - 08/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Linhas conectadas � barra analisada
linhasConectadas = dadosEntrada.linhas(find(Amod(barraEmAnalise,:) ~= 0));

%%%% Retirada das linhas conectadas iguais �s linhas j� analisadas
if ~isempty(linhasAnalisadas)
    [linhasConectadas] = DeletaBarrasAnalisadas(linhasConectadas, linhasAnalisadas);    
end

%%%% Para cada linha conectada � barra analisada...
for k=1:length(linhasConectadas)
    barrasConectadas = find(Amod(:,linhasConectadas(k,1)) ~= 0);                        % Barras conectadas � linha em an�lise

    [barrasConectadas] = DeletaBarrasAnalisadas(barrasConectadas, barrasAnalisadas);    % Retirada das barras conectadas que j� foram analisadas anteriormente
    
    linhasAnalisadas(length(linhasAnalisadas)+1,1) = linhasConectadas(k,1);             % Vetor que grava as linhas analisadas
    
    %%%% Se ainda h� barras que n�o foram analisadas...
    if ~isempty(barrasConectadas)
        for l=1:length(barrasConectadas)
            barraEmAnalise = barrasConectadas(l,1);
            
            %%%% Se a nova barra em an�lise � uma das pontas...
            if any(find(pontas == barraEmAnalise))
                %%%% Gravar a barra em an�lise e ir para a pr�xima barra conectada
                barrasAnalisadas(length(barrasAnalisadas)+1,1) = barraEmAnalise;
            else
                barrasAnalisadas(length(barrasAnalisadas)+1,1) = barraEmAnalise;
                [barrasAnalisadas, linhasAnalisadas] = AlgoritmoBuscaIlha(pontas, Amod, barraEmAnalise, barrasAnalisadas, linhasAnalisadas, dadosEntrada);
            end
        end
    end
end
end        