%   K-means Clusturing for segmentation
function myimgkmeanval = myimgkmeans(he)
    lab_he = rgb2lab(he);
    
    ab = lab_he(:,:,2:3);
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);

    nColors = 2;
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
    
    pixel_labels = reshape(cluster_idx,nrows,ncols);
    
    segmented_images = cell(1,2);
    rgb_label = repmat(pixel_labels,[1 1 3]);

    for k = 1:nColors
        color = he;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;
    end
    
    val = segmented_images{2};

%     take 1st 5x5 pixels to check if they are black or not
    first5x5 = val([1:5], [1:5]);
    black5x5 = zeros(5);
    
    if(isequal(first5x5, black5x5) == 0)
        val = imcomplement(val);
    end
    
    val = rgb2gray(val);
    val = im2bw(val);
    
    myimgkmeanval = val;
    
    
    
    
    
    
    
    
