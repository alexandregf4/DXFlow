% incidencia
A=[1  0  0  0  0  0  0;
  -1  1  1  0  0  0  0;
   0 -1  0  0  0  0  0;
   0  0 -1  0  0  0  0;
   0  0  0  0  1  1  0;
   0  0  0  0 -1  0  0;
   0  0  0  0  0 -1  1;
   0  0  0  0  0  0 -1]
   

[mL, mU] = lu(A*A');

% substitui os pivos nulos por 1
mU(4,4) = 1;
mU(8,8) = 1;

mU

% define vetor com valores positivos inteiros sequencias nas posições respectivas aos pivos nulos
b = [0 0 0 1 0 0 0 2]'

theta_ilhas = inv(mU)*b


% Resulatdo:
% theta_ilhas = [1 1 1 1 2 2 2 2]'

