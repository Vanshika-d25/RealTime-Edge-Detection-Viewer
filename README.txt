📸 Real-Time Edge Detection Viewer

Android + OpenCV (C++) + OpenGL ES + JNI + TypeScript Web Viewer

A modular, high-performance real-time computer vision pipeline built using:

Android Camera2 API

Native C++ with OpenCV

OpenGL ES 2.0 texture rendering

JNI for Java ↔ C++ communication

A lightweight TypeScript web viewer

This project demonstrates an R&D workflow involving native image processing, GPU rendering, and multi-platform debugging.

🔧 Tech Stack
Android

Java/Kotlin

Camera2 API

OpenCV (C++ bindings)

NDK + CMake

JNI

OpenGL ES 2.0

GLSL shaders

Web

TypeScript

HTML/CSS

Simple static viewer

🚀 Project Summary

This project performs real-time camera frame capture, sends each frame to C++ OpenCV code, processes it (edges, grayscale, etc.), and then renders it on-screen using OpenGL ES textures.

Additionally, a mini TypeScript web viewer displays a sample processed frame for debugging/export validation.

🧩 Features
📸 1. Android Camera Feed Integration

Continuous frame capture using TextureView / Camera2

Handles YUV_420_888 / NV21 formats

Background thread for stable streaming

🔁 2. Native Processing (C++ + OpenCV)

JNI call for each frame

OpenCV operations implemented:

Canny Edge Detection

Grayscale conversion

Blur

Invert (optional)

Conversion: NV21 → Mat → Process → RGBA output

Returns raw byte buffer back to Java

Processing time logged → FPS counter

🎨 3. Rendering Using OpenGL ES

RGBA buffer uploaded as a 2D texture

Drawn on a full-screen quad

Efficient shader pipeline

Real-time rendering (10–30 FPS depending on device)

🌐 4. Web Viewer (TypeScript)

Displays static processed frames

Overlays resolution, FPS info

DOM updates using clean TS modules

Helps validate exported frames outside Android

⚙️ Architecture Overview
/app
    Camera2Controller (frame capture)
    MainActivity (UI + mode switching)
    NativeBridge (JNI helper)
    GLView (surface for rendering)

/jni
    edge_detector.cpp (OpenCV logic)
    native_bridge.cpp (JNI bindings)
    image_utils.cpp (NV21 → RGBA)
    CMakeLists.txt

/gl
    GLRenderer.cpp (texture renderer)
    shaders.glsl

/web
    index.html
    main.ts
    styles.css

/scripts
    fetch_opencv.ps1
    fetch_jdk17.ps1
    install_gradle.ps1

/third_party
    OpenCV Android SDK

/assets, /files
    Sample processed frames

🔄 Frame Processing Pipeline
Android Camera (YUV / NV21)
        ↓
ImageReader → Java/Kotlin
        ↓ JNI
Native C++ (OpenCV: Canny/Grayscale/etc.)
        ↓
RGBA byte buffer
        ↓
OpenGL ES Renderer (texture)
        ↓
On-screen output (real-time)

🛠️ Setup Instructions
1. Install Required Tools

Android Studio Hedgehog+

Android SDK + NDK (r21+)

CMake 3.10+

JDK 17

OpenCV Android SDK (download from opencv.org)

2. Clone the Repository
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

3. Configure OpenCV for CMake

In Android Studio → Project Structure → CMake:

OpenCV_DIR = <path/to/OpenCV-android-sdk>/sdk/native/jni

4. Build & Run

Sync Gradle

Connect an Android device

Run the app

Toggle between processing modes

FPS overlay shows real-time performance



This project was built as part of an Android + OpenCV + OpenGL + Web R&D Intern Assessment, showcasing:

Native image processing

Camera + rendering pipeline

Multi-language integration (C++, Java, TS)

Real-time graphics optimization

Clean architecture design

🙌 Author

Vanshika Dixit

