cmake_minimum_required(VERSION 3.1.0)
project(cmake_cuda_library_project)

#-----------------------------------------------------------------------------
# Set your favorite C++ standard for compiling the internal files.  The library
# will export things as extern "C" so this will not impact client programs.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#-----------------------------------------------------------------------------
if(WIN32)
    add_definitions(-DNOMINMAX)
endif(WIN32)

#-----------------------------------------------------------------------------
# Local CMake Modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

#-----------------------------------------------------------------------------
# Enable sorting projects within the solution on Visual Studio, to group
# Test and Example files together.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#-----------------------------------------------------------------------------
# Export libraries along with our DLLs if we want to build shared
# Allow the developer to select if Dynamic or Static libraries are built
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

include (GenerateExportHeader)

#-----------------------------------------------------------------------------
# Build options.
option(BUILD_EXAMPLES "Build examples" ON)
option(BUILD_TESTS "Build test programs" ON)

#-----------------------------------------------------------------------------
# Set up build product locations

include(GNUInstallDirs)

# Win-specific: we want shared libs (dlls) in same dir as exe files.
if(WIN32)
	set(CMAKE_LIBRARY_PROJECT_SHARED_LIBRARY_DIR "${CMAKE_INSTALL_BINDIR}")
else()
	set(CMAKE_LIBRARY_PROJECT_SHARED_LIBRARY_DIR "${CMAKE_INSTALL_LIBDIR}")
endif()

set (cmake_cuda_library_project_SOURCES cmake_cuda_library_project.cpp)

#-----------------------------------------------------------------------------
# Build the library

set (cmake_cuda_library_project_HEADERS
  cmake_cuda_library_project.h
)

add_library(cmake_cuda_library_project ${cmake_cuda_library_project_SOURCES}
  ${cmake_cuda_library_project_HEADERS})
set_target_properties(cmake_cuda_library_project PROPERTIES LINKER_LANGUAGE CXX)
# Hide all symbols that are not explicitly exported from the library
set_target_properties(cmake_cuda_library_project PROPERTIES C_VISIBILITY_PRESET hidden)
set_target_properties(cmake_cuda_library_project PROPERTIES CXX_VISIBILITY_PRESET hidden)
set_target_properties(cmake_cuda_library_project PROPERTIES VISIBILITY_INLINES_HIDDEN 1)
target_include_directories(cmake_cuda_library_project PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_BINARY_DIR}
  ${CMAKE_INSTALL_PREFIX}/include
)
# Include this if the library uses threads.
#if(UNIX)
#    target_link_libraries(cmake_cuda_library_project PUBLIC pthread)
#endif(UNIX)
set_target_properties(cmake_cuda_library_project
  PROPERTIES PUBLIC_HEADER "${cmake_cuda_library_project_HEADERS}")
generate_export_header(cmake_cuda_library_project)

install(TARGETS cmake_cuda_library_project EXPORT ${PROJECT_NAME}
  RUNTIME DESTINATION bin COMPONENT lib
  LIBRARY DESTINATION lib${LIB_SUFFIX} COMPONENT lib
  ARCHIVE DESTINATION lib${LIB_SUFFIX} COMPONENT lib
  INCLUDES DESTINATION include
  PUBLIC_HEADER DESTINATION include
)
install(FILES ${PROJECT_BINARY_DIR}/cmake_cuda_library_project_export.h
  DESTINATION include COMPONENT headers
)

#-----------------------------------------------------------------------------
# Build examples if we've been asked to.

if(BUILD_EXAMPLES)
  set (EXAMPLES
    cmake_cuda_library_project_example
  )
  foreach (APP ${EXAMPLES})
    add_executable (${APP} examples/${APP}.c)
    set_target_properties(${APP} PROPERTIES FOLDER examples)
    target_link_libraries(${APP} cmake_cuda_library_project)
    install(TARGETS ${APP} EXPORT ${PROJECT_NAME}
      RUNTIME DESTINATION bin
    )
  endforeach (APP)

endif(BUILD_EXAMPLES)

#-----------------------------------------------------------------------------
# Build tests if we've been asked to.

if(BUILD_TESTS)

  enable_testing()

  set (TESTS
    cmake_cuda_library_project_test
  )
  foreach (APP ${TESTS})
    add_executable (${APP} tests/${APP}.c)
    set_target_properties(${APP} PROPERTIES FOLDER tests)
    target_link_libraries(${APP} cmake_cuda_library_project)
    install(TARGETS ${APP} EXPORT ${PROJECT_NAME}
      RUNTIME DESTINATION bin
    )
    add_test(${APP} ${APP})
  endforeach (APP)

endif(BUILD_TESTS)
