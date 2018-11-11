/**
 * Copyright 2011 B. Schauerte. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are 
 * met:
 * 
 *    1. Redistributions of source code must retain the above copyright 
 *       notice, this list of conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright 
 *       notice, this list of conditions and the following disclaimer in 
 *       the documentation and/or other materials provided with the 
 *       distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR 
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 * DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *  
 * The views and conclusions contained in the software and documentation
 * are those of the authors and should not be interpreted as representing 
 * official policies, either expressed or implied, of B. Schauerte.
 */

/** opencv_matlab
 *  Conversion routines from OpenCV's (interleaved, row-major) images to Matlab 
 *  images (3-D matrices, column-major).
 *
 *  TEMPLATE LIBRARY! Thus, lightweight inclusion in any existing OpenCV project!
 * 
 *  \author B. Schauerte
 *  \email  <schauerte@kit.edu>
 *  \date   2011
 */

#pragma once

#include <cassert>

#include <opencv2/core/core.hpp>

#include "math_common.hpp"

// Matlab-like column-major indexing of 3-D array (be aware of the dimensions: 0<=i<ncols (row) and 0<=j<nrows (column) and - hypothetically - 0<=c<nchannels)
#define _A3D_IDX_COLUMN_MAJOR(i,j,k,nrows,ncols) ((i)+((j)+(k)*ncols)*nrows)
// interleaved row-major indexing for 2-D OpenCV images
//#define _A3D_IDX_OPENCV(x,y,c,mat) (((y)*mat.step[0]) + ((x)*mat.step[1]) + (c))
#define _A3D_IDX_OPENCV(i,j,k,nrows,ncols,nchannels) (((i*ncols + j)*nchannels) + (k))

namespace om // om: opencv-matlab
{
    /**
     * Copy the (image) data from cv::Mat to a Matlab-algorithm compatible (column-major) representation.
     * The information about the image are taken from the OpenCV cv::Mat structure.
     */
    template <typename T>
    inline void
    copyMatrixToMatlab(const cv::Mat& from, T* to)
    {
        assert(from.dims == 2); // =2 <=> 2-D image

        const int dims=from.channels();
        const int rows=from.rows;
        const int cols=from.cols;

        const T* pdata = (T*)from.data;

        for (int c = 0; c < dims; c++)
        {
            for (int x = 0; x < cols; x++)
            {
                for (int y = 0; y < rows; y++)
                {
                    //const T element = pdata[_A3D_IDX_OPENCV(x,y,c,from)];
                    const T element = pdata[_A3D_IDX_OPENCV(y,x,c,rows,cols,dims)];
                    to[_A3D_IDX_COLUMN_MAJOR(y,x,c,rows,cols)] = element;
                }
            }
        }
    }

    /**
     * Copy the (image) data from cv::Mat to a Matlab-algorithm compatible (column-major) representation.
     * The information about the image are taken from the OpenCV cv::Mat structure.
     */
    template <typename T>
    inline void
    copyMatrixFromOpencv(const cv::Mat& from, T* to)
    {
        copyMatrixToMatlab(from,to);
    }

    /** 
     * Copy the (image) data from Matlab-algorithm compatible (column-major) representation to cv::Mat.
     * The information about the image are taken from the OpenCV cv::Mat structure.
     */
    template <typename T>
    inline void
    copyMatrixFromMatlab(const T* from, cv::Mat& to)
    {
        assert(to.dims == 2); // =2 <=> 2-D image

        const int dims=to.channels();
        const int rows=to.rows;
        const int cols=to.cols;
        
        T* pdata = (T*)to.data;

        for (int c = 0; c < dims; c++)
        {
            for (int x = 0; x < cols; x++)
            {
                for (int y = 0; y < rows; y++)
                {
                    const T element = from[_A3D_IDX_COLUMN_MAJOR(y,x,c,rows,cols)];
                    pdata[_A3D_IDX_OPENCV(y,x,c,rows,cols,dims)] = element;
                }
            }
        }
    }

    /** 
     * Copy the (image) data from Matlab-algorithm compatible (column-major) representation to cv::Mat.
     * The information about the image are taken from the OpenCV cv::Mat structure.
     */
    template <typename T>
    inline void
    copyMatrixToOpencv(const T* from, cv::Mat& to)
    {
        assert(to.dims == 2); // =2 <=> 2-D image

        copyMatrixFromMatlab(from,to);
    }

    /**
     * Allocate enough memory to copy the (image) data from the OpenCV mat structure
     */
    template <typename T>
    inline T*
    allocateMatrixFromOpencv(const cv::Mat& mat)
    {
        return new T[mat.channels()*mat.rows*mat.cols];
    }

    /**
     * Get the image dimensions in Matlab-style (size), i.e. [nrows ncols nchannels].
     */
    template <typename T>
    inline void
    getDimensions(const cv::Mat& mat, T* dims)
    {
        dims[0] = mat.rows;
        dims[1] = mat.cols;
        dims[2] = mat.channels();
    }
    
    /**
     * Get the number of dimensions in Matlab-style (3 for multi-channel images and 2 for single-channel images).
     */
    inline int
    getNumberOfDimensions(const cv::Mat& mat)
    {
        assert(mat.dims == 2); // =2 <=> 2-D image

        if (mat.channels() > 1)
            return 3;
        else
            return 2;
    }

    //////////////////////////////////////////////////////////////////////////
    // Some basic algoritms
    //////////////////////////////////////////////////////////////////////////

    /** Calculate the number of elements, where dims is a vector that contains the size of each dimension and ndims is the number of dimensions. */
    template <typename T>
    inline T
    calculateNumberOfElements(const T* dims, const T ndims)
    {
        // calculate the number of elements
        int numel = 1;
        for (int i = 0; i < ndims; i++)
            numel *= dims[i];
        return numel;   
    }

    /** Scale data so that the minimum value in the matrix is range_min and the maximum is range_max (mat2gray) */
    template <typename T>
    inline void
    normalizeRangeOfMatrix(const T* src, T* dst, int ndims, const int* dims, const T range_min = 0, const T range_max = 1)
    {
        int numel = calculateNumberOfElements(dims, ndims);

        T _min(0), _max(0);
        MinMaxArray(src, numel, _min, _max);
        
        // normalize to [0,1]
        for (int i = 0; i < numel; i++)
            dst[i] = _INTERVAL_NORMALIZE(src[i],_min,_max);

        if (range_min != 0 || range_max != 1)
            MulArrayScalar(dst,(range_max - range_min),dst,numel);

        if (range_min != 0)
            DivArrayScalar(dst,range_min,dst,numel);
    }

    /** Convert a uint8 matrix to a double matrix (including conversion from {0,1,...255} to [0,1]). */
    inline void
    im2double(const unsigned char* src, double* dst, int ndims, const int* dims, const double scale = 255.0)
    {
        int numel = calculateNumberOfElements(dims, ndims);

        for (int i = 0; i < numel; i++)
            dst[i] = ((double)src[i]) / scale;
    }

    /** Convert a uint8 matrix to a float matrix (including conversion from {0,1,...255} to [0,1]). */
    inline void
    im2float(const unsigned char* src, float* dst, int ndims, const int* dims, const float scale = 255.0f)
    {
        int numel = calculateNumberOfElements(dims, ndims);

        for (int i = 0; i < numel; i++)
            dst[i] = ((double)src[i]) / scale;
    }

    /** Convert a uint8 matrix to a floating-point matrix (including conversion from {0,1,...255} to [0,1]). */
    template <typename T>
    inline void
    im2fp(const unsigned char* src, T* dst, int ndims, const int* dims, const T scale = 255)
    {
        int numel = calculateNumberOfElements(dims, ndims);
        //std::cout << "numel=" << numel << std::endl;

        for (int i = 0; i < numel; i++)
            dst[i] = ((T)src[i]) / scale;
    }

    /** Convert a (floating-point) matrix to a uint8 matrix (including conversion from [0,1] to {0,1,...255}). */
    template <typename T>
    inline void
    convertFloatMatrixToUint8(const T* src, unsigned char* dst, int ndims, const int* dims, const T scale = 255)
    {
        int numel = calculateNumberOfElements(dims, ndims);

        for (int i = 0; i < numel; i++)
            dst[i] = (unsigned char)(src[i]*scale);
    }
}
