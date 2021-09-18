# cmake_cuda_library_project

This repository contains an example library, including example and test programs,
that builds and installs using CMake.  It can be built as a static library or as
a dynamic library.

## Getting Started

**Build:** This project uses CMake to configure the builds (though other build
systems could be used).  On Ubuntu Linux, this can be done as follows

    sudo apt install cmake
    cd; mkdir src; cd src; git clone https://github.com/reliasolve/cmake_library_project
    cd; mkdir -p build/cmake_cuda_library_project; cd build/cmake_cuda_library_project
    cmake ../../src/cmake_cuda_library_project
    make

**Fork:** To use this to define an actual library, find and replace all instances of
"cmake_cuda_library_project" and "CMAKE_CUDA_LIBRARY_PROJECT" with a prefix that matches the
name of the project being implemented.  It does not need to be the full name and can
be an abbreviation.  Then implement new functions, test programs, and examples as needed.

General library design criteria:

* The library should never cause the program calling it to exit, even
for catastrophic failures.  It can return error codes but must always
pass control back to the caller to deal with them.  This is particularly
challenging when dealing with C++ exceptions and signals (like segmentation
faults).
* Place a distinguishing prefix on EVERYTHING THAT CAN BE SEEN outside
the library.  This includes such things as global file variables,
which are not used by the user code, but certainly can cause name
collisions.  Everything that does not
have this prefix should be either local to a routine or declared static.
This includes type definitions in the header (.h) files.
* Provide a function to get the version of the library.  This should
include at least major version (which changes when not all previous code will
continue to work with the new version) and minor version, but may also include
additional levels.
* All routines should return some value that specifies whether they
worked correctly or not.  It is good for these to be uniform
across the library as much as possible.  Note that some routines seem like they cannot
fail, but then later they are changed to do something that can
fail, so it is worth your while to have them return always with
success and have higher routines check the return value so that
when it later changes the other code will be prepared.
* To provide a human-readible error message for the return values,
a function such as cmake_cuda_library_project_ErrorMessage() should be provided that converts
the value into a string.  This is useful to application that want to let
the user know what went wrong.  All internally-defined status returns should have
an entry in this function (OK, warnings, and errors).
* Name things consistently within the library.  All type definitions
should have the same format.
* Limit unexpected side-effects of routines.  Ideally, all
of the information passed to or from the routines should be in
the parameters and return values.  Having global variables that
are set to communicate with the library causes confusion.
* Wherever possible, limit the external exposure of dependencies on
other libraries.  The most problematic such exposure is in the header
files that must be included by the client code.  This can often be
handled by forward declaring types in the headers and including the
sub-library headers in the C/C++ files.  The next level is to not
require the client to link to the sub-libraries by using static
library linkage for other libraries that are used internally.
* For libraries that are designed to work across architectures,
the basic C types have the problem that they can vary in size.  This
means that the various specific-sized types such as uint23_t should be
used where possible to maintain the same ranges across all builds.
