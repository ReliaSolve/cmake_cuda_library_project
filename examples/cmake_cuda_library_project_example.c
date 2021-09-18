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

#include <cmake_cuda_library_project.h>
#include <stdio.h>
#include <string.h>

int main(int argc, const char* argv[])
{
  int ret;
  if (CMAKE_CUDA_LIBRARY_PROJECT_STATUS_OK != (ret = cmake_cuda_library_project_init())) {
    fprintf(stderr, "Error initializing: %s\n", cmake_cuda_library_project_ErrorMessage(ret));
  }
  printf("Library version: %s\n", cmake_cuda_library_project_get_version());
  if (CMAKE_CUDA_LIBRARY_PROJECT_STATUS_OK != (ret = cmake_cuda_library_project_destroy())) {
    fprintf(stderr, "Error destroying: %s\n", cmake_cuda_library_project_ErrorMessage(ret));
  }
}
