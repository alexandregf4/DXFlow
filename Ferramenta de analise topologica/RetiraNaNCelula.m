function [celulaSaida] = RetiraNaNCelula(celulaEntrada)
%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Função que transforma o NaN de uma célula em espaço vazio []
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 28/06/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Laço para substituição dos valores NaN por []

for l=1:size(celulaEntrada,1)
    for c=1:size(celulaEntrada,2)
        if isnan(celulaEntrada{l,c})
            celulaSaida{l,c} = [];
        else
            celulaSaida{l,c} = celulaEntrada{l,c};
        end
    end
end
end