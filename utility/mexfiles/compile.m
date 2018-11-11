% Please change the path for opencv

mex -lopencv_core -lopencv_imgproc -L/usr/local/Cellar/opencv/2.4.13.2/lib -I/usr/local/include/ mexResize.cpp MxArray.cpp
mex -lopencv_core -lopencv_imgproc -L/usr/local/Cellar/opencv/2.4.13.2/lib -I/usr/local/include/ mpolar.cpp
mex -lopencv_core -lopencv_imgproc -L/usr/local/Cellar/opencv/2.4.13.2/lib ...
    -I/usr/local/include/ getColorSpace.cpp
mex -lopencv_core -lopencv_imgproc -L/usr/local/Cellar/opencv/2.4.13.2/lib ...
    -I/usr/local/include/ getColorSpaceHist.cpp