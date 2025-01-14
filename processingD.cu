#include"Demosaicing.cuh"

__global__ void processDemosacing(unsigned char* device_bayer_data, unsigned char* device_bgr_data, int width, int height)
{
    unsigned long long x = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned long long y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height)
    {
        unsigned long long index = y * width + x;
        unsigned char r, g, b;

        // 根据拜尔模式（RGGB）进行插值
        if (x % 2 == 0 && y % 2 == 0) // R
        {
            r = device_bayer_data[index];
            g = (device_bayer_data[index - 1] + device_bayer_data[index + 1] + device_bayer_data[index - width] + device_bayer_data[index + width]) / 4;
            b = (device_bayer_data[index - width - 1] + device_bayer_data[index - width + 1] + device_bayer_data[index + width - 1] + device_bayer_data[index + width + 1]) / 4;
        }
        else if (x % 2 == 1 && y % 2 == 0) // Gr
        {
            r = (device_bayer_data[index - 1] + device_bayer_data[index + 1]) / 2;
            g = device_bayer_data[index];
            b = (device_bayer_data[index - width] + device_bayer_data[index + width] + device_bayer_data[index - width - 1] + device_bayer_data[index - width + 1] + device_bayer_data[index + width - 1] + device_bayer_data[index + width + 1]) / 6;
        }
        else if (x % 2 == 0 && y % 2 == 1) // Gb
        {
            r = (device_bayer_data[index - width] + device_bayer_data[index + width]) / 2;
            g = device_bayer_data[index];
            b = (device_bayer_data[index - 1] + device_bayer_data[index + 1] + device_bayer_data[index - width - 1] + device_bayer_data[index - width + 1] + device_bayer_data[index + width - 1] + device_bayer_data[index + width + 1]) / 6;
        }
        else // B
        {
            r = (device_bayer_data[index - width - 1] + device_bayer_data[index - width + 1] + device_bayer_data[index + width - 1] + device_bayer_data[index + width + 1]) / 4;
            g = (device_bayer_data[index - 1] + device_bayer_data[index + 1] + device_bayer_data[index - width] + device_bayer_data[index + width]) / 4;
            b = device_bayer_data[index];
        }

        // 存储结果到BGR图像数组
        int bgr_index = index * 3;
        device_bgr_data[bgr_index] = b;
        device_bgr_data[bgr_index + 1] = g;
        device_bgr_data[bgr_index + 2] = r;
    }
}
