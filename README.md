# moco MATLAB

moco is a fast motion-correction approach for calcium imaging videos [1]. This algorithm is available as a plugin for ImageJ and an implementation for MATLAB is presented here. moco utilizes dynamic programming and FFT-based 2D convolution that reduce the time and complexity of the computation of a weigted $L_2$ norm difference matrix between a "template" $b_{i,j}$ and stack images $a_{i,j}$, witn $i = \{1,\cdots,m\}$ and $j = \{1,\cdots,n\}$ ($m$ and $n$ are the height and width of the image, respectively). This matrix is defined as $f_{s,t}$ and the indexes are selected such that $\max(|s|,|t|) < w,$ where $w$ is a input parameter related with the maximum expected displacement ($w < \min(|m|,|n|)$) and is set by the user:

$$f_{s,t} = \frac{1}{Area(D_{s,t})} \sum_{(i,j)\in D_{s,t}} (a_{i+s,j+t} - b_{i,j})^2$$

where $D_{s,t}$ is a set of $(i',j')$, with $1\leq i'+s \leq m$ and $1\leq j'+t \leq n$. Then, the pair $(s,t)$ is selected such that $f_{s,t}$ is minimal.

## References

[1] Dubbs A, Guevara J and Yuste R (2016) moco: Fast Motion Correction for Calcium Imaging. Front. Neuroinform. 10:6. doi: [10.3389/fninf.2016.00006](https://doi.org/10.3389/fninf.2016.00006)
