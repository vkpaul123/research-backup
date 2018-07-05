clear;
clear all;
clc;
home;

warning('START...');

for k2 = 1:3        %   limit should be 4 not 3. 3 is for leaves only
    errorFile = [];
    errorCount = 0;
    k2 = 3;
    switch (k2)
        case 1
            imageClassName = 'Buds'
            cd '_InputImages\\Buds';
        case 2
            imageClassName = 'Flowers'
            cd '_InputImages\\Flowers';
        case 3
            imageClassName = 'Leaves'
            cd '_InputImages\\Leaves';
        case 4
            imageClassName = 'Thorns'
            cd '_InputImages\\Thorns';
    end
    
    allImgs = dir('*.jpg');
    currFile = 1;
    disp('Listing Files...');
    totalFiles = numel(allImgs);
    for k1 = 1:totalFiles
        disp(allImgs(k1).name);
    end
    totalFiles
    cd ..;
    cd ..;
    
    myDataset = [];
    
    warning(sprintf('\n=============\n\nStarting Pre-Process Now...'));
    
    for k = 1:numel(allImgs)
        try
            disp(sprintf('%d of %d Files...', currFile, totalFiles));
            fileName = allImgs(k).name
            
            switch (k2)
                case 1
                    cd '_InputImages\\Buds';
                case 2
                    cd '_InputImages\\Flowers';
                case 3
                    cd '_InputImages\\Leaves';
                case 4
                    cd '_InputImages\\Thorns';
            end
            
            disp('Read Input Image...');
            im = imread(fileName);
            disp('   Image Reading Done!');
            
            disp('Orienting Image Vertically');
            currImageSize = size(im);
            if(currImageSize(:, 1) < currImageSize(:, 2))
                im = imrotate(im, 90);
            end
            disp('   Orienting Image Vertically Done!');
            
            cd ..;
            cd ..;
            
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
            
            disp('Writing Files...');
            [~, name, ~] = fileparts(fileName);
            normFileName = sprintf('_OutputImages\\%s\\normalized\\%s.jpg', imageClassName, name);
            binFileName = sprintf('_OutputImages\\%s\\binary\\%s.jpg', imageClassName, name);
            segFileName = sprintf('_OutputImages\\%s\\segmented\\%s.jpg', imageClassName, name);
            grayScaleFileName = sprintf('_OutputImages\\%s\\grayscale\\%s.jpg', imageClassName, name);
            histEqFileName = sprintf('_OutputImages\\%s\\histeq\\%s.jpg', imageClassName, name);
            xlsFileName = sprintf('_OutputImages\\%s\\excel\\%s', imageClassName, name);
            largestBlobFileName = sprintf('_OutputImages\\%s\\largestblob\\%s.jpg', imageClassName, name);
            
            imwrite(normalized, normFileName);
            imwrite(clustered, binFileName);
            imwrite(mapped, segFileName);
            imwrite(mapped_gray, grayScaleFileName);
            imwrite(histEqualized, histEqFileName);
            imwrite(largestBlob, largestBlobFileName);
            disp('   Files Written!');
            
            disp('GLCM Haralic Feature Extraction...');
            GLCM2 = graycomatrix(histEqualized);
            stats = GLCM_Features1(GLCM2,0)
            GLCM1 = struct2array(stats);
            GLCM1 = GLCM1';
            xlswrite([xlsFileName, '_GLCM.xlsx'], GLCM1);
            disp('   GLCM Haralic Features Extraction Done!');
            
            disp('Geometrical Feature Extraction');
            geoFeatures = regionprops(largestBlob, 'Area', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Orientation', 'ConvexArea', 'FilledArea', 'EquivDiameter', 'Solidity', 'Extent', 'Perimeter', 'PerimeterOld')
            geoFeatures_Vector = struct2array(geoFeatures);
            xlswrite([xlsFileName, '_Geometrical.xlsx'], geoFeatures_Vector);
            disp('   Geometrical Feature Extraction Done!');
            
            disp('Adding Features to Dataset...');         
            datasetRow_GLCM = reshape(GLCM1, [1,22]);
            datasetRow = [datasetRow_GLCM geoFeatures_Vector 0]
            myDataset = [myDataset; datasetRow];
            disp('   New Row Added!');
        catch
            warning(['Error in Image... ', fileName]);
            subplot(1, 1, 1), imshow(im), title(fileName);
            
            errorFile = [errorFile; [fileName, ', ']];
            errorCount = errorCount + 1;
        end
        
        disp([fileName, ' Done!']);
        disp(sprintf('%d of %d Files Complete!\n\n\n=============', currFile, totalFiles));
        currFile = currFile + 1;
    end
    
    xlswrite(['_OutputImages\\', imageClassName, '\\', imageClassName, '_myDataset_NotKeru.xlsx'], myDataset);
    myDataset(:,35) = [];
%     xlswrite(['_OutputImages\\', imageClassName, '\\', imageClassName, '_descriptor.xlsx'], mean(myDataset));
%     xlswrite(['_OutputImages\\', imageClassName, '\\', imageClassName, '_minVals.xlsx'], min(myDataset));
%     xlswrite(['_OutputImages\\', imageClassName, '\\', imageClassName, '_maxVals.xlsx'], max(myDataset));
    
    disp(sprintf('   Total Errors Occoured... %d', errorCount));
    
    errorFile
end



error('ALL DONE!!!');

