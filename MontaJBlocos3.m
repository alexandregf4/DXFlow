function [J] = MontaJBlocos3(dadosEntrada, estadosRede, barrasDeltaPQ, potenciaDeltaPQ, variavelDeltaX)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função monta a matriz jacobiana por blocos 2x2 para um fluxo de
%%%% carga convencional.
%%%% A estrutura da jacobiana é a seguinte:
%%%% [dP1/dtheta1  dP1/dV1  dP1/dtheta2  dP1/dV2]
%%%% [dQ1/dtheta1  dQ1/dV1  dQ1/dtheta2  dQ1/dV2]
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%% v2 - em desenvolvimento / Suporte ao controle automático de tap com acréscimo
%%%% dos elementos dP/dakm (W) e dQ/dakm (Z)
%%%% v3 = 13/05/2015 / Adicionados elementos C, D, O e P para a modelagem
%%%% de ramos chaveáveis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Montagem da matriz Jacobiana por blocos 2x2

J = sparse(zeros(2.*dadosEntrada.npq+2.*dadosEntrada.npqv+dadosEntrada.npv+2.*dadosEntrada.nrc,2.*dadosEntrada.npq+2.*dadosEntrada.npqv+dadosEntrada.npv+2.*dadosEntrada.nrc));                         % Inicialização da matriz Jacobiana

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBS.: linha_akm é o vetor de linhas com transformadores comutadores
% automáticos. A especificação de qual posição está sendo utilizada em cada
% laço (no caso de mais de um transformador comutador) é feita por
% observação do número da barra PARA. A barra PARA é considerada sempre a
% barra cuja tensão será regulada.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

listaUsadosPa = [];
listaUsadosQa = [];

for l=1:length(J)                                                                               % Laço que corre todas as linhas da Jacobiana
   if l <= 2.*dadosEntrada.npq + dadosEntrada.npv + 2.*dadosEntrada.npqv
        k = barrasDeltaPQ(l);                                                                   % Definição da barra k em relação à linha da Jacobiana
   else
       k = 0;
   end
      for c=1:length(J)                                                                         % Laço que corre todas as colunas da Jacobiana
            
          if c <= 2.*dadosEntrada.npq + dadosEntrada.npv + 2.*dadosEntrada.npqv
            m = barrasDeltaPQ(c);                                                               % Definição da barra m em relação à coluna da Jacobiana
          else
            m = 0;
          end
      
      if strcmp(potenciaDeltaPQ{l,1},'P') && strcmp(variavelDeltaX{c,1},'O')            % Se a linha é potência ativa (P) e a coluna é ângulo da tensão (theta)
          J(l,c) = CalculaH(k, m, dadosEntrada, estadosRede);                                   % Elemento de J recebe H
      elseif strcmp(potenciaDeltaPQ{l,1},'P') && strcmp(variavelDeltaX{c,1},'V')        % Se a linha é potência ativa (P) e a coluna é módulo da tensão (V)                         
          J(l,c) = CalculaN(k, m, dadosEntrada, estadosRede);                                   % Elemento de J recebe N
      elseif strcmp(potenciaDeltaPQ{l,1},'P') && strcmp(variavelDeltaX{c,1},'a')        % Se a linha é potência ativa (P) e a coluna é módulo do tap (a)                         
          for h=1:length(dadosEntrada.linhasTrafosAutomaticos)                                  % Laço para encontrar a linha do vetor akm correspondente ao para igual à m
              if isempty(find(listaUsadosPa == h))
                  if dadosEntrada.de(dadosEntrada.linhasTrafosAutomaticos(h)) == k || dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(h)) == m
                        listaUsadosPa(h) = h;                                                 % Lista de posições já verificadas de linha_akm
                        break;
                  end
              end
          end
          J(l,c) = CalculaW(k, linha_akm, dadosEntrada, estadosRede);                           % Elemento de J recebe W
      elseif strcmp(potenciaDeltaPQ{l,1},'Q') && strcmp(variavelDeltaX{c,1},'O')        % Se a linha é potência reativa (Q) e a coluna é ângulo da tensão (theta)
          J(l,c) = CalculaM(k, m, dadosEntrada, estadosRede);                                   % Elemento de J recebe M
      elseif strcmp(potenciaDeltaPQ{l,1},'Q') && strcmp(variavelDeltaX{c,1},'V')        % Se a linha é potência reativa (Q) e a coluna é módulo da tensão (V)
          J(l,c) = CalculaL(k, m, dadosEntrada, estadosRede);                                   % Elemento de J recebe L
      elseif strcmp(potenciaDeltaPQ{l,1},'Q') && strcmp(variavelDeltaX{c,1},'a')        % Se a linha é potência ativa (Q) e a coluna é módulo do tap (a)                         
          for h=1:length(dadosEntrada.linhasTrafosAutomaticos)                                  % Laço para encontrar a linha do vetor akm correspondente ao para igual à m
                if isempty(find(listaUsadosQa == h))
                  if dadosEntrada.de(dadosEntrada.linhasTrafosAutomaticos(h)) == k || dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(h)) == m
                        listaUsadosQa(h) = h;                                            % Lista de posições já verificadas de linha_akm
                        break;
                  end
              end
          end
          J(l,c) = CalculaZ(k, linha_akm, dadosEntrada, estadosRede);                           % Elemento de J recebe Z
      elseif strcmp(potenciaDeltaPQ{l,1},'P') && strcmp(variavelDeltaX{c,1},'t')
          J(l,c) = CalculaT([], l, c, dadosEntrada, barrasDeltaPQ);
      elseif strcmp(potenciaDeltaPQ{l,1},'Q') && strcmp(variavelDeltaX{c,1},'u')
          J(l,c) = CalculaU([], l, c, dadosEntrada, barrasDeltaPQ);
      elseif strcmp(potenciaDeltaPQ{l,1},'t_cl') && strcmp(variavelDeltaX{c,1},'O')
          J(l,c) = CalculaC([], l, c, barrasDeltaPQ, dadosEntrada);
      elseif strcmp(potenciaDeltaPQ{l,1},'u_cl') && strcmp(variavelDeltaX{c,1},'V')
          J(l,c) = CalculaD([], l, c, barrasDeltaPQ, dadosEntrada);
      elseif strcmp(potenciaDeltaPQ{l,1},'t_op') && strcmp(variavelDeltaX{c,1},'t')
          J(l,c) = CalculaO([], l, c, dadosEntrada);
      elseif strcmp(potenciaDeltaPQ{l,1},'u_op') && strcmp(variavelDeltaX{c,1},'u')
          J(l,c) = CalculaP([], l, c, dadosEntrada);
%       else
%           error('Erro na montagem da Jacobiana! Linha %d Coluna %d', l, c);             % Exibição de mensagem de erro se nenhuma das condições anteriores forem satisfeitas (erro na matriz potenciaDeltaPQ)
      end
   end
end
end