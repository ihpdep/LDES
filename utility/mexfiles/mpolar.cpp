

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
    
//     const int *dimsB    = mxGetDimensions(prhs[1]);
//     const int nDimsB    = mxGetNumberOfDimensions(prhs[1]);
//     const int rowsB     = dimsB[0];
//     const int colsB     = dimsB[1];
//     const int channelsB = (nDimsB == 3 ? dimsB[2] : 1);
    double* pmag =  mxGetPr(prhs[1]);
    int mag = (int)pmag[0];
    // Allocate, copy, and convert the input image
    // @note: input is double
    cv::Mat imgA = cv::Mat::zeros(cv::Size(colsA, rowsA), CV_64F);
    om::copyMatrixToOpencv(mxGetPr(prhs[0]), imgA);
//     
//     cv::Mat imgB = cv::Mat::zeros(cv::Size(colsB, rowsB), CV_64F);
//     om::copyMatrixToOpencv(mxGetPr(prhs[1]), imgB);
//     
    cv::Mat pa = cv::Mat::zeros(imgA.size(), CV_64F);
//     cv::Mat pb = cv::Mat::zeros(imgB.size(), CV_64F);
    IplImage ipl_a = imgA, ipl_pa = pa;
//     IplImage ipl_b = imgB, ipl_pb = pb;
    cvLogPolar(&ipl_a, &ipl_pa, cvPoint2D32f(imgA.cols >> 1, imgA.rows >> 1), mag);
 //   cvCartToPolar();
//     cvLogPolar(&ipl_b, &ipl_pb, cvPoint2D32f(imgB.cols >> 1, imgB.rows >> 1), mag);
    

//     cv::Point2d pt = cv::phaseCorrelate(pa, pb);
    
//     printf("%d Shift %f %f Rotation %f Scale %f \n", mag, pt.x, pt.y, pt.y*180/(imgA.cols >> 1), exp( pt.x / mag) );
   // plhs[0] = mxCreateNumericArray(nDimsA, dimsA, mxDOUBLE_CLASS, mxREAL);
   // om::copyMatrixToMatlab<double>(pa, (double*)mxGetPr(plhs[0]));
     
    plhs[0] = mxCreateDoubleMatrix(colsA, rowsA,  mxREAL);
	double* out = mxGetPr(plhs[0]);
     om::copyMatrixToMatlab(pa, out);
//     out[0] = pt.y*180/(imgA.cols >> 1);
//     out[1] = exp( pt.x / mag);
}