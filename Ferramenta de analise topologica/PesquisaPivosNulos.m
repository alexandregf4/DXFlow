function [pivosNulos] = PesquisaPivosNulos(A)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta fun��o pesquisa poss�veis piv�s nulos pela an�lise direta da
%%%% matriz incid�ncia barra-ramo (A), sem a necessidade de se calcular os
%%%% piv�s nulos da matriz ganho (G) por fatora��o LU.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 28/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pesquisa dos piv�s nulos

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