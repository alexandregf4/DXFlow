function [Y, B, G] = montaY3(dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o monta a matriz admit�ncia do sistema em estudo para
%%%% c�lculo do fluxo de carga.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1.0 - 29/06/2014
%%%% v1.1 - 03/08/2014 / Corre��o de bug: NaN no shunt de linha
%%%% v1.2 - 23/08/2014 / Prepara��o do algoritmo para barras PQV: barras
%%%% sem tap especificado. Estas s�o inicializadas com a = 1.
%%%% v1.3 - 26/10/2014 / Corre��o da formula��o de montagem da Y barra: se
%%%% akm � diferente de 1, amk = 1, pois o transformador � 1:a.
%%%% v2.0 - 05/11/2014 / Reprograma��o da fun��o. Utiliza��o da fun��o
%%%% pesquisa_adjacentes para encontrar as linhas adjacentes.
%%%% Desconsidera��o do transformador defasador.
%%%% v3.0 - 09/05/2015 / Utiliza��o da fun��o conjuntoomegak, desprezando o
%%%% conjunto tauk (ramos chave�veis) para a utiliza��o do n�vel de
%%%% subesta��o.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% C�lculo das admit�ncias do sistema

dadosEntrada.bShBarra(isnan(dadosEntrada.bShBarra) == 1) = 0;               % Posi��es do vetor bShBarra n�o preenchidas s�o preenchidas com 0
dadosEntrada.tap(isnan(dadosEntrada.tap) == 1) = 1;                         % Posi��es do vetor tap n�o preenchidas s�o preenchidas com 1

ykm = 1./complex(dadosEntrada.r,dadosEntrada.x);                            % Vetor com as admit�ncias s�rie de todos os trechos j� em n� complexo
ykk = dadosEntrada.tap.^2.*ykm + complex(0,abs(dadosEntrada.b));            % Vetor com a express�o: a^2*Ykm + jBkm_sh para todos os trechos (n� complexo)
ymm = ykm + complex(0,abs(dadosEntrada.b));                                 % Vetor com a express�o: Ykm + jBkm_sh para todos os trechos (n� complexo)
bShunt = complex(0,abs(dadosEntrada.bShBarra));                             % Vetor com as admit�ncias paralelas de barra transformado em n� complexo

%% Montagem da matriz Y

Y = zeros(dadosEntrada.nb,dadosEntrada.nb);                    % Inicializa��o em 0 da matriz com tamanho nb x nb

for l = 1:dadosEntrada.nb                                                   % La�o de pesquisa nas linhas de Y
   for c = 1:dadosEntrada.nb                                                % La�o de pesquisa nas colunas de Y
   
       k = dadosEntrada.barras(l);                                          % Defini��o da barra k (DE)
       m = dadosEntrada.barras(c);                                          % Defini��o da barra m (PARA)
       
       if l == c                                                            %%%% Diagonal principal
          
          [linhasAdjacentes, ~] = ConjuntoOmegaK(k, dadosEntrada);
          for t=1:dadosEntrada.nl                                           % La�o de pesquisa se a barra atual est� na lista dos transformadores
              if k == dadosEntrada.de(dadosEntrada.linhas(t))               % Se a barra for o lado DE da linha que possui o transformador
                  Y(l,c) = sum(ykk(dadosEntrada.linhas(linhasAdjacentes))) + bShunt(k);    % Ykk = sum(a^2.ykm + bkm/2) + jbk
              else
                  Y(l,c) = sum(ymm(dadosEntrada.linhas(linhasAdjacentes))) + bShunt(k);    % Ymm = sum(ykm + bkm/2) + jbk
              end
          end
           
       else                                                                 %%%% Fora da diagonal
           
           for t=1:dadosEntrada.nl                                                                                          % La�o de pesquisa para encontrar se as duas barras possuem uma linha em comum
               
               if isempty(find(dadosEntrada.linhasChaveaveis == dadosEntrada.linhas(t)))                                    % Se n�o � linha chave�vel
                   
                   if k == dadosEntrada.de(dadosEntrada.linhas(t)) && m == dadosEntrada.para(dadosEntrada.linhas(t))        % Se encontrou uma linha com k|------|m
                       
                       if dadosEntrada.phi(dadosEntrada.linhas(t)) ~= 0                  %%%% Se existe transformador defasador nesta linha:
                           Y(l,c) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ykm = akm.exp(j.phi).ykm
                           Y(c,l) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(-1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));  % ymk = akm.exp(-j.phi).ykm
                       else                                                 %%%% Se N�O existe transformador defasador nesta linha:
                           Y(l,c) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ykm = akm.exp(j.phi).ykm
                           Y(c,l) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ymk = akm.exp(j.phi).ykm
                       end
                       
                   elseif k == dadosEntrada.para(dadosEntrada.linhas(t)) && m == dadosEntrada.de(dadosEntrada.linhas(t))    % Se encontrou uma linha com m|------|k
                       
                       if dadosEntrada.phi(dadosEntrada.linhas(t)) ~= 0                  %%%% Se existe transformador defasador nesta linha:
                           Y(l,c) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(-1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));  % ymk = akm.exp(-j.phi).ykm
                           Y(c,l) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ykm = akm.exp(j.phi).ykm
                       else
                           Y(l,c) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ykm = akm.exp(j.phi).ykm
                           Y(c,l) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ymk = akm.exp(j.phi).ykm
                       end
                   end
               end
           end
       end
   end
end

G = real(Y);                                % C�lculo da matriz G (parte real de Y)
B = imag(Y);                                % C�lculo da matriz B (parte imagin�ria de Y)
end