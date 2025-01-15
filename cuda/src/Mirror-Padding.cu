#include<iostream>
#include<stdlib.h>
#include <cuda_runtime.h>
#include <opencv2/opencv.hpp>

void mirrorPadBayerImage(const std::vector<unsigned char>& bayer_data, std::vector<unsigned char>& padded_data, int width, int height, int pad_width) {
    int padded_width = width + 2 * pad_width;
    int padded_height = height + 2 * pad_width;
    padded_data.resize(padded_width * padded_height, 0);
    for (int y = 0; y < height; ++y) 
    {
        for (int x = 0; x < width; ++x) 
        {
            int src_idx = y * width + x;
            int dst_idx = (y + pad_width) * padded_width + (x + pad_width);
            padded_data[dst_idx] = bayer_data[src_idx];
        }
    }
    for (int y = 0; y < pad_width; ++y)
     {
        for (int x = 0; x < padded_width; ++x)
         {
            padded_data[y * padded_width + x] = padded_data[(pad_width * 2 - y - 1) * padded_width + x];
            padded_data[(padded_height - y - 1) * padded_width + x] = padded_data[(padded_height - pad_width * 2 + y) * padded_width + x];
        }
    }
    for (int y = pad_width; y < padded_height - pad_width; ++y) 
    {
        for (int x = 0; x < pad_width; ++x) 
        {
            padded_data[y * padded_width + x] = padded_data[y * padded_width + (pad_width * 2 - x - 1)];
            padded_data[y * padded_width + (padded_width - x - 1)] = padded_data[y * padded_width + (padded_width - pad_width * 2 + x)];
        }
    }
}