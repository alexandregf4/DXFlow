function [caminhos_se]=Conectividade3(linhas, pontas, se)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% LACTEC - DPEE - DVSE
% Algoritmo desenvolvido por Helon V H Ayala e Luciano
% Data: 2013
% Objetivo: encontrou falha na conectividade
% Solicitantes: Fabio
%
% Dado de entrada:
%    linhas --> matriz com 2 colunas contendo informações de De e Para
%               É NECESSÁRIO que a primeira linha seja a SE
% Dados de saída:
%     caminhos_se     -->  caminhos que levam até a SE
%     caminhos_falha  -->  caminhos que não levam até a SE
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

lin_linhas = size(linhas,1); % número de linhas
% se = linhas(1,1);            % guarda o número da subestação

% ----- Encontrar as pontas do circuito
conta_pontas = length(pontas); % contador das pontas
% pontas = [];      % vetor com as pontas
% for a=1:lin_linhas
%     if isempty(find(linhas(a,2)==linhas(:,1), 1))
%         conta_pontas = conta_pontas + 1;
%         pontas(conta_pontas) = linhas(a,2);
%     end
% end

% ----- traçar os caminhos de cada ponta
caminhos=[]; % matriz com os caminhos, cada linha é um caminho
for b=1:conta_pontas
    % acha o indice da ponta
    i_ponta = find(pontas(b) == linhas(:,2));
    % começa o caminho de cada ponta
    caminhos(b,1:2) = [linhas(i_ponta,2) linhas(i_ponta,1)];
    % tamanho mínimo do caminho
    n_caminho = 2;
    % varre toda a matriz para cada ponta
    c = 0;
    while c ~= lin_linhas
        c = c + 1;
        if linhas(lin_linhas-c+1,2) == caminhos(b,n_caminho)
            n_caminho = n_caminho + 1;
            caminhos(b,n_caminho) = linhas(lin_linhas-c+1,1);
            c = 0;
        end
        if any(caminhos == se) % se chega na subestação
            break
        end
    end
end

% ----- Mostra caminhos que não levam a ponta até a SE
caminhos_se    = []; % dados para saída
caminhos_falha = []; % dados para saída
conta_se    = 0;
conta_falha = 0;
for a=1:conta_pontas
    if isempty(find(caminhos(a,:) == se, 1))
        conta_falha = conta_falha + 1;
        % fprintf('\nCaminho %i não leva até a SE.',a);
        caminhos_falha(conta_falha,:) = caminhos(a,:);
    else
        conta_se = conta_se + 1;
        %fprintf('\nCaminho %i leva até a SE.',a);
        caminhos_se(conta_se,:) = caminhos(a,:);
    end
end


% fprintf('\n\n\nFim\n\n');
end