% #########################################################################
% Creates a shared library from a c-monitor
% #########################################################################
function [pathToLib,pathToHeader] = makemonitor(pathToKeYmaeraMonitor, monitorName, outputFolder)

    %save current working directory
    currentFolder = pwd; 
    
    %switch to project root for relative path
    pjRoot = matlab.project.rootProject;
    cd(pjRoot.RootFolder);
    
    %unload monitor library if loaded
    if libisloaded(monitorName)
        unloadlibrary(monitorName)
    end
    
    %add dir for monitorFile if it doesn't already exist
    if ~exist(outputFolder, 'dir')
       mkdir(outputFolder);
    end
    
    %open matlab-interface monitor files, create if necessary
    libName = append(monitorName,'.so');
    headerName = append(monitorName,'.h');
    sourceName = append(monitorName,'.c');
    targetName = append(monitorName,'.so');
    
    pathToHeader = append(outputFolder,'\',headerName);
    pathToSource = append(outputFolder,'\',sourceName);
    
    createLibrarySrcFromMonitor(pathToHeader,pathToSource, pathToKeYmaeraMonitor, headerName);
    
    %create compilation command for *.so
    compilationCommand = append('gcc -shared -o ',libName,' -fPIC ',sourceName);
    %compile in output folder
    cd(outputFolder);
    system(compilationCommand);
    
    pathToLib = append(pwd,'\',targetName);
    pathToHeader = append(pwd,'\',headerName);
    
    %go back to current folder
    cd(currentFolder);
        
    %TODO check and return status
end

function createLibrarySrcFromMonitor(pathToHeader, pathToSource, pathToKeYmaeraMonitor, headerName)
    monitorH = fopen(pathToHeader,'w', 'n', 'US-ASCII');
    monitorC = fopen(pathToSource,'w', 'n', 'US-ASCII');
    
    if monitorH == -1
        error('Author:Function:OpenFile', 'Cannot open file: monitorH');
    end
    
    if monitorC == -1
        error('Author:Function:OpenFile', 'Cannot open file: monitorC');
    end
    
    %include header in c file
    fprintf(monitorC, append('#include "',headerName,'"\n'));
    
    %open KeYmaera monitor file to read
    originalMonitorFile = fopen(pathToKeYmaeraMonitor,'r', 'n', 'US-ASCII');
    
    %discarding first line prevents "stray ‘\32’ in program" error
    fgetl(originalMonitorFile);
    
    % while not end of file
    while ~feof(originalMonitorFile)
        line = fgetl(originalMonitorFile);
        %handle state variables
        if contains(line,'typedef struct state {')
            copyLineToTarget(line,monitorH);
            line = fgetl(originalMonitorFile);
            while ~contains(line,'} state;')
                line = erase(line,"long ");
                copyLineToTarget(line,monitorH);
                %sVar = erase(line,";");
                %statevars{end+1} = sVar;
                line = fgetl(originalMonitorFile);
            end
            copyLineToTarget(line,monitorH);
            line = fgetl(originalMonitorFile);
        end
        %handle parameters
        if contains(line,'typedef struct parameters {')
            copyLineToTarget(line,monitorH);
            line = fgetl(originalMonitorFile);
            while ~contains(line,'} parameters;')
                line = erase(line,"long ");
                copyLineToTarget(line,monitorH);
                %par = erase(line,";");
                %parameters{end+1} = par;
                line = fgetl(originalMonitorFile);
            end
            copyLineToTarget(line,monitorH);
            line = fgetl(originalMonitorFile);
        end
        if contains(line,'int main() {')
            line = fgetl(originalMonitorFile);
            while ~contains(line,'return 0;')
                line = fgetl(originalMonitorFile);%discard next line
            end
            fgetl(originalMonitorFile);%discard }
            line =  fgetl(originalMonitorFile);%discard }
        end
        if(~feof(originalMonitorFile))
        copyLineToTarget(line,monitorC);
        end
    end
    
    % build monitor function:
    monitorDeclaration = append('int HCMonitor(struct state pre,struct state post,struct parameters params)');
    
    % internal call to c-monitor function
    monitorSatisfiedCall = 'return monitorSatisfied(pre, post, &params);';
    
    %print monitor function to file
    fprintf(monitorC,'//automatically generated monitor function for matlab\n');
    fprintf(monitorC,append(monitorDeclaration,' {\n', monitorSatisfiedCall, '\n}\n'));
    
    % Add monitor declaration to header
    fprintf(monitorH,'//automatically generated monitor function for matlab\n');
    fprintf(monitorH, append(monitorDeclaration,';'));

    %close files
    fclose(originalMonitorFile);
    fclose(monitorC);
    fclose(monitorH);
end

%helper functions ...

function str = toCommaSepString(strArray)
    siz = size(strArray);
    string = '';
    for i = 1 : siz(2)
        comma = ',';
        if i == siz(2)
            comma = '';
        end
        string = append(string, strArray{i},comma);
    end
    str = string;
end
 
function array = addSuffix(varArray, suffix)
    if nargin < 2
       suffix = '';
    end
    siz = size(varArray);
    arr = {size(varArray)};
    for i = 1 : siz(2)
        name = getName(varArray,i);
        type = getType(varArray,i);
        str = append(type, ' ', name, suffix);
        arr{i} = str;
    end
    array = arr;
end

function assignments = toStructInitializer(structVars, params)
    siz = size(structVars);
    assignments = {siz(2)};
    for i = 1 : siz(2)
        assignments{i} = append('.',getName(structVars,i),'=',getName(params,i));
    end
end

function name = getName(varArray, i)
        name = varArray{i};
        name = erase(name,' ');
        name = erase(name,'double');
        name = erase(name,'long');
        name = erase(name,'bool');
end

function type = getType(varArray, i)
        name = getName(varArray,i);
        type = erase(varArray{i},name);
        type = erase(type, ' ');
        type = erase(type, 'long');
end 

function copyLineToTarget(line,targetfile)
    siz = size(line);
    for i = 1 : siz(1)
        lineText = line(i,1:end);
        fprintf(targetfile,lineText);
        fprintf(targetfile,'\n');
    end
end