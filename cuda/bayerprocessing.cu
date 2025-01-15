#include <iostream>
#include <cuda_runtime.h> 
#include <opencv2/opencv.hpp>
#include "common.cuh"
#include  "readBayer.cuh"
#include  "Mirror-Padding.cu"


int main(void)
{
  set_GPU();  
  std::cout<<"请输入图片的长和宽"<<std::endl;
  int width,height;
  std::cin>>width>>height;
  readBayer_img Bayer{"example",width,height};
  std::vector<unsigned char> Bayer_data_ = Bayer.readBayerImage("example",width,height);
  std::vector<unsigned char> BGR_data_;
  std::vector<unsigned char>& padded_data;
  int pad_width = 10;
  int padded_width = width + pad_width;
  int padded_height = height + pad_width;
  mirrorPadBayerImage(Bayer_data_ ,padded_data,width,height,pad_width);
  //分配主机内存，并初始化
  int Bayer_ElemenCount = ( width + pad_width ) * ( height + pad_width ) ;
  int BGR_ElementCount = 3 * width * height ;

  size_t Bayer_Bytecount = Bayer_ElemenCount*sizeof(unsigned char);
  size_t Bgr_Bytecount = BGR_ElementCount * sizeof(unsigned char);

  unsigned char *device_padded_bayer_data; unsigned char*device_bgr_data;
  device_bayer_data = (float *)cudaMalloc(Bayer_Bytecount);
  device_bgr_data = (float *)cudaMalloc(Bgr_Bytecount);
  //复制主机数据到GPU
  cudaMemcpy(device_padded_bayer_data, padded_bayer_data.data(), padded_width * padded_height * sizeof(unsigned char), cudaMemcpyHostToDevice);
  //设置网格数和线程数
  dim3 threadsPerBlock(16, 16);
  dim3 blocksPerGrid((width + threadsPerBlock.x - 1) / threadsPerBlock.x, (height + threadsPerBlock.y - 1) / threadsPerBlock.y);
  
  Demosaicing_process<<<blocksPerGrid, threadsPerBlock>>>(device_padded_bayer_data, device_bgr_data, padded_width, padded_height, width, height, pad_width);
  cudaDeviceSynchronize();

  std::vector<unsigned char> bgr_data(width * height * 3);
  cudaMemcpy(bgr_data.data(), device_bgr_data, width * height * 3 * sizeof(unsigned char), cudaMemcpyDeviceToHost);

  cudaFree(device_padded_bayer_data);
  cudaFree(device_bgr_data);

  
  cv::Mat bgr_image(height, width, CV_8UC3, bgr_data.data());
  cv::imwrite("output.jpg", bgr_image);

  return 0;  
}

