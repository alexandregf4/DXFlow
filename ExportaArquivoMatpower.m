function [] = ExportaArquivoMatpower(modoExecucao, dadosEntrada, bShBarraVar)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função utiliza os dados extraídos da planilha de dados de entrada
%%%% e os formata no formato dos dados de entrada do MATPOWER.
%%%%
%%%% v1 - 25/10/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Criação de um novo arquivo

if strcmp(modoExecucao,'WIN')
    if exist(strcat(pwd,'\Export MATPOWER\export_matpower.m'),'file')                   % Deleção do arquivo anterior
        delete(strcat(pwd,'\Export MATPOWER\export_matpower.m'));
    end

    exportMatpower = fopen(strcat(pwd,'\Resultados\export_matpower.m'),'w');            % Criação do novo arquivo
    
elseif strcmp(modoExecucao,'MAC')
    if exist(strcat(pwd,'/Export MATPOWER/export_matpower.m'),'file')                   % Deleção do arquivo anterior
        delete(strcat(pwd,'/Export MATPOWER/export_matpower.m'));
    end

    exportMatpower = fopen(strcat(pwd,'/Export MATPOWER/export_matpower.m'),'w');       % Criação do novo arquivo
end
    

%% Headers
fprintf(exportMatpower,'function mpc = export_matpower\n\n');
fprintf(exportMatpower,'%% Este é um arquivo exportado do programa DXFlow gerado a partir do últimos dados de entrada abertos\n\n');

%% case format
fprintf(exportMatpower,'%%%% MATPOWER Case Format : Version 2\n');
fprintf(exportMatpower,'mpc.version = ''2'';\n\n');

%% system MVA base
fprintf(exportMatpower,'%%%% system MVA base\n');
fprintf(exportMatpower,'mpc.baseMVA = %d;\n\n',dadosEntrada.moduloPotenciaBase./1000);

%% bus data

for k=1:dadosEntrada.nb
    switch dadosEntrada.tipoBarra(k)
        case 1                      % Barra VT
            tipoBarraMatpower = 3;
        case 2                      % Barra PV
            tipoBarraMatpower = 2;
        case 3
            tipoBarraMatpower = 1;
        case 4
            tipoBarraMatpower = 1;
    end
    
    if k==1                         % Se for a primeira linha
        dadosEntrada.Vesp(isnan(dadosEntrada.Vesp)) = 1;
        dadosEntrada.Pg = -dadosEntrada.Pg;
        dadosEntrada.Pg(isnan(dadosEntrada.Pg)) = 0;
        dadosEntrada.Pd = -dadosEntrada.Pd;
        dadosEntrada.Pd(isnan(dadosEntrada.Pd)) = 0;
        dadosEntrada.Qg = -dadosEntrada.Qg;
        dadosEntrada.Qg(isnan(dadosEntrada.Qg)) = 0;
        dadosEntrada.Qd = -dadosEntrada.Qd;
        dadosEntrada.Qd(isnan(dadosEntrada.Qd)) = 0;
        
        fprintf(exportMatpower, 'mpc.bus = [%d  %d  %1.9f  %2.9f  %d  %3.9f  %d  %4.2f  %5.2f  %6.2f  %d  %7.1f  %8.1f;\n',dadosEntrada.barras(k), tipoBarraMatpower, (dadosEntrada.Pg(k)-dadosEntrada.Pd(k))./1000, (dadosEntrada.Qg(k)-dadosEntrada.Qd(k))./1000, 0, bShBarraVar(k)./1000, 0, dadosEntrada.Vesp(k), 0, dadosEntrada.VbaseBarra(k), 1, 1.5, 0.5);
    elseif k == dadosEntrada.nb                      % Se for a última linha
        fprintf(exportMatpower, '%d  %d  %1.9f  %2.9f  %d  %3.9f  %d  %4.2f  %5.2f  %6.2f  %d  %7.1f  %8.1f];\n\n',dadosEntrada.barras(k), tipoBarraMatpower, (dadosEntrada.Pg(k)-dadosEntrada.Pd(k))./1000, (dadosEntrada.Qg(k)-dadosEntrada.Qd(k))./1000, 0, bShBarraVar(k)./1000, 0, dadosEntrada.Vesp(k), 0, dadosEntrada.VbaseBarra(k), 1, 1.5, 0.5);
    else                                % Se for uma linha intermediária
        fprintf(exportMatpower, '%d  %d  %1.9f  %2.9f  %d  %3.9f  %d  %4.2f  %5.2f  %6.2f  %d  %7.1f  %8.1f;\n',dadosEntrada.barras(k), tipoBarraMatpower, (dadosEntrada.Pg(k)-dadosEntrada.Pd(k))./1000, (dadosEntrada.Qg(k)-dadosEntrada.Qd(k))./1000, 0, bShBarraVar(k)./1000, 0, dadosEntrada.Vesp(k), 0, dadosEntrada.VbaseBarra(k), 1, 1.5, 0.5);
    end
end

%% generator data
fprintf(exportMatpower,'%%%% generator data\n');
fprintf(exportMatpower,'mpc.gen = [1  %d  0	%d  %d  1  1000  1  %d  0  0  0  0  0  0  0  0  0  0  0  0];\n\n', 10.*ceil(sum(abs(dadosEntrada.Pg))+sum(abs(dadosEntrada.Pd))), 10.*ceil(sum(abs(dadosEntrada.Qg))+sum(abs(dadosEntrada.Qd))), -10.*ceil(sum(abs(dadosEntrada.Qg))+sum(abs(dadosEntrada.Qd))), 15.*ceil(sum(abs(dadosEntrada.Pg))+sum(abs(dadosEntrada.Pd))));

%% branch data
fprintf(exportMatpower,'%%%% branch data\n');
zBase = (dadosEntrada.VbaseLinha.^2.*1000)./dadosEntrada.moduloPotenciaBase;

for k=1:dadosEntrada.nl
    
    %%%% O ramo atual é chaveável?
    flagRamoChaveavel = false;
    if ~isempty(dadosEntrada.linhasChaveaveis)
        for l=1:length(dadosEntrada.linhasChaveaveis)
            if dadosEntrada.linhas(k) == dadosEntrada.linhasChaveaveis(l)
                flagRamoChaveavel = true;
                break;
            end
        end
    end
    
    %%%% O programa ignora ramos chaveáveis!
    if flagRamoChaveavel == false
        
        dadosEntrada.tap(isnan(dadosEntrada.tap)) = 1;
        dadosEntrada.phi(isnan(dadosEntrada.phi)) = 0;
        
        if k==1
            fprintf(exportMatpower,'mpc.branch = [%d  %d  %1.9f  %2.9f  %3.9f  %d  %d  %d  %4.3f  %5.3f  %d  %d  %d;\n',dadosEntrada.de(k), dadosEntrada.para(k), dadosEntrada.rConvencional(k)./zBase(k), dadosEntrada.xConvencional(k)./zBase(k), dadosEntrada.bConvencional(k)./zBase(k), 500, 500, 500, dadosEntrada.tap(k), dadosEntrada.phi(k), 1, -360, 360);
        elseif k==dadosEntrada.nl
            fprintf(exportMatpower,'%d  %d  %1.9f  %2.9f  %3.9f  %d  %d  %d  %4.3f  %5.3f  %d  %d  %d];\n\n',dadosEntrada.de(k), dadosEntrada.para(k), dadosEntrada.rConvencional(k)./zBase(k), dadosEntrada.xConvencional(k)./zBase(k), dadosEntrada.bConvencional(k)./zBase(k), 500, 500, 500, dadosEntrada.tap(k), dadosEntrada.phi(k), 1, -360, 360);
        else
            fprintf(exportMatpower,'%d  %d  %1.9f  %2.9f  %3.9f  %d  %d  %d  %4.3f  %5.3f  %d  %d  %d;\n',dadosEntrada.de(k), dadosEntrada.para(k), dadosEntrada.rConvencional(k)./zBase(k), dadosEntrada.xConvencional(k)./zBase(k), dadosEntrada.bConvencional(k)./zBase(k), 500, 500, 500, dadosEntrada.tap(k), dadosEntrada.phi(k), 1, -360, 360);
        end
    end
    
    flagRamoChaveavel = false;
end

%% generator cost data
fprintf(exportMatpower,'%%%% generator cost data\n');
fprintf(exportMatpower,'mpc.gencost = [2  0  0  2  14  0];');
