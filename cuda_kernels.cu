/*
 * Copyright 2021 ReliaSolve, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cuda.h>
#include <stdint.h>
#include <algorithm>
#include "cuda_kernels.h"
#include "math_constants.h"

extern "C" {

  //----------------------------------------------------------------------
  // Definitions and routines needed by all functions below.
  //----------------------------------------------------------------------

  static FLOATPIXEL* g_cuda_buffer_float = nullptr;

  static unsigned		g_cuda_nx = 0;
  static unsigned		g_cuda_ny = 0;

  // For the GPU code, block size and number of kernels to run to cover a whole grid.
  // Initialized once in ensure_cuda_ready();
  static dim3         g_threads;      // 16x16x1
  static dim3         g_grid;         // Computed to cover array (slightly larger than array)

  // Open the CUDA device and get a context.  Also allocate buffers of
  // appropriate size.  Do this allocation only when the size of the buffer
  // allocated is different from the newly-requested size.  Return false
  // if we cannot get one.  This function can be called every time a
  // CUDA-using function is called, but it only does the device opening
  // and image-buffer allocation once.
  static const char *ensure_cuda_ready(unsigned nx, unsigned ny)
  {
    static bool initialized = false;	// Have we initialized yet?
    if (!initialized) {
      // Whether this works or not, we'll be initialized.
      initialized = true;

      // Open the first CUDA device in the system and create a context.
      if (cudaSetDevice(0) != cudaSuccess) {
        return "ensure_cuda_ready(): Could not set device.";
      }
      g_cuda_nx = nx;
      g_cuda_ny = ny;
    }

    // Allocate buffer to be used on the GPU.  It will be copied from and to host memory.
    // If we've been given a different-sized buffer, deallocate the old buffers.
    // Don't do this if we had an empty size before.
    if ( (g_cuda_nx || g_cuda_ny) && ((nx != g_cuda_nx) || (ny != g_cuda_ny)) ) {
      cudaFree(g_cuda_buffer_float);
    }

    unsigned int numFloatBytes = nx * ny * sizeof(FLOATPIXEL);
    if (g_cuda_buffer_float == NULL) {
      if (cudaMalloc((void**)&g_cuda_buffer_float, numFloatBytes) != cudaSuccess) {
        return "ensure_cuda_ready(): Could not allocate memory";
      }
      if (g_cuda_buffer_float == NULL) {
        return "ensure_cuda_ready() : Buffer is NULL pointer.";
      }
    }

    // Return true if we are okay.
    return "";
  }

  // CUDA kernel to sum the results for all points into the image.
  static __global__ void cuda_compute_point_sum_kernel(
    const POINT* points, int numPoints, FLOATPIXEL* image, int nx, int ny)
  {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    // Only compute values for pixels that inside the image.
    if ((x < nx) && (y < ny)) {
      for (int i = 0; i < numPoints; i++) {
        const POINT& p = points[i];
        float R_squared = (x-p[0])*(x-p[0]) + (y-p[1])*(y-p[1]);
        // Avoid numerical instability
        if (R_squared == 0) {
          image[x + y * nx] += 1e10;
        } else {
          image[x + y * nx] += FLOATPIXEL(1) / R_squared;
        }
      }
    }
  }

  const char* cuda_compute_point_sum(
    const POINT* points, int numPoints, FLOATPIXEL* image, int nx, int ny)
  {
    // Check the parameters.
    if (!points) { return "cuda_compute_point_sum(): Null points"; }
    if (!image) { return "cuda_compute_point_sum(): Null image"; }
    if (numPoints <= 0) { return "cuda_compute_point_sum(): numPoints <= 0"; }
    if (nx <= 0) { return "cuda_compute_point_sum(): nx <= 0"; }
    if (ny <= 0) { return "cuda_compute_point_sum(): ny <= 0"; }

    // Make sure we can initialize CUDA.  This also allocates the global
    // input buffer that we'll copy data from the host into.
    const char* ret = ensure_cuda_ready(nx, ny);
    if (strlen(ret) != 0) { return ret; }

    // Zero the GPU image that we will sum into.
    // Copy the input image from host memory into the GPU buffers.  Don't re-copy the same
    // image that we sent last time.
    size_t floatSize = nx * ny * sizeof(FLOATPIXEL);
    if (cudaMemset(g_cuda_buffer_float, 0, floatSize) != cudaSuccess) {
      return "cuda_compute_point_sum(): Could not zero CUDA image";
    }

    // Allocate a GPU buffer for the points and copy the points into it.
    POINT* points_gpu = nullptr;
    size_t pointsSize = numPoints * sizeof(POINT);
    if (cudaMalloc((void**)&points_gpu, pointsSize) != cudaSuccess) {
      return "cuda_compute_point_sum(): Could not allocate memory";
    }
    if (cudaMemcpy(points_gpu, points, pointsSize, cudaMemcpyHostToDevice) != cudaSuccess) {
      return "cuda_compute_point_sum(): Could not copy points to GPU";
    }

    // Set up enough threads (and enough blocks of threads) to at least
    // cover the size of the array.  We use a thread block size of 16x16
    // because that's what the example matrixMul code from nVidia does.
    g_threads.x = 16;
    g_threads.y = 16;
    g_threads.z = 1;
    g_grid.x = ((g_cuda_nx - 1) / g_threads.x) + 1;
    g_grid.y = ((g_cuda_ny - 1) / g_threads.y) + 1;
    g_grid.z = 1;

    // Call the CUDA kernel to make the output image,
    // Synchronize the threads when we are done so we know that they finish
    // before we copy the memory back.
    cuda_compute_point_sum_kernel << < g_grid, g_threads >> > (
      points_gpu, numPoints, g_cuda_buffer_float, nx, ny);
    if (cudaDeviceSynchronize() != cudaSuccess) {
      return "cuda_compute_point_sum(): Could not synchronize threads";
    }

    // Copy the buffer back from the GPU to host memory.
    if (cudaMemcpy(image, g_cuda_buffer_float, floatSize, cudaMemcpyDeviceToHost) != cudaSuccess) {
      return "cuda_compute_point_sum(): Could not copy image back to host";
    }

    // We're done with the points buffer now.
    cudaFree(points_gpu);

    // Everything worked!
    return "";
  }

}