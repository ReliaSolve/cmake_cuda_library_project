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

// The header file that defines the CUDA functions should not itself require
// including CUDA, so that the application using the library does not need to.
// This header file should be a public header file for the library if its
// functions are going to be exposed directly, but can be a private header
// if they are only going to be called by other functions in the library.
// If they are going to be locally called, then they do not need to be exported.

#pragma once
 // This auto-generated file defines the export functions needed when we're
 // using a shared library on Windows.
#include <cmake_cuda_library_export.h>

#ifdef __cplusplus
extern "C" {
#endif

  /// @todo This particular implementation should be replaced with code that does
  // whatever is desired.  Because CUDA is often used for array processing and for
  // 2D or 3D images, this example defines a 2D vector type of points together
  // with a 2D floating-point image and it sums a quadratic fall-off energy from
  // a 1D array of points into the 2D array of pixels.
  /// @todo Do not pollute the global namespace with type definitions.
  typedef float POINT[2];
  typedef float FLOATPIXEL;

  /// @brief Sums 1/r^2 contributions from each point into an image.
  /// 
  /// This routine will ensure that CUDA is opened correctly when it is called and
  /// it will allocated any required CUDA storage.  If the routine is called multiple
  /// times with the same sized image, it will reuse already-allocated buffers.
  /// @param [in] point A 1D array of points that will be splatted into the image.
  ///             The point coordinates are in pixels.
  /// @param [in] numPoints How many points are in the 1D array.
  /// @param [out] image Image to be filled in.
  /// @param [in] nx Number of pixels in X in the image.
  /// @param [in] ny Number of pixels in Y in the image.
  /// @return Empty string on success.  String describing the problem on failure.
  CMAKE_CUDA_LIBRARY_EXPORT const char* cuda_compute_point_sum(
    const POINT *points, int numPoints, FLOATPIXEL *image, int nx, int ny);

#ifdef __cplusplus
}
#endif