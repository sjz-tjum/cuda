#include"set_GPU.cuh"


void set_GPU()
{
    int iDeviceCount = 0;
    cudaError_t error = cudaGetDeviceCount( &iDeviceCount);
    if(error != cudaSuccess)
    {
        printf("There's no GPU found!\n");
        exit(-1);
    }
    else
    {
        printf("The number of GPU is %d .\n",iDeviceCount);
    }

   //设置GPU
   int iDev = 0;
   error = cudaSetDevice(iDev);
   if(error != cudaSuccess)
   {
    printf("fail to set GPU 0 for computing.\n");
    exit(-1);
   }
   else
   {
    printf("Successfully set GPU 0 for computing.\n");
   }
}