
clc
clear all 
close all 

display(newline)
display("---------------------MINTS---------------------")

addpath("../../functions/")

addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml('mintsDefinitions.yaml')

dataFolder         = mintsDefinitions.dataFolder;
gatewayIDs         = mintsDefinitions.gatewayIDs;
loraIDs            = mintsDefinitions.loraIDs;
deployments        = mintsDefinitions.deployments;
binsPerColumn      = mintsDefinitions.binsPerColumn;
numberPerBin       = mintsDefinitions.numberPerBin ;
pValid             = mintsDefinitions.pValid;
airmarID           = mintsDefinitions.airmarID;

mintsInputs ={...       
    'NH3'    ,...              
    'CO'     ,...           
    'NO2'    ,...       
    'C3H8'   ,...          
    'C4H10'  ,...          
    'CH4'    ,...          
    'H2'     ,...          
    'C2H5OH' ,...          
    'P1_lpo' ,...          
    'P1_ratio',...         
    'P1_conc' ,...         
    'P2_lpo'  ,...         
    'P2_ratio',...         
    'P2_conc'  ,...        
    'Temperature' ,...     
    'Pressure'       ,...  
    'Humidity'   ,...      
    'shuntVoltageBat' ,... 
    'busVoltageBat' ,...   
    'currentBat'   ,...    
    'shuntVoltageSol'  ,...
    'busVoltageSol' ,...   
    'currentSol'     ,...  
    'CO2'            ,...  
    'SCD30_temperature',...
    'SCD30_humidity'   ,...
        }

mintsInputLabels ={...       
    'NH_{3}'    ,...              
    'CO'     ,...           
    'NO_{2}'    ,...       
    'C_{3}H_{8}'   ,...          
    'C_{4}H_{10)'  ,...          
    'CH_{4}'    ,...          
    'H_{2}'     ,...          
    'C_{2}H_{5}OH' ,...          
    'P1 LPP' ,...          
    'P1 Ratio',...         
    'P1 Concentration' ,...         
    'P2 LPO'  ,...         
    'P2 Ratio',...         
    'P2 Concentration'  ,...        
    'Temperature' ,...     
    'Pressure'       ,...  
    'Humidity'   ,...      
    'Shunt Voltage Battery' ,... 
    'Bus Voltage Battery' ,...   
    'Current Battery'   ,...    
    'Shunt Voltage Solar'  ,...
    'Bus Voltage Solar' ,...   
    'Current Solar'     ,...  
    'CO2 SCD30'            ,...  
    'Temperature SCD30',...
    'Humidity SCD30'   ,...
        }
    
    
    
    
mintsTargets =   {...
            'pm1_PALAS'                   ,...
            'pm2_5_palas'                 ,...
            'pm4_palas'                   ,...
            'pm10_palas'                  ,...
            'temperatureAirmar',...
            'humidityAirmar'   ,... 
            'dewPointAirmar'  ,...
            'pressureAirmar'   }
            
            

        
mintsTargetLabels =   {...
                    'PM_{1}'                  ,...
                    'PM_{2.5}'                ,...
                    'PM_{4}'                  ,...
                    'PM_{10}'                 ,...
                    'Temperature'             ,...
                    'Humidity'                ,...
                    'Dew Point'               ,...
                    'Pressure'                 ...
                     }        
 

% for graphing 
limitsLow  ={ 0,  0,  0,  0,  20,  20, 10, .98};
limitsHigh= {20, 25, 30, 40,  45,  75, 25,  .995};

units      = {'\mug/m^{3}',...
               '\mug/m^{3}',...
               '\mug/m^{3}',...
               '\mug/m^{3}',...
               'C^{o}',...
               '%',...
               'C^{o}',...
               'bars'...
               };
                 
instruments = {'Palas Spectrometor',...
               'Palas Spectrometor',...
               'Palas Spectrometor',...
               'Palas Spectrometor',...
               'Airmar WS',...
               'Airmar WS',...
               'Airmar WS',...
               'Airmar WS',...
                };           
           
rawFolder          =  dataFolder + "/raw";
rawDotMatsFolder   =  dataFolder + "/rawMats";
loraMatsFolder     =  rawDotMatsFolder  + "/lora";
referenceFolder     = dataFolder + "/reference";
referenceMatsFolder = dataFolder + "/referenceMats";
palasFolder         = referenceFolder       + "/palasStream";
palasMatsFolder     = referenceMatsFolder   + "/palas";
driveSyncFolder     = strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    = dataFolder + "/mergedMats/lora";
GPSFolder           = referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        = referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/lora";
trainingMatsFolder  =  dataFolder + "/trainingMats/lora";
plotsFolder         =  dataFolder + "/visualAnalysis/lora";

display(newline)
folderCheck(dataFolder)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawDotMatsFolder)
display("lora DotMat Data Located @ :"+ loraMatsFolder)
display("Reference Data Located @: "+ referenceFolder )
display("Reference DotMat Data Located @ :"+ referenceMatsFolder)
display("Palas Raw Data Located @ :"+ palasFolder)
display("Palas DotMat Data Located @ :"+ palasMatsFolder)
display("Car GPS Files Located @ :"+ GPSFolder)

%% Loading Files 
display("Loading Palas Files")
load(strcat(palasMatsFolder,"/palas.mat"));
palasData = palas;

display("Loading GPS Files");
load(strcat(GPSFolder,"/carMintsGPS.mat"));
carGpsData = mintsData;

display("Loading Airmar Files");
load(strcat(airmarFolder,"/airMar_",airmarID,".mat"));
airmarData = mintsDataAll;
% The airmar was always at the cage, but just incase I am only taking
% inputs that has GPS. 

airmarData = removevars( airmarData, {...
                        'courseOGTrue'                           ,...
                        'courseOGMagnetic'                       ,...
                        'speedOverGroundKnots'                   ,...
                        'speedOverGroundKMPH'                    ,...
                        'heading'                                ,...
                        'barrometricPressureMercury'             ,...
                        'barrometricPressureBars_mintsDataWimda' ,...
                        'windDirectionTrue'                      ,...
                        'windDirectionMagnetic'                  ,...
                        'windSpeedKnots'                         ,...
                        'windSpeedMetersPerSecond'               ,...
                        'windAngle'                              ,...
                        'windSpeed'                              ...
                        });


airmarDataWSTC     = gpsCropCoord(airmarData,32.992179, -96.757777,0.0015,0.0015);

airmarDataWSTC     = removevars( airmarDataWSTC, {...    
                                'latitudeCoordinate'  ,...
                                'longitudeCoordinate'  });      
                            
airmarDataWSTC.Properties.VariableNames =    {'temperatureAirmar'    ,...                    
                                            'humidityAirmar'            ,...          
                                            'dewPointAirmar'                ,...              
                                            'pressureAirmar'};
                                        
%% Syncing Data 

display("Aligning GPS data with Palas Data")
palasWithGPS  =  rmmissing(synchronize(palasData,carGpsData,'intersection'));

display("WSTC Palas Data")
palasWSTC = gpsCropCoord(palasWithGPS,32.992179, -96.757777,0.0015,0.0015);
palasWSTC = removevars( palasWSTC, {...    
                                'latitudeCoordinate'  ,...
                                'longitudeCoordinate'  });



display("Palas With Airmar")
palasWithAirmar  =  rmmissing(synchronize(palasWSTC,airmarDataWSTC,'intersection'));



%% Loading Lora Data and merging them with Palas Data 
display("Analysis")
versionStrTrain = ['loraFitRNN_All_' datestr(today,'yyyy_mm_dd')];
disp(versionStrTrain)
versionStrMdl   = ['loraFitRNN_Mdl_' datestr(today,'yyyy_mm_dd')];
disp(versionStrMdl)
display(newline)


for nodeIndex = 1:length(loraIDs)

    loraID    = loraIDs{nodeIndex};
    
    % if file Exists was recorded 
    fileName  =  strcat(loraMatsFolder,...
                           "/loraMints_",...
                            loraID ,...
                            ".mat");

    if isfile(fileName)
        load(fileName);
    else
       display(strcat("No Data Exists for Node: ",loraID)); 
       continue;
    end
    
    
    loraData   = rmmissing(mintsData,'MinNumMissing',width(mintsData)-1);    
    
    %% Check points  

        
    % if enough data was recorded 
    if (height(loraData)<100)
       display(strcat("Not enough Data points for Node: ",loraID));
       continue 
    end    
    
    
    % if GPS was recorded 
    if (all(isnan((loraData.Latitude))))
       display(strcat("No GPS Data for Node: ",loraID));
       continue 
    end    
    
    % Cleaning Data 
    display("Removing GPS Data")
    loraData    =  rmmissing(removevars(loraData, {...    
                                'Latitude'  ,...
                                'Longitude',...
                                'gpsTime'}));  
                            
     if (height(loraData)<100)
       display(strcat("Not enough Data points for Node: ",loraID," after cleaning"));
       continue 
    end    
  
    
    loraWithTargets =  rmmissing(synchronize(loraData,palasWithAirmar,'intersection'));
  
                                                                  
    %% Geo Bound LoRa Nodes 
    % WSTC Coordinates - Only For Training Purposes
    % ideally It best we use Lora GPS Coordinates - However in most LoRa
    % nodes the GPS values are not recorded all the time. This is mainly
    % due to limitations in power. As such on the YAML file add
    % a deployment date so that any node data coming field deploymenst are 
    % not used for calibration. 
    
    deployed = isfield(deployments, strcat('x',loraID));
    
    if(deployed)
        display("Delete data from deployment stages for Lora Node: "+loraID)
        evalString = strcat("deployDate =  datetime(deployments.x",loraID,",'timezone','utc');");
        eval(evalString);
        loraWithTargets(loraWithTargets.dateTime>deployDate,:) = [];   
    else
        display("Lora Node: "+loraID + " not yet deployed in the field" )
    end
      
    display("Save merged data for calibration: "+loraID )
    fileNameStr = strcat(mergedMatsFolder,"/loraWithTargets_", loraID,".mat");
    folderCheck(fileNameStr)
    save(fileNameStr,...
            'loraWithTargets')                 
    
    %% Creating Training Data for calibration
    display(newline)
    display("Creating Training Data Sets for Node: "+ loraID )  
    
    for targetIndex = 1: length(mintsTargets)              
        target = mintsTargets{targetIndex};
        targetLabel = mintsTargetLabels{targetIndex};

        display(newline)
        display("Gainin Data set for Node "+ loraID + " with target output " + target)  
        [In_Train,Out_Train,...
            In_Validation,Out_Validation,...
                trainingTT, validatingTT,...
                    trainingT, validatingT ] ...
                                    = representativeSampleTT(loraWithTargets,mintsInputs,target,pValid,binsPerColumn,numberPerBin);    

        if(target == "dCn_palas" )
            trainingT(trainingT.dCn_palas == Inf,:) = [];
            In_Train(trainingT.dCn_palas == Inf,:) = [];
            Out_Train(trainingT.dCn_palas == Inf,:) = [];
            In_Validation(validatingT.dCn_palas == Inf,:) = [];
            Out_Validation(validatingT.dCn_palas == Inf,:) = [];
            trainingTT(trainingT.dCn_palas == Inf,:) = [];
            validatingTT(validatingT.dCn_palas == Inf,:) = [];
            trainingT(trainingT.dCn_palas == Inf,:) = [];
            validatingT(validatingT.dCn_palas == Inf,:) = [];
        end                        
                                
        display("Running Regression")
  
        tic     
        Mdl = fitrnn(In_Train,Out_Train);
        display("Training Time: " + toc  + " Seconds")
        
        
        %% Saving Model Files 
        display(strcat("Saving Model Files for Node: ",loraID, "& target :" ,targetLabel));
        modelsSaveNameDaily = getMintsFileNameGeneral(modelsMatsFolder,loraIDs,...
                                    nodeIndex,target,"daily_Mdl")
        folderCheck(modelsSaveNameDaily)
        
        modelsSaveName      = strrep(modelsSaveNameDaily,"daily_Mdl",strcat(versionStrMdl,"/",versionStrMdl))                                                
        folderCheck(modelsSaveName)
        
        save(modelsSaveName,'Mdl',...
                            'mintsInputs',...
                            'mintsInputLabels',...
                            'target',...
                            'targetLabel'...
                             )    
                         
        
        save(modelsSaveNameDaily,'Mdl',...
                            'mintsInputs',...
                            'mintsInputLabels',...
                            'target',...
                            'targetLabel'...
                             )                     
        
             
        trainingSaveNameDaily = getMintsFileNameGeneral(trainingMatsFolder,loraIDs,...
                                    nodeIndex,target,"daily_Train")
        folderCheck(trainingSaveNameDaily)                        
        
        trainingSaveName      = strrep(trainingSaveNameDaily,"daily_Train",strcat(versionStrTrain,"/",versionStrTrain))                        
        folderCheck(trainingSaveName) 
        
        
        
        save(trainingSaveNameDaily,...
                 'Mdl',...
                 'In_Train',...
                 'Out_Train',...
                 'In_Validation',...
                 'Out_Validation',...
                 'trainingTT',...
                 'validatingTT',...
                 'trainingT',...
                 'validatingT',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'target',...
                 'targetLabel',...
                 'loraID',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'binsPerColumn',...
                 'numberPerBin',...
                 'pValid' ...
             )                        
                                
        save(trainingSaveName,...
                 'Mdl',...
                 'In_Train',...
                 'Out_Train',...
                 'In_Validation',...
                 'Out_Validation',...
                 'trainingTT',...
                 'validatingTT',...
                 'trainingT',...
                 'validatingT',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'target',...
                 'targetLabel',...
                 'loraID',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'binsPerColumn',...
                 'numberPerBin',...
                 'pValid' ...
             )
        
        
        
        
        
        
        %% Estimating Statistics 
        outTrainEstimate=predictrnn(Mdl,In_Train);
        outValidEstimate=predictrnn(Mdl,In_Validation);
       
        
        
        
        
        %% Visual Analysis
        
        display(newline);
        combinedFigDaily   = getMintsFileNameFigure(plotsFolder,loraIDs,nodeIndex,target,"daily_Train");
        folderCheck(combinedFigDaily) 
        
        combinedFig        = strrep(combinedFigDaily,"daily_Train",strcat(versionStrTrain,"/",versionStrTrain)) 
        folderCheck(combinedFig) 
        
        drawScatterPlotMintsCombinedLimitsLora(Out_Train,...
                                         outTrainEstimate,...
                                         Out_Validation,...
                                         outValidEstimate,...
                                         limitsLow{targetIndex},...
                                         limitsHigh{targetIndex},...
                                         loraID,...
                                         targetLabel,...
                                         instruments{targetIndex},...
                                         "Lora Node",...
                                         units{targetIndex},...
                                         combinedFigDaily); 
        
        drawScatterPlotMintsCombinedLimitsLora(Out_Train,...
                                         outTrainEstimate,...
                                         Out_Validation,...
                                         outValidEstimate,...
                                         limitsLow{targetIndex},...
                                         limitsHigh{targetIndex},...
                                         loraID,...
                                         targetLabel,...
                                         instruments{targetIndex},...
                                         "Lora Node",...
                                         units{targetIndex},...
                                         combinedFig); 


            clearvars -except...
                   plotsFolder limitsLow limitsHigh units instruments....
                   palasWithAirmar deployments ...  
                   loraIDs loraID loraWithTargets loraMatsFolder...
                   versionStrTrain versionStrMdl ...
                   rawMatsFolder mergedMatsFolder ...
                   trainingMatsFolder modelsMatsFolder...
                   nodeIDs nodeIndex nodeID ...
                   mintsInputs mintsInputLabels ...
                   mintsTargets mintsTargetLabels targetIndex ...
                   binsPerColumn numberPerBin pValid 

            close all

        end %Targets 
    
end   


function [In_Train,Out_Train,...
            In_Validation,Out_Validation,...
               trainingTT, validatingTT,...
                trainingT, validatingT ] ...
                            = representativeSampleSimpleTT(timeTableIn,inputVariables,target,pvalid)

    [trainInd,valInd,testInd] = dividerand(height(timeTableIn),1-pvalid,0,pvalid);

    tableIn  =  timetable2table(timeTableIn);            
    In       =  table2array(tableIn(:,inputVariables));
    Out      =  table2array(tableIn(:,target)); 

    In_Train       = In(trainInd,:);
    In_Validation  = In(testInd,:);

    Out_Train      = Out(trainInd);
    Out_Validation = Out(testInd);           

    trainingTT     = timeTableIn(trainInd ,[{inputVariables{:},target}]);
    validatingTT   = timeTableIn(testInd  ,[{inputVariables{:},target}]);

    trainingT          = timetable2table(trainingTT);
    validatingT        = timetable2table(validatingTT);

    trainingT.dateTime   = [];
    validatingT.dateTime = [];   
    
    
    

end





function currentFileName = getMintsFileNameTraining(folder,nodeIDs,nodeIndex,...
                                                            target,stringIn)
        nodeDataFolder      = folder+ "/"+nodeIDs(nodeIndex);
        currentFileName     = nodeDataFolder+"/"+stringIn + "_" +...
                                    nodeIDs(nodeIndex)+ "_" + ...
                                          target +"_"+...
                                              ".mat";
                                          
    if ~exist(fileparts(currentFileName), 'dir')
       mkdir(fileparts(currentFileName));
    end
end


function TT = gpsCropCoord(TT,latitude,longitude,latRange,longRange)
    
    TT= TT(TT.latitudeCoordinate>latitude-abs(latRange),:);
    TT= TT(TT.latitudeCoordinate<latitude+abs(latRange),:);
    TT= TT(TT.longitudeCoordinate>longitude-abs(longRange),:);
    TT= TT(TT.longitudeCoordinate<longitude+abs(longRange),:);
end




function [] = drawScatterPlotMintsCombinedLimits(...
                                    dataXTrain,...
                                    dataYTrain,...
                                    dataXValid,...
                                    dataYValid,...
                                    limitLow,...
                                    limitHigh,...
                                    nodeID,...
                                    estimator,...
                                    summary,...
                                    xInstrument,...
                                    yInstrument,...
                                    units,...
                                    saveNameFig)
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );

    %% Plot 1 : 1:1
    plot1=plot([limitLow: limitHigh],[limitLow: limitHigh]);
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);
    hold on 

    %% Plot 2 : Training Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXTrain,...
       dataYTrain,...
       ft);
   
    rmseTrain     = rms(dataXTrain-dataYTrain);
    r = corrcoef(dataXTrain,dataYTrain);
    rSquaredTrain=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult);
    set(plot2,'DisplayName','Training Fit','LineWidth',2,'Color',[0 0 .7]);  
    
    %% Plot 3 Traning Data 
    % Create plot
    plot3 = plot(...
         dataXTrain,...
         dataYTrain)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 1]);
    
    %% Plot 4 : Testing Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXValid,...
       dataYValid,...
       ft);
   
    rmseValid     = rms(dataXValid-dataYValid);
    r = corrcoef(dataXValid,dataYValid);
    rSquaredValid=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot4 = plot(fitresult)
    set(plot4,'DisplayName','Testing Fit','LineWidth',2,'Color',[1 0 0]);  
    
    %% Plot 5 Validating Data 
    % Create plot
    plot5 = plot(...
         dataXValid,...
         dataYValid);
    set(plot5,'DisplayName','Testing Data','Marker','o',...
        'LineStyle','none','Color',[1 0 0]);
    
     %% Plot 6 : Combined Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
    dataXAll = [dataXTrain;dataXValid];
    dataYAll = [dataYTrain;dataYValid];
    
    [fitresult, gof] = fit(...
       dataXAll,...
       dataYAll,...
       ft);
   
    rmse     = rms(dataXAll-dataYAll);
    r = corrcoef(dataXAll,dataYAll);
    rSquared=r(1,2)^2;

    plot6 = plot(fitresult)
    set(plot6,'DisplayName','Combined Fit','LineWidth',2,'Color',[0 0 0]);  
    
   
    %% Labels 
   
    yl=strcat(yInstrument,'~=',string(fitresult.p1),'*',xInstrument,'+',string(fitresult.p2)," (",units,")");
    ylabel(yl,'FontWeight','bold','FontSize',10);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title= strcat("R^2 = ", string(rSquared),...
                        ", RMSE = ",string(rmse),...
                         ", N = ",string(length(dataXAll)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Uncomment the following line to preserve the X-limits of the axes
    xlim([limitLow, limitHigh]);
    % Uncomment the following line to preserve the Y-limits of the axes
    ylim([limitLow, limitHigh]);
    box('on');
    axis('square');

    % Create legend
    legend1 = legend('show');
    set(legend1,'Location','northwest');
   
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
   
    Fig_name =strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end


function [] = drawScatterPlotMintsLimits(dataX,...
                                    dataY,...
                                    limitLow,...
                                    limitHigh,...
                                    nodeID,...
                                    estimator,...
                                    summary,...
                                    xInstrument,...
                                    yInstrument,...
                                    units,...
                                    saveNameFig)
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );


    plot1=plot([limitLow: limitHigh],[limitLow: limitHigh])
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);

    hold on 

    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];

    

     
    [fitresult, gof] = fit(...
       dataX,...
       dataY,...
       ft);
   
    rmse     = rms(dataX-dataY);
    r = corrcoef(dataX,dataY);
    rSquared=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult)
    set(plot2,'DisplayName','Fit','LineWidth',2,'Color',[0 0 1]);

    
    
    
    % Create plot
    plot3 = plot(...
         dataX,...
         dataY)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 0]);
    
    
    
    
    yl=strcat(yInstrument,'~=',string(fitresult.p1),'*',xInstrument,'+',string(fitresult.p2)," (",units,")");
    ylabel(yl,'FontWeight','bold','FontSize',10);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title= strcat("R^2 = ", string(rSquared),...
                        ", RMSE = ",string(rmse),...
                         ", N = ",string(length(dataX)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Uncomment the following line to preserve the X-limits of the axes
    xlim([limitLow, limitHigh]);
    % Uncomment the following line to preserve the Y-limits of the axes
    ylim([limitLow, limitHigh]);
    box('on');
    axis('square');
    % Create legend
    legend1 = legend('show');
    set(legend1,'Location','northwest');


    
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
   
    Fig_name =strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end

function [] = drawPredictorImportaince(regressionTree,yLimit,...
                                        estimator,variableNames,nodeID,...
                                         figNamePre)
%GETPREDICTORIMPORTAINCE Summary of this function goes here
%   Detailed explanation goes here

imp = 100*(regressionTree.predictorImportance/sum(regressionTree.predictorImportance));

xLimit = max(imp)+5;

[sortedImp,isortedImp] = sort(imp,'descend');

   figure_1= figure('Tag','PREDICTOR_IMPORTAINCE_PLOT',...
        'NumberTitle','off',...
        'units','pixels',...   
        'OuterPosition',[0 0 2000 1300],...
        'Name','predictorImportance',...
        'Visible','off'...
    )



barh(imp(isortedImp));hold on ; grid on ;
set(gca,'ydir','reverse');
xlabel('Scaled Importance(%)','FontSize',20);
ylabel('Predictor Rank','FontSize',20);
   % Create title
    Top_Title=strcat(estimator," - Predictor Importaince Estimates")
    Middle_Title = strcat("Node " +string(nodeID))
    title({Top_Title;Middle_Title},'FontSize',21);

% title('Predictor Importaince Estimates')
ylim([.5 (yLimit+.5)]);
yticks([1:1:yLimit])
xlim([0 (xLimit)]);
xticks([0:1:xLimit])

% sortedPredictorLabels= regressionTree.PredictorNames(isortedImp);

sortedPredictorLabels= variableNames(isortedImp);

    for n = 1:yLimit
        text(...
            imp(isortedImp(n))+ 0.05,n,...
            sortedPredictorLabels(n),...
            'FontSize',15 , 'Interpreter', 'tex'...
            )
    end
%     
    Fig_name = strcat(figNamePre,'.png');
    saveas(figure_1,char(Fig_name));
    Fig_name = strcat(figNamePre,'.fig');
    saveas(figure_1,char(Fig_name));

    
end




function [] = drawScatterPlotMintsCombined(...
                                    dataXTrain,...
                                    dataYTrain,...
                                    dataXValid,...
                                    dataYValid,...
                                    limit,...
                                    nodeID,...
                                    estimator,...
                                    summary,...
                                    xInstrument,...
                                    yInstrument,...
                                    units,...
                                    saveNameFig)
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );

    %% Plot 1 : 1:1
    plot1=plot([1: limit],[1: limit]);
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);
    hold on 

    %% Plot 2 : Training Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXTrain,...
       dataYTrain,...
       ft);
   
    rmseTrain     = rms(dataXTrain-dataYTrain);
    r = corrcoef(dataXTrain,dataYTrain);
    rSquaredTrain=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult);
    set(plot2,'DisplayName','Training Fit','LineWidth',2,'Color',[0 0 .7]);  
    
    %% Plot 3 Traning Data 
    % Create plot
    plot3 = plot(...
         dataXTrain,...
         dataYTrain)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 1]);
    
    %% Plot 4 : Testing Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXValid,...
       dataYValid,...
       ft);
   
    rmseValid     = rms(dataXValid-dataYValid);
    r = corrcoef(dataXValid,dataYValid);
    rSquaredValid=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot4 = plot(fitresult)
    set(plot4,'DisplayName','Testing Fit','LineWidth',2,'Color',[1 0 0]);  
    
    %% Plot 5 Validating Data 
    % Create plot
    plot5 = plot(...
         dataXValid,...
         dataYValid);
    set(plot5,'DisplayName','Testing Data','Marker','o',...
        'LineStyle','none','Color',[1 0 0]);
    
     %% Plot 6 : Combined Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
    dataXAll = [dataXTrain;dataXValid];
    dataYAll = [dataYTrain;dataYValid];
    
    [fitresult, gof] = fit(...
       dataXAll,...
       dataYAll,...
       ft);
   
    rmse     = rms(dataXAll-dataYAll);
    r = corrcoef(dataXAll,dataYAll);
    rSquared=r(1,2)^2;

    plot6 = plot(fitresult)
    set(plot6,'DisplayName','Combined Fit','LineWidth',2,'Color',[0 0 0]);  
    
   
    %% Labels 
   
    yl=strcat(yInstrument,'~=',string(fitresult.p1),'*',xInstrument,'+',string(fitresult.p2)," (",units,")");
    ylabel(yl,'FontWeight','bold','FontSize',10);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title= strcat("R^2 = ", string(rSquared),...
                        ", RMSE = ",string(rmse),...
                         ", N = ",string(length(dataXAll)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Uncomment the following line to preserve the X-limits of the axes
    xlim([0  limit]);
    % Uncomment the following line to preserve the Y-limits of the axes
    ylim([0  limit]);
    box('on');
    axis('square');

    % Create legend
    legend1 = legend('show');
    set(legend1,'Location','northwest');
   
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
   
    Fig_name =strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end


function [] = drawScatterPlotMints(dataX,...
                                    dataY,...
                                    limit,...
                                    nodeID,...
                                    estimator,...
                                    summary,...
                                    xInstrument,...
                                    yInstrument,...
                                    units,...
                                    saveNameFig)
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );


    plot1=plot([1: limit],[1: limit])
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);

    hold on 

    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];

    

     
    [fitresult, gof] = fit(...
       dataX,...
       dataY,...
       ft);
   
    rmse     = rms(dataX-dataY);
    r = corrcoef(dataX,dataY);
    rSquared=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult)
    set(plot2,'DisplayName','Fit','LineWidth',2,'Color',[0 0 1]);

    
    
    
    % Create plot
    plot3 = plot(...
         dataX,...
         dataY)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 0]);
    
    
    
    
    yl=strcat(yInstrument,'~=',string(fitresult.p1),'*',xInstrument,'+',string(fitresult.p2)," (",units,")");
    ylabel(yl,'FontWeight','bold','FontSize',10);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title= strcat("R^2 = ", string(rSquared),...
                        ", RMSE = ",string(rmse),...
                         ", N = ",string(length(dataX)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Uncomment the following line to preserve the X-limits of the axes
    xlim([0  limit]);
    % Uncomment the following line to preserve the Y-limits of the axes
    ylim([0  limit]);
    box('on');
    axis('square');
    % Create legend
    legend1 = legend('show');
    set(legend1,'Location','northwest');


    
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
   
    Fig_name =strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end




