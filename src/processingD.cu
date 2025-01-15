#include<iostream>
#include<stdlib.h>
#include <cuda_runtime.h>
//#include <opencv2/opencv.hpp>

__global__ void Demosaicing_process(unsigned char* padded_bayer_data, unsigned char* bgr_data, int padded_width, int padded_height, int width, int height,int pad_width) {
    int x = blockIdx.x * blockDim.x + threadIdx.x + pad_width;  
    int y = blockIdx.y * blockDim.y + threadIdx.y + pad_width;  

    if (x >= width + pad_width || y >= height + pad_width) return;
    int bayer_idx = y * padded_width + x;
    int bgr_idx = (y - pad_width) * width * 3 + (x - pad_width) * 3;
    unsigned char r, g, b;
    if (x % 2 == 0 && y % 2 == 0) { 
        r = padded_bayer_data[bayer_idx];
        g = (padded_bayer_data[bayer_idx - 1] + padded_bayer_data[bayer_idx + 1] + padded_bayer_data[bayer_idx - padded_width] + padded_bayer_data[bayer_idx + padded_width]) / 4;
        b = (padded_bayer_data[bayer_idx - padded_width - 1] + padded_bayer_data[bayer_idx - padded_width + 1] + padded_bayer_data[bayer_idx + padded_width - 1] + padded_bayer_data[bayer_idx + padded_width + 1]) / 4;
    } else if (x % 2 == 1 && y % 2 == 0) { 
        r = (padded_bayer_data[bayer_idx - 1] + padded_bayer_data[bayer_idx + 1]) / 2;
        g = padded_bayer_data[bayer_idx];
        b = (padded_bayer_data[bayer_idx - padded_width] + padded_bayer_data[bayer_idx + padded_width] + padded_bayer_data[bayer_idx - padded_width - 1] + padded_bayer_data[bayer_idx - padded_width + 1] + padded_bayer_data[bayer_idx + padded_width - 1] + padded_bayer_data[bayer_idx + padded_width + 1]) / 6;
    } else if (x % 2 == 0 && y % 2 == 1) { 
        r = (padded_bayer_data[bayer_idx - padded_width] + padded_bayer_data[bayer_idx + padded_width]) / 2;
        g = padded_bayer_data[bayer_idx];
        b = (padded_bayer_data[bayer_idx - 1] + padded_bayer_data[bayer_idx + 1] + padded_bayer_data[bayer_idx - padded_width - 1] + padded_bayer_data[bayer_idx - padded_width + 1] + padded_bayer_data[bayer_idx + padded_width - 1] + padded_bayer_data[bayer_idx + padded_width + 1]) / 6;
    } else { // B
        r = (padded_bayer_data[bayer_idx - padded_width - 1] + padded_bayer_data[bayer_idx - padded_width + 1] + padded_bayer_data[bayer_idx + padded_width - 1] + padded_bayer_data[bayer_idx + padded_width + 1]) / 4;
        g = (padded_bayer_data[bayer_idx - 1] + padded_bayer_data[bayer_idx + 1] + padded_bayer_data[bayer_idx - padded_width] + padded_bayer_data[bayer_idx + padded_width]) / 4;
        b = padded_bayer_data[bayer_idx];
    }
    bgr_data[bgr_idx] = b;
    bgr_data[bgr_idx + 1] = g;
    bgr_data[bgr_idx + 2] = r;
}