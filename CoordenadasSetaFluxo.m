function [xA, xB, xC, yA, yB, yC] = CoordenadasSetaFluxo(altura, largura, x1, x2, y1, y2, sentido)

%% Ponto m�dio do segmento

xMed = (x1+x2)/2;
yMed = (y1+y2)/2;

%% C�lculo do ponto A do tri�ngulo (base)

xA = xMed;
yA = yMed;

%% C�lculo do ponto C do tri�ngulo (ponta da seta)

alpha = atan((y2-y1)/(x2-x1));          % �ngulo derivado do coeficiente angular da reta "m"
xCorrAltura = altura*cos(alpha);        % Comprimento X de corre��o da altura
yCorrAltura = altura*sin(alpha);        % Comprimento Y de corre��o da altura

if sentido == 12
    xC = xMed + xCorrAltura;
    yC = yMed + yCorrAltura;
elseif sentido == 21
    xC = xMed - xCorrAltura;
    yC = yMed - yCorrAltura;
end

%% C�lculo do ponto B do tri�ngulo (ponta da largura)

gama = pi/2 - alpha;                    % �ngulo entre a largura do tri�ngulo e o eixo X
xCorrLargura = largura*cos(gama);       % Comprimento X de corre��o da largura
yCorrLargura = largura*sin(gama);       % Comprimento Y de corre��o da largura

xB = xMed - xCorrLargura;
yB = xMed + yCorrLargura;
