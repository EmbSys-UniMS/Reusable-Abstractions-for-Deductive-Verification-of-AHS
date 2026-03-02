function critic = createSafeVectorQValueFunction(model, observationInfo, actionInfo, shield, nameValueArgs)
% RLVECTORQVALUEFUNCTION construct multi-output state-action value function 
% approximator object for discrete action space.
%
% * Deep Neural Network
%
%       CRITIC = RLVECTORQVALUEFUNCTION(NET,OINFO,AINFO)
%       creates a multi-output state-action value function approximator object for 
%       discrete action space using a deep neural network, NET, from Deep 
%       Learning Toolbox, as well as observation and action specifications 
%       OINFO and AINFO, respectively. 
%       NET must have single output layer with as many outputs as the
%       number of possible discrete actions. Observation input names
%       are automatically populated based on the dimension specification 
%       from OINFO.
%
%       CRITIC = RLVECTORQVALUEFUNCTION(NET,OINFO,AINFO,'ObservationInputNames',ONAMES)
%       creates a multi-output state-action value function approximator object
%       using deep neural network, NET, from Deep Learning Toolbox as well 
%       as observation and action specifications OINFO and AINFO, 
%       respectively. 
%       Specify the network input layer names, ONAMES, associated with each 
%       observation specification as a string array. The names in ONAMES must
%       be in the same order as the observation specifications, OINFO.
%
%       E.g. 2-channel observation, 3 discrete actions Q function
%                      +-------+
%         o1 --------->|       |          Q([o1,o2],a1)
%                      |   Q   |--------> Q([o1,o2],a2)
%         o2 --------->|       |          Q([o1,o2],a3)
%                      +-------+
%
%       Example of a vector q-value function deep neural network
%       obsInfo = rlNumericSpec([4 1]);
%       actInfo = rlFiniteSetSpec([-1 0 1]);
% 
%       net = [
%           featureInputLayer(4, 'Normalization', 'none', 'Name', 'state')
%           fullyConnectedLayer(3, 'Name', 'fc')];
%       net = dlnetwork(layerGraph(net));
%       critic = rlVectorQValueFunction(net, obsInfo, actInfo, 'ObservationInputNames', 'state');
%
% * Basis function
%
%       CRITIC = RLVECTORQVALUEFUNCTION({BASISFCN,W0},OINFO,AINFO)
%       creates a a state-action value approximator object using the custom basis
%       function handle BASISFCN, the initial parameter values vector W0,
%       as well as observation and action specifications OINFO and AINFO,
%       respectively. 
%       The scalar Q-function f must be such that f = W'*B
%       where B is the column vector returned from B =
%       BASISFCN(obs1,...,obsN), where obs1 to obsN are
%       defined by OINFO. 
%       BASISFCN is a function handle.
%       W0 is the initial parameters, a column vector of size [nB x nA]
%       where nB is the number of elements in B and nA is the number of 
%       possible actions.
%
%   For any previous syntax, you can specify whether to use CPU or GPU with 
%   the following name-value pair. USEDEVICE can be "cpu" or "gpu".
%
%       CRITIC = RLVECTORQVALUEFUNCTION(...,"UseDevice",USEDEVICE)

% Copyright 2021 The MathWorks, Inc.

arguments
    model
    observationInfo (:,1) rl.util.RLDataSpec
    actionInfo (1,1) rl.util.rlFiniteSetSpec
    shield
    nameValueArgs.ObservationInputNames string = string.empty
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
    % multi output Q
    if numModelInputChannel ~= numel(observationInfo)
        error(message('rl:agent:errVectorQValueInvalidNumInputBasisModel'))
    end
    inputSize = {observationInfo.Dimension};
    if rl.util.isaSpecType(actionInfo, 'continuous')
        error(message('rl:agent:errQContinuousActionMultiOutput'));
    end
    outputSize = {[getNumberOfElements(actionInfo) 1]};
end

% create internal model
model = rl.internal.model.createInternalModel(model, nameValueArgs.UseDevice, inputSize, outputSize);

% mapping validation
modelInputMap = rl.internal.validate.mapFunctionObservationInput(model,observationInfo,nameValueArgs.ObservationInputNames);

% construct function
critic = shieldedVectorQValueFunction(model, observationInfo, actionInfo, modelInputMap, shield);
end