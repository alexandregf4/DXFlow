function [celulaSaida] = RetiraDuplicatas(celulaEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta função retira possíveis duplicatas dos vetores barrasIlha e
%%%% linhasIlha.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 28/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Desenvolvimento

contadorSaida = 1;
celulaSaida = [];
flagVetoresIguais = false;

for k=1:length(celulaEntrada)
    if k==1
        celulaSaida{contadorSaida,1} = celulaEntrada{k,1};
        contadorSaida = contadorSaida + 1;
    end
    
    for l=1:(contadorSaida - 1)
        if isequal(celulaSaida{l,1},celulaEntrada{k,1})
            flagVetoresIguais = true;
        end
    end
    
    if ~flagVetoresIguais
       celulaSaida{contadorSaida,1} = celulaEntrada{k,1};
       contadorSaida = contadorSaida + 1;
    end
    flagVetoresIguais = false;
end