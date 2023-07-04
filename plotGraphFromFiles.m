function plotGraphFromFiles(matchedString)
    arguments
        matchedString string = ""
    end
    addpath(genpath("./Results"));
    files = dir("./Results");
    
    dirFlags = [files.isdir];
    subDirs = files(dirFlags);
    subDirsNames = {subDirs(3:end).name};
    if ~strcmp(matchedString,"")
        subDirsNames = subDirsNames(contains(subDirsNames, matchedString));
    end
    for i=1:length(subDirsNames)
        subDir = subDirsNames{i};
        plotGraphFromFilesAux(fullfile("./Results",subDir));
    end
end


function plotGraphFromFilesAux(folderPath)
    % plotGraphFromFiles - Plot a graph of (n, log_p) pairs from files in a folder
    %   folderPath: string, optional, path to the folder containing the files (default: "./Results")

    arguments
        folderPath string = "./Results" % Default folder path
    end
    
    addpath(genpath(folderPath));
    
    % Get a list of all files in the folder
    files = dir(fullfile(folderPath, '*.mat'));

    % Initialize arrays to store (n, log_p) pairs
    BEP_Naive_Values = [];
    BEP_MsgPas_Values = [];
    
    BEPind_Naive_Values = [];
    BEPind_MsgPas_Values = [];
    logPValues = [];

    % Variables to extract from the struct in the file
    vars = {"BEP_MsgPas", "BEP_Naive", "log_p", "BEPind_Naive", "BEPind_MsgPas", "maxTrueIterMsgPas", "maxTrueIterNaive"};

    % Iterate over each file in the folder
    for i = 1:numel(files)
        % Load the file and extract the struct
        filePath = fullfile(folderPath, files(i).name);
        data = load(filePath,vars{:});
        
        % Extract the log_p and BEP values from the struct
        logP = data.log_p;
        BEP_Naive = data.BEP_Naive;
        BEP_MsgPas = data.BEP_MsgPas;
        BEPind_MsgPas = data.BEPind_MsgPas;
        BEPind_Naive = data.BEPind_Naive;
        maxTrueIterMsgPas = data.maxTrueIterMsgPas;
        maxTrueIterNaive = data.maxTrueIterNaive;
        disp("with" + logP  + ": maxIterMsgPas : " + maxTrueIterMsgPas + ". maxIterNaive : " + maxTrueIterNaive);
        % Append the values to the arrays
        BEP_Naive_Values = [BEP_Naive_Values, BEP_Naive];
        BEP_MsgPas_Values = [BEP_MsgPas_Values, BEP_MsgPas];
        BEPind_Naive_Values = [BEPind_Naive_Values, BEPind_Naive];
        BEPind_MsgPas_Values = [BEPind_MsgPas_Values, BEPind_MsgPas];
        logPValues = [logPValues, logP];
    end
    
    % Plot the graph
    figure;
    semilogy(logPValues, BEP_Naive_Values);
    hold on
    semilogy(logPValues, BEPind_Naive_Values);
    hold on
    semilogy(logPValues, BEP_MsgPas_Values);
    hold on
    semilogy(logPValues, BEPind_MsgPas_Values);
    xlabel('log_p');
    ylabel('BEP');
    [~,folderName,~] = fileparts(folderPath);
    nameSplitted = strsplit(folderName,"_");
    numIter = nameSplitted(4).extractAfter(1);
    ratio = nameSplitted(5).extractAfter(2);
    ratioUpDown = nameSplitted(5).extract(2);
    assert(any(strcmp(ratioUpDown,["u", "d"])), "ratio needs to be either Up or Down");
    if strcmp(ratioUpDown,"d")
        ratio = 1 / ratio;
    end
    seq1 = nameSplitted(6).extractAfter(2);
    seq2 = nameSplitted(7).extractAfter(2);
    currTitle = "$Iter : " + numIter + ",  \frac{\mathrm{Up}}{\mathrm{Down}} = " + ratio +  ", sequence : [" + seq1 + "," + seq2 + "]$";
    title(currTitle,'Interpreter', 'latex', 'FontSize', 22);
    legend('BEP Naive',  'BEP ind Naive', 'BEP MsgPas', 'BEP ind MsgPas', 'Location', 'northwest');
end