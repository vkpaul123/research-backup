function mysegmentedimg = mykmeansimgsegmenter(kmeansresultimg, originalimg)

    myresult = originalimg;

    [rows, cols] = size(kmeansresultimg(:,:,1));

    for col = 1:cols
        for row = 1:rows
            if(kmeansresultimg(row, col) == 0)
                myresult(row, col, 1) = 0;
                myresult(row, col, 2) = 0;
                myresult(row, col, 3) = 0;
            else
                myresult(row, col, 1) = originalimg(row, col, 1);
                myresult(row, col, 2) = originalimg(row, col, 2);
                myresult(row, col, 3) = originalimg(row, col, 3);
            end
        end
    end
        
    mysegmentedimg = myresult;