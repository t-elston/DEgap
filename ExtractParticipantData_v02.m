function [AllData] = ExtractParticipantData_v02(DATADIR,experiment)
% extracts the participant data from the excel sheets in DATADIR and puts
% everything together into one big table variable

AllData = table;

FileNames = dir([DATADIR '*.xlsx']);

for f = 1:numel(FileNames)
    RawTable = readtable(FileNames(f).name);
    RawTable.Properties.VariableNames{1} = 'rt';
    
    %*** depending on the version of matlab you have, some variables are
    % read out as either strings or doubles. Here I check and, if necessary,
    % convert strings to doubles. The real extraction begins below.
    
    if ~isnan(str2double(RawTable.rt))
        RawTable.rt = str2double(RawTable.rt);
    end
    
    if ~isnan(str2double(RawTable.imageProbLeft))
        RawTable.imageProbLeft = str2double(RawTable.imageProbLeft);
    end
    
   if ~isnan(str2double(RawTable.imageProbRight))
        RawTable.imageProbRight = str2double(RawTable.imageProbRight);
   end
    
  if contains(experiment,'between')
    
    if ~isnan(str2double(RawTable.D1))
        RawTable.D1 = str2double(RawTable.D1);
    end
    
    if ~isnan(str2double(RawTable.D2))
        RawTable.D2 = str2double(RawTable.D2);
    end
    
    if ~isnan(str2double(RawTable.D3))
        RawTable.D3 = str2double(RawTable.D3);
    end
    
    if ~isnan(str2double(RawTable.E1))
        RawTable.E1 = str2double(RawTable.E1);
    end
    
    if ~isnan(str2double(RawTable.E2))
        RawTable.E2 = str2double(RawTable.E2);
    end
    
    if ~isnan(str2double(RawTable.E3))
        RawTable.E3 = str2double(RawTable.E3);
    end
  end
    
    
    
    if ~isnan(str2double(RawTable.age))
        RawTable.age = str2double(RawTable.age);
    end
    

    % keep track of this file's name 
    ThisName = FileNames(f).name;
    Fname={};
    for t = 1:numel(RawTable(1:end,1))
        Fname{t,1} = ThisName;
    end
    
    % put everything together
    AllData=[AllData; [Fname ,  RawTable(1:end,:)]];
   
end % of cycling through files

% pass the variable names to the table 
AllData.Properties.VariableNames{1} = 'FileName';


return