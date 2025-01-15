#include <iostream>
#include <string>
#include <vector>
#include <fstream>
//#include <opencv2/opencv.hpp>
#include <cuda_runtime.h> 
#include "C:\Users\ASUS\Desktop\cuda\src\Mirror-Padding.cu"
#include "C:\Users\ASUS\Desktop\cuda\src\processingD.cu"
#include "C:\Users\ASUS\Desktop\cuda\src\set_GPU.cu"


std::vector<unsigned char> readBayerImage(const std::string& filename, int width, int height) {
    std::ifstream file(filename, std::ios::binary);
    if (!file) {
        std::cerr << "Error: Could not open or find the image" << std::endl;
        exit(1);
    }

    std::vector<unsigned char> bayer_data(width * height);
    file.read(reinterpret_cast<char*>(bayer_data.data()), width * height);
    if (!file) {
        std::cerr << "Error: Failed to read the image" << std::endl;
        exit(1);
    }

    return bayer_data;
}

int main(void) {
    set_GPU();  
    std::string filename = "C:/Users/ASUS/Desktop/cuda/examples/example.RAW";
    int width = 7040; 
    int height = 4688;

    // 读取Bayer图像数据
    std::vector<unsigned char> Bayer_data_ = readBayerImage(filename, width, height);

    // 初始化padded_data
    std::vector<unsigned char> padded_data;

    int pad_width = 10;
    int padded_width = width + 2 * pad_width;
    int padded_height = height + 2 * pad_width;

    // 进行镜像填充
    mirrorPadBayerImage(Bayer_data_, padded_data, width, height, pad_width);

    // 分配GPU内存
    unsigned char* device_padded_bayer_data;
    unsigned char* device_bgr_data;

    int Bayer_ElemenCount = padded_width * padded_height;
    int BGR_ElementCount = 3 * width * height;

    size_t Bayer_Bytecount = Bayer_ElemenCount * sizeof(unsigned char);
    size_t Bgr_Bytecount = BGR_ElementCount * sizeof(unsigned char);

    cudaMalloc((void**)&device_padded_bayer_data, Bayer_Bytecount);
    cudaMalloc((void**)&device_bgr_data, Bgr_Bytecount);

    // 复制主机数据到GPU
    cudaMemcpy(device_padded_bayer_data, padded_data.data(), Bayer_Bytecount, cudaMemcpyHostToDevice);

    // 设置网格数和线程数
    dim3 threadsPerBlock(16, 16);
    dim3 blocksPerGrid((width + threadsPerBlock.x - 1) / threadsPerBlock.x, (height + threadsPerBlock.y - 1) / threadsPerBlock.y);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // 记录开始时间
    cudaEventRecord(start, 0);
    
    // 调用核函数进行去马赛克处理
    Demosaicing_process<<<blocksPerGrid, threadsPerBlock>>>(device_padded_bayer_data, device_bgr_data, padded_width, padded_height, width, height, pad_width);
    cudaDeviceSynchronize();
    
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    // 计算并输出执行时间
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    std::cout << "Kernel execution time: " << elapsedTime << " ms" << std::endl;

    // 将结果从设备复制回主机
    std::vector<unsigned char> bgr_data(width * height * 3);
    cudaMemcpy(bgr_data.data(), device_bgr_data, Bgr_Bytecount, cudaMemcpyDeviceToHost);

    // 释放GPU内存
    cudaFree(device_padded_bayer_data);
    cudaFree(device_bgr_data);

    // 保存或处理BGR图像数据
   //  cv::Mat bgr_image(height, width, CV_8UC3, bgr_data.data());
    // cv::imwrite("output.jpg", bgr_image);
   // cv::imshow("BGR Image", bgr_image);
    // cv::waitKey(0);  // 等待按键
    std::cout << "Original Bayer Image Data (part):" << std::endl;
    int rows_to_print = 5;  // 打印的行数
    int cols_to_print = 5;  // 打印的列数
    for (int y = 0; y < rows_to_print; ++y) {
        for (int x = 0; x < cols_to_print; ++x) {
            int idx = y * width + x;
            std::cout << static_cast<int>(Bayer_data_[idx]) << " ";
        }
        std::cout << std::endl;
    }

    // 打印BGR图像数据矩阵的一部分
    std::cout << "Processed BGR Image Data (part):" << std::endl;
    for (int y = 0; y < rows_to_print; ++y) {
        for (int x = 0; x < cols_to_print; ++x) {
            int idx = (y * width + x) * 3;
            std::cout << "B: " << static_cast<int>(bgr_data[idx]) 
                      << " G: " << static_cast<int>(bgr_data[idx + 1]) 
                      << " R: " << static_cast<int>(bgr_data[idx + 2]) 
                      << "  ";
        }
        std::cout << std::endl;
    }

    return 0;  
}
