#include <iostream>
#include <cuda_runtime.h>  // 包含CUDA运行时头文件
#include <opencv2/opencv.hpp>
#include "common.cuh"


int main(void)
{
  set_GPU();  
  std::cout<<"请输入图片的长和宽"<<std::endl;
  std::cin>>width>>height;
  readBayer_img Bayer{"example",width,height};
  std::vector<unsigned char> Bayer_data_ = Bayer.readBayerImage("example",width,height);
  std::vector<unsigned char> BGR_data_;
  //分配主机内存，并初始化
  int Bayer_ElemenCount = width*height;
  int BGR_ElementCount = 3*width*height;

  size_t Bayer_Bytecount = Bayer_ElemenCount*sizeof(unsigned char);
  size_t Bgr_Bytecount = BGR_ElementCount * sizeof(unsigned char);


  unsigned char *device_bayer_data; unsigned char*device_bgr_data;
  device_bayer_data = (float *)malloc(Bayer_Bytecount);
  device_bgr_data = (float *)malloc(Bgr_Bytecount);
  //复制主机数据到GPU
  cudaMemcpy(device_bayer_data,Bayer_data_.data(), Bayer_Bytecount, cudaMemcpyHostToDevice);
  //设置网格数和线程数
  dim3 threadsPerBlock(16, 16);
  dim3 blocksPerGrid((width + threadsPerBlock.x - 1) / threadsPerBlock.x, (height + threadsPerBlock.y - 1) / threadsPerBlock.y);



}