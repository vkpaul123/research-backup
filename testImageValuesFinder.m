clear;
clear all;
clc;
home;

warning('START');

% INSERT IMAGE CLASS NAME...
imageClassName = 'Buds';

% INSERT IMAGE PATH HERE...
disp('Read Input Image...');
im = imread(['Temp\', imageClassName, '\Input\IMG_20180518_142539.jpg']);
disp('   Image Reading Done!');

disp('Orienting Image Vertically');
currImageSize = size(im);
if(currImageSize(:, 1) < currImageSize(:, 2))
    im = imrotate(im, 90);
end
disp('   Orienting Image Vertically Done!');

% try
    disp('Normalize Input Image...');
    normalized = comprehensive_colour_normalization(im);
    disp('   Image Normalization Done!');
    
    disp('Label Using K-means Clustering...');
    clustered = myimgkmeans(normalized);
    disp('   K-means Cluster Labling Done!');
    
    disp('Segment from Original Image...');
    mapped = mykmeansimgsegmenter(clustered, im);
    disp('   Segmentation Done!');
    
    disp('Convert to GrayScale...');
    mapped_gray = rgb2gray(mapped);
    disp('   Converted to GrayScale!');
    
    disp('Histogram Equalization...');
    histEqualized = adapthisteq(mapped_gray);
    disp('   Histogram Equalization Done!');
    
    disp('Finding Largest Blob');
    largestBlob = bwareafilt(clustered, 1);
    largestBlob = imfill(largestBlob, 'holes');
    disp('   Finding Largest Blob Done!');
    
    disp('GLCM Haralic Feature Extraction...');
    GLCM2 = graycomatrix(histEqualized);
    stats = GLCM_Features1(GLCM2,0)
    GLCM1 = struct2array(stats);
    GLCM1 = GLCM1';
    disp('   GLCM Haralic Features Extraction Done!');
    
    disp('Geometrical Feature Extraction');
    geoFeatures = regionprops(largestBlob, 'Area', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Orientation', 'ConvexArea', 'FilledArea', 'EquivDiameter', 'Solidity', 'Extent', 'Perimeter', 'PerimeterOld')
    geoFeatures_Vector = struct2array(geoFeatures);
    disp('   Geometrical Feature Extraction Done!');
    
    disp('Consolidating Features...');
    datasetRow_GLCM = reshape(GLCM1, [1,22]);
    featureSet_Vector = [datasetRow_GLCM geoFeatures_Vector]
    disp('   Features Consolidated!');
    
    disp('Calculating Distance');
    minVals = xlsread([pwd, '\\_OutputImages\\', imageClassName, '\\', imageClassName, '_minVals.xlsx'])
    maxVals = xlsread([pwd, '\\_OutputImages\\', imageClassName, '\\', imageClassName, '_maxVals.xlsx'])
    avgVals = xlsread([pwd, '\\_OutputImages\\', imageClassName, '\\', imageClassName, '_descriptor.xlsx'])
    distanceFromAvg = avgVals - featureSet_Vector
    
    disp('   Calculating Distance Done!');
% catch
%     error('An Error Occoured!');
% end

error('ALL DONE!!!');