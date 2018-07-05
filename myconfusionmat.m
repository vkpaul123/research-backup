function confmat = myconfusionmat(v, pv)
    yu = unique(v);
    confmat = zeros(length(yu));
    
    for i = 1:length(yu)
        for j = 1:length(yu)
            confmat(i,j) = sum(v==yu(i) & pv==yu(j));
        end
    end
end