function rb = radialBasis(val,center,bandwidth)
    rb = -(norm(val-center))^2/(2*bandwidth^2);
    rb = exp(rb);
end