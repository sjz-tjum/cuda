#include "readBayer.cuh"
#include<iostream>


std::vector<unsigned char> readBayer_img::readBayerImage(const std::string& filename, int width, int height)
{
    std::ifstream file(filename, std::ios::binary);   //文件以二进制模式打开
    if (!file) {
        std::cerr << "Error: Could not open or find the image" << std::endl;
        exit(1);
    }
    std::vector<unsigned char> bayer_data(width * height);
    file.read(reinterpret_cast<char*>(bayer_data.data()), width * height);
    return bayer_data;
}