function PlotaTopologiaTensao(auxiliar, dadosEntrada, estadosRede)
%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função plota a topologia do sistema baseada nos dados de entrada
%%%% (coordenadas cartesianas ou georreferenciadas). As tensões do sistema
%%%% são representadas nas cores laranja, vermelha, verde ou preta conforme
%%%% os limites estabelecidos pelo PRODIST.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 05/07/2015 / Plot de coordenadas cartesianas.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Transformação das coordenadas em variáveis de linha

coordenadas_de = zeros(length(dadosEntrada.de),2);               % Coluna 1: X Coluna 2: Y
coordenadas_para = zeros(length(dadosEntrada.para),2);           % Coluna 1: X Coluna 2: Y

for k=1:length(dadosEntrada.de)
    coordenadas_de(k,1) = dadosEntrada.coordHorizontal(dadosEntrada.barras(dadosEntrada.de(k)));
    coordenadas_de(k,2) = dadosEntrada.coordVertical(dadosEntrada.barras(dadosEntrada.de(k)));
    coordenadas_para(k,1) = dadosEntrada.coordHorizontal(dadosEntrada.barras(dadosEntrada.para(k)));
    coordenadas_para(k,2) = dadosEntrada.coordVertical(dadosEntrada.barras(dadosEntrada.para(k)));
end

%% Tratamento das coordenadas georreferenciadas

if strcmp(auxiliar.opcaoPlotUsuario,'georreferenciado')
%     % Conversão de ° em rad
%     latitude = deg2rad(dadosEntrada.coordHorizontal);
%     longitude = deg2rad(dadosEntrada.coordVertical);
%     
%     % Conversão de georreferenciado para cartesiano
%     [dadosEntrada.coordVertical,dadosEntrada.coordHorizontal, ~, ~]=ell2utm(latitude,longitude);
elseif strcmp(auxiliar.opcaoPlotUsuario,'cartesiano')
elseif strcmp(auxiliar.opcaoPlotUsuario,'nenhum')
    return;
else
    error('Tipo de dados das coordenadas inválidos!');
end

%% Propriedades do plot

barWidth = 2;                           % Largura das barras
barHeight = 1;                          % Altura das barras
circlOuterSquare = 1;                   % Tamanho do circulo do símbolo dos transformadores

%% Plot

topologia = figure
hold on

for i = 1 : length(coordenadas_de)
%     ind_de = find(de(i) == barras);
%     ind_para = find(para(i) == barras);
    
    cor = SelecionarCor(estadosRede.V(find(dadosEntrada.para(i) == dadosEntrada.barras)));
    
    %%%% Plot das barras
    rectangle('Position',[(coordenadas_de(i,1)-barWidth/2) (coordenadas_de(i,2)-barHeight/2) barWidth barHeight],'EdgeColor','k','Facecolor',cor);
    rectangle('Position',[(coordenadas_para(i,1)-barWidth/2) (coordenadas_para(i,2)-barHeight/2) barWidth barHeight],'EdgeColor','k','Facecolor',cor);
%     rectangle('Position',[(dadosEntrada.coordHorizontal(ind_de)-barWidth/2) (dadosEntrada.coordVertical(ind_de)-barHeight/2) barWidth barHeight],'EdgeColor','k','Facecolor',cor);
%     rectangle('Position',[(dadosEntrada.coordHorizontal(ind_para)-barWidth/2) (dadosEntrada.coordVertical(ind_para)-barHeight/2) barWidth barHeight],'EdgeColor','k','Facecolor',cor);
    
    %%%% Plot das linhas
    if ~isempty(find(dadosEntrada.linhas(i,1) == dadosEntrada.linhasChaveaveis)) && dadosEntrada.statusChaves(find(dadosEntrada.linhas(i,1) == dadosEntrada.linhasChaveaveis)) == 0
        line([coordenadas_de(i,1) coordenadas_para(i,1)],[coordenadas_de(i,2) coordenadas_para(i,2)],'Color', 'k', 'LineWidth', 2);
%         line([dadosEntrada.coordHorizontal(ind_de) dadosEntrada.coordHorizontal(ind_para)],[dadosEntrada.coordVertical(ind_de) dadosEntrada.coordVertical(ind_para)],'Color', 'k', 'LineWidth', 2);
    else
        line([coordenadas_de(i,1) coordenadas_para(i,1)],[coordenadas_de(i,2) coordenadas_para(i,2)],'Color', cor, 'LineWidth', 2);
%         line([dadosEntrada.coordHorizontal(ind_de) dadosEntrada.coordHorizontal(ind_para)],[dadosEntrada.coordVertical(ind_de) dadosEntrada.coordVertical(ind_para)],'Color', cor, 'LineWidth', 2);
    end
    
    %%%% Plot das chaves
    if ~isempty(find(dadosEntrada.linhas(i,1) == dadosEntrada.linhasChaveaveis))         
        if dadosEntrada.statusChaves(find(dadosEntrada.linhas(i,1) == dadosEntrada.linhasChaveaveis)) == 1
            plot((coordenadas_de(i,1)+coordenadas_para(i,1))/2,(coordenadas_de(i,2)+coordenadas_para(i,2))/2,'sk','MarkerFaceColor','k','MarkerSize',10)
%             plot((dadosEntrada.coordHorizontal(ind_de)+dadosEntrada.coordHorizontal(ind_para))/2,(dadosEntrada.coordVertical(ind_de)+dadosEntrada.coordVertical(ind_para))/2,'sk','MarkerFaceColor','k','MarkerSize',10)
        else
            plot((coordenadas_de(i,1)+coordenadas_para(i,1))/2,(coordenadas_de(i,2)+coordenadas_para(i,2))/2,'sk','MarkerFaceColor','w','MarkerSize',10)
%             plot((dadosEntrada.coordHorizontal(ind_de)+dadosEntrada.coordHorizontal(ind_para))/2,(dadosEntrada.coordVertical(ind_de)+dadosEntrada.coordVertical(ind_para))/2,'sk','MarkerFaceColor','w','MarkerSize',10)
        end
    end
    
    %%%% Plot dos transformadores reguladores
    if ~isempty(dadosEntrada.linhasTrafosAutomaticos) && ~isempty(find(dadosEntrada.linhasTrafosAutomaticos == dadosEntrada.linhas(i)))
        Centro = [(coordenadas_de(i,1)+coordenadas_para(i,1))/2 (coordenadas_de(i,2)+coordenadas_para(i,2))/2];
%         Centro = [(dadosEntrada.coordHorizontal(ind_de)+dadosEntrada.coordHorizontal(ind_para))/2 (dadosEntrada.coordVertical(ind_de)+dadosEntrada.coordVertical(ind_para))/2];
        C1 = [(Centro(1,1)-circlOuterSquare/4) Centro(1,2)];
        C2 = [(Centro(1,1)+circlOuterSquare/4) Centro(1,2)];
        P1 = [(C1(1,1)-circlOuterSquare/2) (C1(1,2)-circlOuterSquare/2)];
        P2 = [(C2(1,1)-circlOuterSquare/2) (C2(1,2)-circlOuterSquare/2)];
        rectangle('Position',[P1(1,1) P1(1,2) circlOuterSquare circlOuterSquare],'Curvature',[1 1])
        rectangle('Position',[P2(1,1) P2(1,2) circlOuterSquare circlOuterSquare],'Curvature',[1 1])
    end
%     
%     %%%% Plot de geradores
%     if ~isempty(pchBarraTronco) && ~isempty(find(para(i) == pchBarraTronco,1))
%         plot(dadosEntrada.coordHorizontal(ind_y),dadosEntrada.coordVertical(ind_y),'ok','MarkerSize',15,'MarkerFaceColor','k')
%         plot(dadosEntrada.coordHorizontal(ind_y),dadosEntrada.coordVertical(ind_y),'ok','MarkerSize',10,'MarkerFaceColor','w')
%     end
end

title('Topologia do sistema: perfil de tensão');
% save(strcat(pwd,'/Resultados/','Topologia.fig'),topologia);

function [cor]=SelecionarCor(V)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Função para selecionar a cor conforme o valor de perfil de tensão
%%%
%%% Desenvolvido por Lucas R. Ferreira
%%% 14/03/14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vmax = 1.06;
vmin = 0.90;
vcritico = 0.93;

if V == 0                                       % Sem tensão
    cor = [0 0 0];
elseif V <= vmax && V >= vcritico               % Dentro dos limites
    cor = [0 1 0];
elseif V < vcritico && V >= vmin                % Nível Crítico
    cor = [1 0.8 0];
elseif V < vmin                                 % Nível de Alerta Mínimo
    cor = [1 0 0];
elseif V > vmax                                 % Nível de Alerta Máximo
    cor = [0.6 0 1];
end
