

#include <opencv2/opencv.hpp>
#include "mex.h"
#include "opencv_matlab.hpp"

void 
mexFunction(int nlhs, mxArray *plhs[], 
            int nrhs, const mxArray *prhs[])
{
    // default parameters
    int ksize = 3;
    double sigma = 2.0;

    //validate input
    if (nrhs == 0)
    {
        mexErrMsgTxt("An image is required!");
    }
    if (nlhs != 1)
    {
        mexErrMsgTxt("Only one output is provided.");
    }
    if(!mxIsDouble(prhs[0]) || ((mxGetNumberOfDimensions(prhs[0]) != 3) && (mxGetNumberOfDimensions(prhs[0]) != 2)))
    {
        mexErrMsgTxt("Type of the image has to be double.");
    }
    if((nrhs >= 2)  && ((!mxIsDouble(prhs[1])) || (mxGetScalar(prhs[1]) <= 0)))
    {
        mexErrMsgTxt("ksize has to be a positive integer.");
    } 
    else if (nrhs >= 2)
    {
        ksize = (int) mxGetScalar(prhs[1]);
    }
    if((nrhs >= 3)  && ((!mxIsDouble(prhs[2])) || (mxGetScalar(prhs[2]) <= 0)))
    {
        mexErrMsgTxt("sigma has to be a positive value.");
    } 
    else if (nrhs >= 3)
    {
        sigma = (double) mxGetScalar(prhs[2]);
    }
    
    // determine input/output image properties
    const int *dims    = mxGetDimensions(prhs[0]);
    const int nDims    = mxGetNumberOfDimensions(prhs[0]);
    const int rows     = dims[0];
    const int cols     = dims[1];
    const int channels = (nDims == 3 ? dims[2] : 1);
    
    // Allocate, copy, and convert the input image
    // @note: input is double
    cv::Mat image = cv::Mat::zeros(cv::Size(cols, rows), CV_64FC(channels));
    om::copyMatrixToOpencv(mxGetPr(prhs[0]), image);
    image.convertTo(image, CV_8U, 255);
    
    // Call OpenCV functions here and do the magic
    cv::Mat out = cv::Mat::zeros(cv::Size(cols, rows), CV_8UC(channels));
    cv::GaussianBlur(image,out,cv::Size(ksize,ksize),sigma);
    
    // Convert opencv to Matlab and set as output
    // @note: output is uint8
    plhs[0] = mxCreateNumericArray(nDims, dims, mxUINT8_CLASS, mxREAL);
    om::copyMatrixToMatlab<unsigned char>(out, (unsigned char*)mxGetPr(plhs[0]));
}