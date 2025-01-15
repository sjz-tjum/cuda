#include"Demosaicing.cuh"

__global__  void processDemosacing(unsigned char* device_bayer_data, unsigned char* device_bgr_data, int width, int height);
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if (x >= width || y >= height) return;
    int bayer_idx = y * width + x;
    int bgr_idx = bayer_idx * 3;

    if (y % 2 == 0) {
        if (x % 2 == 0)
        {
            // B
            device_bgr_data[bgr_idx + 0] = device_bayer_data[bayer_idx];
            device_bgr_data[bgr_idx + 1] = (x + 1 < width) ? device_bayer_data[bayer_idx + 1] : device_bayer_data[bayer_idx - 1];
            device_bgr_data[bgr_idx + 2] = (y + 1 < height) ? device_bayer_data[bayer_idx + width] : device_bayer_data[bayer_idx - width];
        } 
        else 
        {
            // G
            device_bgr_data[bgr_idx + 0] = (x - 1 >= 0) ? device_bayer_data[bayer_idx - 1] : device_bayer_data[bayer_idx + 1];
            device_bgr_data[bgr_idx + 1] = device_bayer_data[bayer_idx];
            device_bgr_data[bgr_idx + 2] = (y + 1 < height) ? device_bayer_data[bayer_idx + width] : device_bayer_data[bayer_idx - width];
        }
    } 
}
