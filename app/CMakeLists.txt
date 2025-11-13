cmake_minimum_required(VERSION 3.10)
project(RTED_App)

# Top-level CMake for Android Studio assembly: include the JNI module
add_subdirectory(${CMAKE_SOURCE_DIR}/../jni ${CMAKE_BINARY_DIR}/jni_build)

# In Android Studio, set OpenCV_DIR as a CMake variable or edit jni/CMakeLists.txt to point to your OpenCV SDK
