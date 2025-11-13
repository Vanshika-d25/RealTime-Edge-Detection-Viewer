#include <jni.h>
#include <opencv2/opencv.hpp>
#include <vector>
#include <chrono>
#include <mutex>

using namespace cv;

static int g_mode = 0; // 0 = Canny edges, 1 = grayscale, 2 = invert, 3 = blur
static double g_last_ms = 0.0;
static std::mutex g_mutex;

extern "C" {

JNIEXPORT jbyteArray JNICALL
Java_com_example_rted_NativeLib_processFrame(JNIEnv *env, jclass clazz, jbyteArray nv21_, jint width, jint height) {
    auto t0 = std::chrono::high_resolution_clock::now();

    jbyte *nv21 = env->GetByteArrayElements(nv21_, NULL);
    jsize nv21_len = env->GetArrayLength(nv21_);

    Mat yuv(height + height/2, width, CV_8UC1, (unsigned char *)nv21);
    Mat rgba;
    cvtColor(yuv, rgba, COLOR_YUV2RGBA_NV21);

    Mat outRGBA;

    if (g_mode == 1) {
        // Grayscale output (converted to RGBA)
        Mat gray;
        cvtColor(rgba, gray, COLOR_RGBA2GRAY);
        cvtColor(gray, outRGBA, COLOR_GRAY2RGBA);
    } else if (g_mode == 2) {
        // Invert colors
        bitwise_not(rgba, outRGBA);
    } else if (g_mode == 3) {
        // Blur
        GaussianBlur(rgba, outRGBA, Size(15, 15), 0);
    } else {
        // Canny edges
        Mat gray;
        cvtColor(rgba, gray, COLOR_RGBA2GRAY);
        Mat edges;
        Canny(gray, edges, 80, 160);
        cvtColor(edges, outRGBA, COLOR_GRAY2RGBA);
    }

    int out_len = outRGBA.total() * outRGBA.elemSize();
    jbyteArray out = env->NewByteArray(out_len);
    env->SetByteArrayRegion(out, 0, out_len, (jbyte*)outRGBA.data);

    env->ReleaseByteArrayElements(nv21_, nv21, 0);

    auto t1 = std::chrono::high_resolution_clock::now();
    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
    {
        std::lock_guard<std::mutex> lock(g_mutex);
        g_last_ms = ms;
    }

    return out;
}

JNIEXPORT void JNICALL
Java_com_example_rted_NativeLib_setMode(JNIEnv *env, jclass clazz, jint mode) {
    std::lock_guard<std::mutex> lock(g_mutex);
    g_mode = mode;
}

JNIEXPORT jdouble JNICALL
Java_com_example_rted_NativeLib_getLastProcessingMs(JNIEnv *env, jclass clazz) {
    std::lock_guard<std::mutex> lock(g_mutex);
    return (jdouble)g_last_ms;
}

} // extern C