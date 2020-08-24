

clc
clear all
close all

display("------ MINTS ------")

addpath("../../functions/")


dataFolder         =  "/media/teamlary/Team_Lary_2/air930/mintsData"

gatewayIDs =  {...
               "b827eb60cd60",...
               "b827eb52fc29",...
               "b827ebf74482",...
               "b827eb70fd4c"};
           

loraIDs= {...
            "475a5fe3002e0023",...
            "475a5fe3002a0019",...
            "475a5fe3003e0023",...
            "475a5fe30031001b",...
            "475a5fe300320019",...
            "475a5fe300380019",...
            "477b41f200290024",...
            "475a5fe3002e001f",...
            "477b41f20047002e",...
            "475a5fe30021002d",...
            "475a5fe30031001f",...
            "475a5fe30028001f",...
            "478b5fe30040004b",...
            "472b544e00250037",...
            "47eb5580003c001a",...
            "47db5580001e0039",...
            "479b558000380033",...
            "472b544e00230033",...
            "478b558000330027",...
            "475a5fe30035001b",...
            "472b544e0024004b",...
            "470a55800048003e",...
            "475a5fe3002a001a",...
            "47cb5580003a001c",...
            "475a5fe300300019",...
            "475a5fe3002e0018",...
            "472b544e0018003d",...
            "476a5fe300220022",...
            "472b544e001b003c",...
            "47bb558000280041",...
            "47db5580002d0043",...
            "477b41f20048001f",...
            "47fb558000450044",...
            "475b41f20037001e",...
            "478b5fe30040004b",...
            "475a5fe30039002a",...
            "479b5580001a0031",...
            "475a5fe3002f001b",...
            "47cb5580002e004a",...
            "471a55800038004e"...
                 };


rawFolder          =  dataFolder + "/raw";
rawDotMatsFolder   =  dataFolder + "/rawMats";
loraMatsFolder     =  rawDotMatsFolder  + "/lora";
display(newline)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawDotMatsFolder)
display("lora DotMat Data Located @ :"+ loraMatsFolder)
display(newline)

%% Syncing Process 

syncFromCloudLora(gatewayIDs,dataFolder)

% going through the lora IDs
for loraIDIndex = 1:length(loraIDs)

    loraID = loraIDs{loraIDIndex};
    allFiles =  dir(strcat(rawFolder,'/*/*/',loraID,'*.csv'));
    
    
    if(length(allFiles) >0)
        loraNodeAll = {};
        display(strcat("Gaining LoRa data for Node: ",loraID))
        for fileNameIndex = 1: length(allFiles)
            loraNodeAll{fileNameIndex} = loraRead(strcat(allFiles(fileNameIndex).folder,"/",allFiles(fileNameIndex).name));
        end     


        display(strcat("Concatinating LoRa data for Node: ",loraID));

        concatStr  =  "mintsDataAll = [";

        for fileNameIndex = 1: length(allFiles)
            concatStr = strcat(concatStr,"loraNodeAll{",string(fileNameIndex),"};");
        end    

        concatStr  =  strcat(concatStr,"];");

        display(concatStr);
        eval(concatStr);

        mintsData = unique(mintsDataAll);

        %% Getting Save Name 
        display(strcat("Saving Lora Data for Node: ", loraID));
        saveName  = strcat(loraMatsFolder,'/loraMints_',loraID,'.mat');
        mkdir(fileparts(saveName));
        save(saveName,'mintsData');
    else
        
       display(strcat("No Data for Lora Node: ", loraID ))
    end
    
    
    clearvars -except loraIDs loraIDIndex rawFolder dataFolder rawDotMatsFolder loraMatsFolder
    
%loraID
end