function [xA, xB, xC, yA, yB, yC] = CoordenadasSetaFluxo(altura, largura, x1, x2, y1, y2, sentido)

%% Ponto médio do segmento

xMed = (x1+x2)/2;
yMed = (y1+y2)/2;

%% Cálculo do ponto A do triângulo (base)

xA = xMed;
yA = yMed;

%% Cálculo do ponto C do triângulo (ponta da seta)

alpha = atan((y2-y1)/(x2-x1));          % Ângulo derivado do coeficiente angular da reta "m"
xCorrAltura = altura*cos(alpha);        % Comprimento X de correção da altura
yCorrAltura = altura*sin(alpha);        % Comprimento Y de correção da altura

if sentido == 12
    xC = xMed + xCorrAltura;
    yC = yMed + yCorrAltura;
elseif sentido == 21
    xC = xMed - xCorrAltura;
    yC = yMed - yCorrAltura;
end

%% Cálculo do ponto B do triângulo (ponta da largura)

gama = pi/2 - alpha;                    % Ângulo entre a largura do triângulo e o eixo X
xCorrLargura = largura*cos(gama);       % Comprimento X de correção da largura
yCorrLargura = largura*sin(gama);       % Comprimento Y de correção da largura

xB = xMed - xCorrLargura;
yB = xMed + yCorrLargura;
