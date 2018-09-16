function [Y, B, G] = montaY3(dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função monta a matriz admitância do sistema em estudo para
%%%% cálculo do fluxo de carga.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1.0 - 29/06/2014
%%%% v1.1 - 03/08/2014 / Correção de bug: NaN no shunt de linha
%%%% v1.2 - 23/08/2014 / Preparação do algoritmo para barras PQV: barras
%%%% sem tap especificado. Estas são inicializadas com a = 1.
%%%% v1.3 - 26/10/2014 / Correção da formulação de montagem da Y barra: se
%%%% akm é diferente de 1, amk = 1, pois o transformador é 1:a.
%%%% v2.0 - 05/11/2014 / Reprogramação da função. Utilização da função
%%%% pesquisa_adjacentes para encontrar as linhas adjacentes.
%%%% Desconsideração do transformador defasador.
%%%% v3.0 - 09/05/2015 / Utilização da função conjuntoomegak, desprezando o
%%%% conjunto tauk (ramos chaveáveis) para a utilização do nível de
%%%% subestação.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Cálculo das admitâncias do sistema

dadosEntrada.bShBarra(isnan(dadosEntrada.bShBarra) == 1) = 0;               % Posições do vetor bShBarra não preenchidas são preenchidas com 0
dadosEntrada.tap(isnan(dadosEntrada.tap) == 1) = 1;                         % Posições do vetor tap não preenchidas são preenchidas com 1

ykm = 1./complex(dadosEntrada.r,dadosEntrada.x);                            % Vetor com as admitâncias série de todos os trechos já em nº complexo
ykk = dadosEntrada.tap.^2.*ykm + complex(0,abs(dadosEntrada.b));            % Vetor com a expressão: a^2*Ykm + jBkm_sh para todos os trechos (nº complexo)
ymm = ykm + complex(0,abs(dadosEntrada.b));                                 % Vetor com a expressão: Ykm + jBkm_sh para todos os trechos (nº complexo)
bShunt = complex(0,abs(dadosEntrada.bShBarra));                             % Vetor com as admitâncias paralelas de barra transformado em nº complexo

%% Montagem da matriz Y

Y = zeros(dadosEntrada.nb,dadosEntrada.nb);                    % Inicialização em 0 da matriz com tamanho nb x nb

for l = 1:dadosEntrada.nb                                                   % Laço de pesquisa nas linhas de Y
   for c = 1:dadosEntrada.nb                                                % Laço de pesquisa nas colunas de Y
   
       k = dadosEntrada.barras(l);                                          % Definição da barra k (DE)
       m = dadosEntrada.barras(c);                                          % Definição da barra m (PARA)
       
       if l == c                                                            %%%% Diagonal principal
          
          [linhasAdjacentes, ~] = ConjuntoOmegaK(k, dadosEntrada);
          for t=1:dadosEntrada.nl                                           % Laço de pesquisa se a barra atual está na lista dos transformadores
              if k == dadosEntrada.de(dadosEntrada.linhas(t))               % Se a barra for o lado DE da linha que possui o transformador
                  Y(l,c) = sum(ykk(dadosEntrada.linhas(linhasAdjacentes))) + bShunt(k);    % Ykk = sum(a^2.ykm + bkm/2) + jbk
              else
                  Y(l,c) = sum(ymm(dadosEntrada.linhas(linhasAdjacentes))) + bShunt(k);    % Ymm = sum(ykm + bkm/2) + jbk
              end
          end
           
       else                                                                 %%%% Fora da diagonal
           
           for t=1:dadosEntrada.nl                                                                                          % Laço de pesquisa para encontrar se as duas barras possuem uma linha em comum
               
               if isempty(find(dadosEntrada.linhasChaveaveis == dadosEntrada.linhas(t)))                                    % Se não é linha chaveável
                   
                   if k == dadosEntrada.de(dadosEntrada.linhas(t)) && m == dadosEntrada.para(dadosEntrada.linhas(t))        % Se encontrou uma linha com k|------|m
                       
                       if dadosEntrada.phi(dadosEntrada.linhas(t)) ~= 0                  %%%% Se existe transformador defasador nesta linha:
                           Y(l,c) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));   % ykm = akm.exp(j.phi).ykm
                           Y(c,l) = -dadosEntrada.tap(dadosEntrada.linhas(t)).*exp(-1j*dadosEntrada.phi(dadosEntrada.linhas(t))).*ykm(dadosEntrada.linhas(t));  % ymk = akm.exp(-j.phi).ykm
                       else                                                 %%%% Se NÃO existe transformador defasador nesta linha:
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

G = real(Y);                                % Cálculo da matriz G (parte real de Y)
B = imag(Y);                                % Cálculo da matriz B (parte imaginária de Y)
end