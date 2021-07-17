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

#pragma once
// This auto-generated file defines the export functions needed when we're
// using a shared library on Windows.
#include <cmake_library_project_export.h>

/**
  * @file cmake_library_project.h
  * @brief Example library compiled using CMake.
  */

#ifdef __cplusplus
extern "C" {
#endif

  /********************************************************************************/
  /* Status return values declared here. */
  #define CMAKE_LIBRARY_PROJECT_STATUS_OK 0
  CMAKE_LIBRARY_PROJECT_EXPORT const char* cmake_library_project_ErrorMessage(int status);

  /********************************************************************************/
  /* Function declarations go here.  They should share a common prefix to avoid
   * colliding with other symbols in the global namespace.
   * Each should have CMAKE_LIBRARY_PROJECT_EXPORT in front of them to support
   * using shared libraries on Windows.
   */

  CMAKE_LIBRARY_PROJECT_EXPORT int cmake_library_project_init();
  CMAKE_LIBRARY_PROJECT_EXPORT int cmake_library_project_destroy();

  CMAKE_LIBRARY_PROJECT_EXPORT const char * cmake_library_project_get_version();

  /* You may want a unit test function that a client can call to let them know the library
   * is behaving properly.  This one returns an empty string on success and a string describing
   * all errors on failure. */
  CMAKE_LIBRARY_PROJECT_EXPORT const char *cmake_library_project_test();

#ifdef __cplusplus
}
#endif