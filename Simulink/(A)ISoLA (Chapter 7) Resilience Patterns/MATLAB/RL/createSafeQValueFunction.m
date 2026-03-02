function critic = createSafeQValueFunction(model, observationInfo, actionInfo, shield, nameValueArgs)
% RLQVALUEFUNCTION creates a scalar state-action value function 
% approximator object for reinforcement learning agents.
%
% * Deep Neural Network
%
%       CRITIC = RLQVALUEFUNCTION(NET,OINFO,AINFO)
%       creates a state-action value function approximator object using the deep 
%       neural network, NET, from Deep Learning Toolbox as well as 
%       observation and action specifications OINFO and AINFO, 
%       respectively. 
%       NET must have both observations and actions as inputs, and a single 
%       scalar output.
%       Observation and action input names are automatically populated 
%       based on the dimension specification from OINFO and AINFO.
%
%       CRITIC = RLQVALUEFUNCTION(NET,OINFO,AINFO,'ObservationInputNames',ONAMES,'ActionInputNames',ANAMES)
%       creates a single-output state-action value function approximator object
%       using deep neural network NET, as well as observation and action 
%       specifications OINFO and AINFO, respectively. 
%       Specify the network input layer names, ONAMES, associated with each 
%       observation specification as a string array. The names in ONAMES must
%       be in the same order as OINFO.
%       Specify the network input layer names, ANAMES, associated with each 
%       action specification as a string array. The names in ANAMES must be 
%       in the same order as AINFO.
%
%       E.g. 2-channel observation single channel state-action function
%                      +-------+
%         o1 --------->|       |
%         o2 --------->|   Q   |--------> Q([o1,o2],a)
%         a  --------->|       |
%                      +-------+
%
%       Example of a q-value function deep neural network
%       obsInfo = rlNumericSpec([4 1]);
%       actInfo = rlFiniteSetSpec([-1 0 1]);
% 
%       obsInput = [
%           featureInputLayer(4, 'Normalization', 'none', 'Name', 'obs')
%           fullyConnectedLayer(8, 'Name', 'fc1')];
%       actionInput = [
%           featureInputLayer(1, 'Normalization', 'none', 'Name', 'action')
%           fullyConnectedLayer(8, 'Name', 'fc2')];
%       concatPath = [
%           concatenationLayer(1, 2, 'Name', 'concat')
%           fullyConnectedLayer(1, 'Name', 'qValue')];
%       net = layerGraph();
%       net = addLayers(net, obsInput);
%       net = addLayers(net, actionInput);
%       net = addLayers(net, concatPath);
%       net = connectLayers(net,'fc1','concat/in1');
%       net = connectLayers(net,'fc2','concat/in2');
%       net = dlnetwork(layerGraph(net));
%       critic = rlQValueFunction(net, obsInfo, actInfo, 'ObservationInputNames', 'obs');
%
% * Table
%
%       CRITIC = RLQVALUEFUNCTION(TABLE,OINFO,AINFO)
%       creates a state value function approximator object using table model
%       TABLE, as well as observation and action specifications OINFO and 
%       AINFO, respectively. 
%       TABLE is an rlTable object that contains a vector with as many 
%       elements as the number of possible observations plus the number of 
%       possible actions. To create TABLE, use rlTable.
%
% * Basis function
%
%       CRITIC = RLQVALUEFUNCTION({BASISFCN,W0},OINFO,AINFO)
%       creates a a state-action value approximator object using the custom basis
%       function handle BASISFCN, the initial parameter values vector W0,
%       as well as observation and action specifications OINFO and AINFO,
%       respectively. 
%       The scalar Q-function f must be such that f = W'*B
%       where B is the column vector returned from B =
%       BASISFCN(obs1,...,obsN,act1,...actM), where obs1 to obsN are
%       defined by OINFO and act1 to actM are defined by AINFO. 
%       BASISFCN is a function handle.
%       W0 is the initial parameters, a column vector of size [(nB+nA) x 1]
%       where nB is the number of elements in B and nA is the number of 
%       possible actions.
%
%   For any previous syntax, you can specify whether to use CPU or GPU with 
%   the following name-value pair. USEDEVICE can be "cpu" or "gpu".
%
%       CRITIC = RLQVALUEFUNCTION(...,"UseDevice",USEDEVICE)

% Copyright 2021-2023 The MathWorks, Inc.

arguments
    model
    observationInfo (:,1) rl.util.RLDataSpec
    actionInfo (1,1) rl.util.RLDataSpec
    shield
    nameValueArgs.ObservationInputNames string = string.empty
    nameValueArgs.ActionInputNames string = string.empty
    nameValueArgs.UseDevice (1,1) string {mustBeMember(nameValueArgs.UseDevice,["cpu","gpu"])} = "cpu"
end

rl.internal.validate.validateModelType(model);

inputSize = [];
outputSize = [];

if iscell(model)
    % basis function
    basisFunction = model{1};
    if ~isa(basisFunction,'function_handle')
        error(message('rl:agent:errInvalidInputBasisModel'));
    end
    numModelInputChannel = nargin(basisFunction);
    switch numModelInputChannel
        case numel(observationInfo) + numel(actionInfo)
            % single output Q
            inputSize = {observationInfo.Dimension actionInfo.Dimension};
            outputSize = {[1 1]};
        otherwise
            error(message('rl:agent:errQValueInvalidNumInputBasisModel'));
    end
end

% create internal model
model = rl.internal.model.createInternalModel(model, nameValueArgs.UseDevice, inputSize, outputSize);

% mapping validation
% number of observation info + action info must = number of input layers
networkInputSize = getSize(model,"input");
if (numel(observationInfo) + numel(actionInfo)) ~= numel(networkInputSize)
    error(message('rl:function:errQValueFcnNumInfoNeqNumNetInput'))
end
modelInputMap = [];
if isa(model,'rl.internal.model.DLNetworkModel')
    externalModel = getExternalModel(model);
    networkInputNames = string(externalModel.InputNames);
    spec = [observationInfo(:); actionInfo(:)];
    specDim = {spec.Dimension};
    numSpec = numel(spec);
    % if ObservationInputNames not specified, get automatically from dlnetwork
    % or error and suggest using nvp
    if isempty(nameValueArgs.ObservationInputNames) || isempty(nameValueArgs.ActionInputNames)
        % if multi channel
        if rl.internal.validate.anySameInputSize(specDim)
            error(message('rl:function:errQValueFcnMustSpecifyObsNames'))
        else
            inputOrder = rl.internal.validate.mapNetworkInput(specDim,networkInputSize);
            modelInputMap.Observation = networkInputNames(inputOrder(1:numel(observationInfo)));
            modelInputMap.Action = networkInputNames(inputOrder(numel(observationInfo)+1:numSpec));
        end
    else
        modelInputMap.Observation = nameValueArgs.ObservationInputNames;
        modelInputMap.Action = nameValueArgs.ActionInputNames;

        numInput = numel(networkInputSize);
        inputOrder = zeros(1,numInput);

        % compute input order
        for inputIdx = 1:numSpec
            positionObs = find(modelInputMap.Observation==networkInputNames(inputIdx));
            positionAct = find(modelInputMap.Action==networkInputNames(inputIdx));
            if ~isempty(positionObs)
                inputOrder(inputIdx) = positionObs;
            elseif ~isempty(positionAct)
                inputOrder(inputIdx) = numel(observationInfo) + positionAct;
            else
                expectedNames = sprintf('"%s", ', string([modelInputMap.Observation, modelInputMap.Action]));
                expectedNames = strip(strtrim(expectedNames),"right",",");
                error(message('rl:function:errObsAtNamesDNNInputNotMatch',expectedNames));
            end
        end
    end
    if numel(observationInfo) ~= numel(modelInputMap.Observation)
        error(message('rl:function:errNumObservationNameNotEqNumObsInfo'));
    end
    if numel(actionInfo) ~= numel(modelInputMap.Action)
        error(message('rl:function:errNumActionNameNotEqNumActInfo'));
    end

    % check if each output channel of the model has compatible size
    % with data specs dimension
    InputDataDimension = {observationInfo.Dimension actionInfo.Dimension};
    InputDataDimension = InputDataDimension(inputOrder);
    ModelInputSize = reshape(networkInputSize,size(InputDataDimension));
    if ~all(cellfun(@(x,y) rl.util.isArrayEqual(x,y), ModelInputSize, InputDataDimension))
        error(message('rl:agent:errIncompatibleModelInputDim'));
    end
end

% construct function
critic = shieldedQValueFunction(model, observationInfo, actionInfo, modelInputMap, shield);
end