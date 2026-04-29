function methodSpecs = default_method_specs(groupName)
if nargin < 1
    groupName = 'main';
end
switch lower(groupName)
    case 'main'
        names = {'full','uniform_weight','global_only'};
        metrics = {'airm','airm','airm'};
        labels = {'Proposed detector','Uniform-weight variant','Global-pooling variant'};
    case 'ablation'
        names = {'full','uniform_weight','global_only','double_ablation'};
        metrics = {'airm','airm','airm','airm'};
        labels = {'Proposed detector','Without discriminative weighting', ...
            'Without top-local emphasis','Double ablation'};
    case 'geometry_baselines'
        names = {'full','fro_structure_field','euclidean_structure_field'};
        metrics = {'airm','fro','euclidean'};
        labels = {'Proposed detector','Frobenius structure-field baseline', ...
            'Euclidean structure-field baseline'};
    otherwise
        error('Unknown groupName: %s', groupName);
end
methodSpecs = struct([]);
for i = 1:numel(names)
    methodSpecs(i).name = names{i};
    methodSpecs(i).metric = metrics{i};
    methodSpecs(i).label = labels{i};
end
end
