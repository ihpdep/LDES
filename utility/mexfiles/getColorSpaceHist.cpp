
//#include <opencv2/opencv.hpp>
#include <math.h>
#include "mex.h"
#include <stdio.h>
#include <string.h>
//#include "opencv_matlab.hpp"

void 
mexFunction(int nlhs, mxArray *plhs[], 
            int nrhs, const mxArray *prhs[])
{
   
    //validate input
    if (nrhs != 2)
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
    
    

    unsigned char *IM = (unsigned char*)mxGetData(prhs[0]);
    int bin = (int)mxGetScalar(prhs[1]);
    mwSize ndim[3];
    ndim[0] = bin;ndim[1] = bin;ndim[2] = bin;
    plhs[0] = mxCreateNumericArray(3, ndim, mxDOUBLE_CLASS,mxREAL);
    double *output = mxGetPr(plhs[0]);
  
    memset(output,0,bin*bin*bin*sizeof(double));
    

    for (int j=0; j<colsA; ++j)
    {
         for (int i=0; i< rowsA; ++i)
         {
             int r=floor(IM[i+rowsA*(j)]/25.6);
             int g=floor(IM[i+rowsA*(j+colsA * 1)]/25.6);
             int b=floor(IM[i+rowsA*(j+colsA * 2)]/25.6);
             int idx = r+bin*(g+bin * b);
             output[idx]++;


         }
    }
    
    
}