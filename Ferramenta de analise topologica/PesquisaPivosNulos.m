function [pivosNulos] = PesquisaPivosNulos(A)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta função pesquisa possíveis pivôs nulos pela análise direta da
%%%% matriz incidência barra-ramo (A), sem a necessidade de se calcular os
%%%% pivôs nulos da matriz ganho (G) por fatoração LU.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 28/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pesquisa dos pivôs nulos

contadorPivosNulos = 1;
pivosNulos = [];

for c=1:size(A,2)
    if c == 1
        pivosNulos(contadorPivosNulos,1) = find(A(:,c) == 1);
        contadorPivosNulos = contadorPivosNulos + 1;
    elseif c < size(A,2)
        if any(A(:,c)) ~= 0
        else
            pivosNulos(contadorPivosNulos,1) = find(A(:,c+1) == 1);
            contadorPivosNulos = contadorPivosNulos + 1;
        end
    end
end