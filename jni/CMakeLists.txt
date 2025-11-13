cmake_minimum_required(VERSION 3.4.1)

# Set path to OpenCV Android SDK using -DOpenCV_DIR or edit below
if(NOT DEFINED OpenCV_DIR)
    # Default to a vendored copy if present under third_party/OpenCV-android/sdk/native/jni
    set(POTENTIAL "${CMAKE_SOURCE_DIR}/../third_party/OpenCV-android/sdk/native/jni")
    # Some extracts place the SDK under third_party/OpenCV-android/OpenCV-android-sdk
    if(NOT EXISTS ${POTENTIAL})
        set(POTENTIAL2 "${CMAKE_SOURCE_DIR}/../third_party/OpenCV-android/OpenCV-android-sdk/sdk/native/jni")
        if(EXISTS ${POTENTIAL2})
            set(POTENTIAL ${POTENTIAL2})
        endif()
    endif()
    if(EXISTS ${POTENTIAL})
        set(OpenCV_DIR ${POTENTIAL})
        message(STATUS "Using vendored OpenCV at ${OpenCV_DIR}")
    else()
        message(WARNING "OpenCV_DIR not set and no vendored copy found. Set -DOpenCV_DIR=/path/to/OpenCV-android/sdk/native/jni")
    endif()
endif()

find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs objdetect)

add_library(edge_native SHARED edge_detector.cpp)

include_directories(${OpenCV_INCLUDE_DIRS})

target_link_libraries(edge_native ${OpenCV_LIBS})