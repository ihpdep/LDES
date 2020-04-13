# Robust Estimation of Similarity Transformation for Visual Object Tracking

This is our implementation of the Large Displacement Estimation of Similarity transformation (LDES) tracker. The main idea is to extend the CF-based tracker with similarity transformation (including position, scale, and rotation) in an efficient way. It can be used as a scale estimator with only sampling once in each frame. The code should be easy to follow and reuse. The details can be found in our [AAAI-2019 paper](https://arxiv.org/abs/1712.05231).

Please cite our publication if you use the code
```
@InProceedings{Li2019ldes,
author = {Li, Yang and Zhu, Jianke and Hoi, Steven C.H. and Song, Wenjie and Wang, Zhefeng and Liu, Hantang},
title = {Robust Estimation of Similarity Transformation for Visual Object Tracking},
booktitle = {The Conference on Association for the Advancement of Artificial Intelligence (AAAI)},
month = {January},
year = {2019}
}
```
 
# Instruction
#### To just demo
* Modify the path in "demo.m" with your own setting. (optional)
* Run the "demo.m" script in MATLAB.

#### To run OTB-100 or OTB-2013
* Please indicate "run_ldes.m" as the entry point for OTB.

#### To run VOT evaluation
* Please integrate "run_vot.m" into the toolkit.

#### To run POT evaluation
* Modify the path in "run_pot.m" with your own setting.
* Run "run_pot.m" script in MATLAB.
* Use the result files in POT code to get benchmark results.

# Troubleshooting
If it does not run directly, probably you need to compile the mex files by yourself. Please check the compile.m in ./utility/mexfiles and change the opencv path for your settings. We tested it with opencv 2.4 and 3.4

The most important thing is make sure your OpenCV is working with your MatLab. Try some simple tutorial online if you have some issue with compiling/running.

# Example
![tracking-example][logo]

[logo]: https://github.com/ihpdep/ihpdep.github.io/raw/master/files/example.gif "tracking-example"

# Contact 
* Yang Li, liyang89@zju.edu.cn, http://ihpdep.github.io
* Jianke Zhu, jkzhu@zju.edu.cn, http://jkzhu.github.io
* Steven C.H. Hoi, chhoi@smu.edu.sg, http://stevenhoi.org
