

#include <opencv2/opencv.hpp>
#include "mex.h"
#include "opencv_matlab.hpp"


void 
mexFunction(int nlhs, mxArray *plhs[], 
            int nrhs, const mxArray *prhs[])
{
   
    //validate input
    if (nrhs == 0)
    {
        mexErrMsgTxt("An image is required!");
    }
    if (nlhs != 1)
    {
        mexErrMsgTxt("Only two output is provided.");
    }
    if(!mxIsDouble(prhs[0]) || ((mxGetNumberOfDimensions(prhs[0]) != 3) && (mxGetNumberOfDimensions(prhs[0]) != 2)))
    {
        mexErrMsgTxt("Type of the image has to be double.");
    }
    
    // determine input/output image properties
    const mwSize *dimsA    = mxGetDimensions(prhs[0]);
    const int nDimsA    = mxGetNumberOfDimensions(prhs[0]);
    const int rowsA     = dimsA[0];
    const int colsA     = dimsA[1];
    const int channelsA = (nDimsA == 3 ? dimsA[2] : 1);
    

    double* pmag =  mxGetPr(prhs[1]);
    int mag = (int)pmag[0];
    // Allocate, copy, and convert the input image
    // @note: input is double
    cv::Mat imgA = cv::Mat::zeros(cv::Size(colsA, rowsA), CV_64F);
    om::copyMatrixToOpencv(mxGetPr(prhs[0]), imgA);
  
    cv::Mat pa = cv::Mat::zeros(imgA.size(), CV_64F);
    
    if (CV_MAJOR_VERSION <3)
    {
        IplImage ipl_a = imgA, ipl_pa = pa;
        cvLogPolar(&ipl_a, &ipl_pa, cvPoint2D32f(imgA.cols >> 1, imgA.rows >> 1), mag);
    }
    else
    {
        cv::logPolar(imgA, pa, cv::Point2f( (float)colsA /2 , (float) rowsA /2), mag,cv::INTER_LINEAR+cv::WARP_FILL_OUTLIERS);
    }
    plhs[0] = mxCreateDoubleMatrix(colsA, rowsA,  mxREAL);
	double* out = mxGetPr(plhs[0]);
     om::copyMatrixToMatlab(pa, out);
//     out[0] = pt.y*180/(imgA.cols >> 1);
//     out[1] = exp( pt.x / mag);
}