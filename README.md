# moco MATLAB

moco is a fast motion-correction algorithm for calcium imaging videos [1]. This algoritm is available as a plugin for ImageJ and an implementation for MATLAB is presented here. moco utilizes dynamic programming and fast Fourier transformation-based 2D convolution that reduce required time and complexity of the computation of a weigted $L_2$ norm difference matrix between a "template" and a stack image.

## References

[1] Dubbs A, Guevara J and Yuste R (2016) moco: Fast Motion Correction for Calcium Imaging. Front. Neuroinform. 10:6. doi: [10.3389/fninf.2016.00006](https://doi.org/10.3389/fninf.2016.00006)
