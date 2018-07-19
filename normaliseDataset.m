% clear;
% clear all;
% clc;
% home;
%
% keru = xlsread('_OutputImages\Leaves\Leaves_myDataset.xlsx')
% notKeru = xlsread('_OutputImages\Leaves\Leaves_myDataset_NotKeru.xlsx')
%
% keru33 = datasample(keru, 33, 'Replace', false)
% myDataset = [keru33; notKeru]
%
% X = myDataset(:, 1:34)
% Y = myDataset(:, 35)
%==========================================================================

function [meanX, stddevX, rngX, normalized_std_X, normalized_rng_X] = normaliseDataset(X)
    meanX = mean(X);
    stddevX = std(X);
    rngX = max(X) - min(X);

    normalized_std_X = X;
    normalized_rng_X = X;

    rows = numsamples(X');
    cols = numsamples(X);

    for i = 1:rows
        for j = 1:cols
            normalized_std_X(i,j) = (normalized_std_X(i,j) - meanX(j)) / stddevX(j);
            normalized_rng_X(i,j) = (normalized_rng_X(i,j) - meanX(j)) / rngX(j);
        end
    end

    % normalized_std_X
    % normalized_rng_X

end