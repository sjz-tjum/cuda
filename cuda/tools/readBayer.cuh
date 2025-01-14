#ifndef READBAYER_CUH
#define READBAYER_CUH


#include<iostream>
#include<ifstream>
#include <cuda_runtime.h>
#include<string>
#include<vector>
#include <opencv2/opencv.hpp>

class readBayer_img
{
private:
    std::string filename;
    int width;
    int height;
    std::vector<unsigned char> Bayer_data;
public:
    __host__ readBayer_img(std::string s=" ",int w=0 ,int h=0)
    {
        filename = s;
        width = w;
        height = h;
    }
   std::vector<unsigned char> readBayerImage();
}

#endif
