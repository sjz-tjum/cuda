#ifndef DEMOSAICED_CUH
#define DEMOSAICED_CUH
#include<iostream>
#include<stdlib.h>
#include <cuda_runtime.h>
#include <opencv2/opencv.hpp>

using namespace std;

class Demosaiced_Bayer 
{
private:
    std::vector<unsigned char> BGR_data;
    int bgr_width;
    int bgr_height;
public:
   Demosaicing_Bayer(int w=0,int h=0)
    {
        bgr_width = w;
        bgr_height = h;
    }
}
#endif