function sleepdata

% % Program to convert XLSX file data into Matlab matrix for analysis
% % % % PROGRAM NOTES
% % % % % TO DO : 
% % % % % % ( )Enable input of various bin sizes
% % % % % % ( )Create matrixes for each Light or Dark period



% % Load Data from excel file, specify cells to load 

%filename = input('Type Name of excel file to load: ','s');
% binsize = input('Type the size of the bin to analyze. Ex. 1 min:  ')
%data = xlsread(filename,'E2:H50')
% % ((Temporary auto load of file test.xls for testing purposes))
data = xlsread('test.xlsx');
data(:,1:3)=[];
binsize=720;
% % Column (4)Total Sleep duration, sum of (2)NREM and (3)REM sleep into 4th column

data(:,4)= data(:,2)+ data(:,3);


% Analyze the length of the data matrix

datasize= length(data);

% Number of days in the data set

days = datasize/1440;


% % Identify between Sleep and Wake%
% % Column (5) 1 = Wake, 2= Sleep
for n=1:datasize;
    if (data(n,4)<50);
    data(n,5)=1;
    else data(n,5)=2;
    end
    
end


% % (6)Identify major vigilance state
% % Column (6) 1 = Wake, 2 = NREM Sleep, 3 = REM sleep

for n=1:datasize;
    if (data(n,5))==1;
    data(n,6)=1;
    
    else
    data(n,6)=2;
    end
    if (data(n,3))>33;
    data(n,6)=3;
    
    end
    
    
end

% (7)Duration of a bout
% Column (7) length of stage bout
data(:,7)=1;

for n=2:datasize;
    if (data(n,6))==(data(n-1,6));
    data(n,7)=  (data(n-1,7))+1;
    data(n-1,7)=0;
    else data(n,7)= 1;
   
    end
end

% (8) REM sleep onset
% Column (8) Duration of NREM sleep preceeding REM sleep
data(:,8)=0;
for n=1:datasize;
    if (data(n,6))==3;
        if data(n-1,6)==2;
        data(n,8)=data(n-1,7);
        end
   
    end
end

% (9) Vigilance stage transitions
%  Column (9) 1 = WAKE to NREM, 2 = NREM to REM, 3 = REM to NREM, 4 = NREM
%  to WAKE, 5 = REM to WAKE, 6 = WAKE to REM, 7= Wake to Wake, 8 = NREM to
%  NREM, 9 = REM to REM
data(:,9)=0;
for n=2:datasize;
        if (data(n,6) ==2 & (data(n-1,6)==1))
       data(n,9)=1;
        end
        if (data(n,6) ==3 & (data(n-1,6)==2))
       data(n,9)=2;
        end
        if (data(n,6) ==2 & (data(n-1,6)==3))
       data(n,9)=3;
        end
        if (data(n,6) ==1 & (data(n-1,6)==2))
       data(n,9)=4;
        end
        if (data(n,6) ==1 & (data(n-1,6)==3))
       data(n,9)=5;
        end
        if (data(n,6) ==3 & (data(n-1,6)==1))
       data(n,9)=6;
        end
        if (data(n,6) ==1 & (data(n-1,6)==1))
       data(n,9)=7;
        end
        if (data(n,6) ==2 & (data(n-1,6)==2))
       data(n,9)=8;
        end
        if (data(n,6) ==3 & (data(n-1,6)==3))
       data(n,9)=9;
        end
   
end

% Divides entire data matrix into Light or Dark periods for further
% analysis.  (In 1 minute bins, there are 720 minutes for 12 hours)

days = 0:binsize:datasize;
ndays = length(days)-1;


% For each period, 720 datapoints will be analyzed

for m = 1:ndays;
% for m = 1;
    datapoints(1,1) = binsize*(m-1)+1;
    datapoints(1,2) = datapoints(1,1)+719;

% Creates new matrix (rem_onset) to analyze the time of NREM sleep
% preceeding REM sleep. 

rem_onset(:,m) = 0;
ro_length = 1;
    for n=datapoints(1,1):datapoints(1,2);
        if data(n,8)~=0
            rem_onset(ro_length,m)= data(n,8);
            ro_length = ro_length +1;
        end
    end
        

    
% Creates new matrix (da) to analyze the duration in specific sleep stages
% Column 1 = Duration of an individual Wake bout
% Column 2 = Duration of an individual NREM bout
% Column 2 = Duration of an individual REM bout
% 
% sur= duration analysis matrix, analyzes survival of bouts
sur(:,m*3)=0;

dalength= 1;
    for n=datapoints(1,1):datapoints(1,2);
        if data(n,7)~=0
            if data(n,6)==1;
            sur(dalength,(3*m)-2)=data(n,7); 
            dalength=dalength+1;
            end
        end
    end
     
    for n=datapoints(1,1):datapoints(1,2);
    dalength= 1;
        if data(n,7)~=0
            if data(n,6)==2;
            sur(dalength,(3*m)-1)= data(n,7);
            dalength=dalength+1;
            end
        end
        
    end
    
    for n=datapoints(1,1):datapoints(1,2);
    dalength= 1;
        if data(n,7)~=0
            if data(n,6)==3;
            sur(dalength,3*m)=data(n,7);
            dalength=dalength+1;
            end
        end
    end


    
% Setup 'da' matrix = Duration 
% Measures the absolute duration of vigilance states irrespective of
% individual bout length

da(1,1:3) = 0;
dalength=1;
ts(1,1:9)=0;
    for n=datapoints(1,1):datapoints(1,2);
        if data(n,6)==1;
            da(1,1)= da(1,1)+1;
        end
        if data(n,6)==2;
            da(1,2)= da(1,2)+1;
        end
        if data(n,6)==3;
            da(1,3)= da(1,3)+1;
        end
         
        % Vigilance state transitions
        % Create new matrix to assess the transition states in "data" column (9)
        % TS = matrix with 5 columns
        %  1 = WAKE to NREM, 2 = NREM to REM, 3 = REM to NREM, 4 = NREM
        %  to WAKE, 5 = REM to WAKE,  6 = WAKE to REM, 7= Wake to Wake, 8 = NREM to
        %  NREM, 9 = REM to REM
                
        if data(n,9)~=0;
           ts(1,data(n,9))=ts(1,data(n,9))+1;
        end
        
     
       
       

    % add analyzed data to current day matrix
    Sleep_durations(m,:)=da;
    Sleep_transitions(m,:)=ts;
    % =ts
   

    end
end


% Sleep_durations Matrix : Each row is a different Period, Light or Dark
% Column 1 = Wake
% Column 2 = NREM
% Column 3 = REM

Sleep_durations;
% Separate into Light and Dark periods

Light_durations = Sleep_durations(1:2:length(Sleep_durations),:)
Dark_durations = Sleep_durations(2:2:length(Sleep_durations),:)

% Light_data = Sleep_durations(Light,:)
% Dark_data = Sleep_durations(Dark,:)
% Sleep_transitions Matrix : Each row is a different Period, Light or Dark
% Column 1 = WAKE to NREM
% Column 2 = NREM to REM
% Column 3 = REM to NREM
% Column 4 = NREM to WAKE     
% Column 5 = REM to WAKE
% Column 6 = WAKE to REM

sur= sort(sur,'descend')
Light_transitions = Sleep_transitions(1:2:length(Sleep_transitions),:)
Dark_transitions = Sleep_transitions(2:2:length(Sleep_transitions),:)
Light_durations = Sleep_durations(1:2:length(Sleep_durations),:)
Dark_durations = Sleep_durations(2:2:length(Sleep_durations),:)
rem_onset = sort(rem_onset,'descend')
