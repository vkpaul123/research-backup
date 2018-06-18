% im = imread('peppers.png');
% im = imread('C:\Users\vkpau\Desktop\_railwayStn\hi\IMG_20180312_173334.jpg');
%
% normalized = comprehensive_colour_normalization(im);
%
% figure;
% imshowpair(im, normalized, 'montage')

clear;
clear all;
clc;

warning('START...');

for k2 = 1:4
    errorFile = [];
    errorCount = 0;
    
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
            
            disp('Writing Files...');
            [~, name, ~] = fileparts(fileName);
            normFileName = sprintf('_OutputImages\\%s\\normalized\\%s.jpg', imageClassName, name);
            binFileName = sprintf('_OutputImages\\%s\\binary\\%s.jpg', imageClassName, name);
            segFileName = sprintf('_OutputImages\\%s\\segmented\\%s.jpg', imageClassName, name);
            grayScaleFileName = sprintf('_OutputImages\\%s\\grayscale\\%s.jpg', imageClassName, name);
            histEqFileName = sprintf('_OutputImages\\%s\\histeq\\%s.jpg', imageClassName, name);
            xlsFileName = sprintf('_OutputImages\\%s\\excel\\%s_GLCM.xlsx', imageClassName, name);
            
            imwrite(normalized, normFileName);
            imwrite(clustered, binFileName);
            imwrite(mapped, segFileName);
            imwrite(mapped_gray, grayScaleFileName);
            imwrite(histEqualized, histEqFileName);
            disp('   Files Written!');
            
            disp('GLCM Haralic Feature Extraction...');
            GLCM2 = graycomatrix(histEqualized, 'Offset', [2 0;0 2]);
            stats = GLCM_Features1(GLCM2,0)
            GLCM1 = cell2mat(struct2cell(stats));
            xlswrite(xlsFileName, GLCM1);
            disp('   GLCM Haralic Features Extraction Done!');
            
            disp('Adding Features to Dataset...');
            GLCM1 = GLCM1';
            
            datasetRow = reshape(GLCM1, [1,44]);
            myDataset = [myDataset; datasetRow];
            disp('   New Row Added!');
            
            %     subplot(2, 2, 1), imshow(im), title('Input');
            %     subplot(2, 2, 2), imshow(normalized), title('Colour Normalized');
            %     subplot(2, 2, 3), imshow(clustered), title('Labeled');
            %     subplot(2, 2, 4), imshow(mapped), title('Segmented');
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
    
    xlswrite(['_OutputImages\\', imageClassName, '\\', imageClassName, '_myDatasetGLCM.xlsx'], myDataset);
    
    disp(sprintf('   Total Errors Occoured... %d', errorCount));
    
    errorFile
end



error('ALL DONE!!!');

