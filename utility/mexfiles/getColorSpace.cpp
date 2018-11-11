
//#include <opencv2/opencv.hpp>
#include <math.h>
#include "mex.h"
//#include "opencv_matlab.hpp"

void 
mexFunction(int nlhs, mxArray *plhs[], 
            int nrhs, const mxArray *prhs[])
{
   
    //validate input
    if (nrhs != 3)
    {
        mexErrMsgTxt("An image and two rgbhist are required!");
    }
    if (nlhs != 1)
    {
        mexErrMsgTxt("Only one output is provided.");
    }
    if( mxGetNumberOfDimensions(prhs[0]) != 3)
    {
        mexErrMsgTxt("Type of the image has to be color.");
    }
    
    
    // determine input/output image properties!mxIsDouble(prhs[0]) ||
    const mwSize *dimsA    = mxGetDimensions(prhs[0]);
    const int nDimsA    = mxGetNumberOfDimensions(prhs[0]);
    const int rowsA     = dimsA[0];
    const int colsA     = dimsA[1];
    const int channelsA = (nDimsA == 3 ? dimsA[2] : 1);
    
    const mwSize *dimsB    = mxGetDimensions(prhs[1]);
    const int nDimsB    = mxGetNumberOfDimensions(prhs[1]);
    const int rowsB     = dimsB[0];
    const int colsB     = dimsB[1];
    const int channelsB = (nDimsB == 3 ? dimsB[2] : 1);
    
    
    plhs[0] = mxCreateDoubleMatrix(rowsA, colsA, mxREAL);
    double *output = mxGetPr(plhs[0]);
    unsigned char *IM = (unsigned char*)mxGetData(prhs[0]);
    double *PI = mxGetPr(prhs[1]);
    double *PL = mxGetPr(prhs[2]);
    for (int j=0; j<colsA; ++j)
    {
         for (int i=0; i< rowsA; ++i)
         {
             int r=floor(IM[i+rowsA*(j)]/25.6);
             int g=floor(IM[i+rowsA*(j+colsA * 1)]/25.6);
             int b=floor(IM[i+rowsA*(j+colsA * 2)]/25.6);
             int idx = r+rowsB*(g+colsB * b);
             if (PL[idx] > 0)
                 output[i+rowsA*j] = double(PI[idx]) /double(PL[idx]);
             else
                 output[i+rowsA*j] = 0.5;
         }
    }
    
    
}