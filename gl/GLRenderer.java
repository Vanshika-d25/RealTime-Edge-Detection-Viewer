package com.example.rted;

import android.content.Context;
import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

// Simple textured quad shader source
class ShaderHelper {
    static final String VERT = "attribute vec4 aPosition;attribute vec2 aTexCoord;varying vec2 vTexCoord;void main(){gl_Position=aPosition;vTexCoord=aTexCoord;}";
    static final String FRAG = "precision mediump float;varying vec2 vTexCoord;uniform sampler2D uTex;void main(){gl_FragColor=texture2D(uTex,vTexCoord);}";

    static int loadProgram() {
        int v = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER);
        GLES20.glShaderSource(v, VERT);
        GLES20.glCompileShader(v);
        int f = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER);
        GLES20.glShaderSource(f, FRAG);
        GLES20.glCompileShader(f);
        int p = GLES20.glCreateProgram();
        GLES20.glAttachShader(p, v);
        GLES20.glAttachShader(p, f);
        GLES20.glLinkProgram(p);
        return p;
    }
}

// Basic GLES2 renderer that accepts RGBA byte[] frames and draws them as a textured quad.
public class GLRenderer implements GLSurfaceView.Renderer {

    private Context ctx;
    private int texId = -1;
    private int viewWidth = 0, viewHeight = 0;
    private byte[] frameData = null;
    private int frameW = 0, frameH = 0;
    private boolean captureNext = false;

    private int program = -1;
    private FloatBuffer vertexBuffer;
    private FloatBuffer texBuffer;
    private int aPositionLoc;
    private int aTexCoordLoc;
    private int uTexLoc;

    public GLRenderer(Context ctx) {
        this.ctx = ctx;
    }

    public void setFrame(byte[] rgba, int w, int h) {
        synchronized (this) {
            this.frameData = rgba;
            this.frameW = w;
            this.frameH = h;
        }
    }

    @Override
    public void onSurfaceCreated(javax.microedition.khronos.opengles.GL10 gl, javax.microedition.khronos.egl.EGLConfig config) {
        texId = genTexture();
        GLES20.glClearColor(0f, 0f, 0f, 1f);

        program = ShaderHelper.loadProgram();
        aPositionLoc = GLES20.glGetAttribLocation(program, "aPosition");
        aTexCoordLoc = GLES20.glGetAttribLocation(program, "aTexCoord");
        uTexLoc = GLES20.glGetUniformLocation(program, "uTex");

        float[] verts = { // clip space quad (x,y)
                -1f, -1f,
                 1f, -1f,
                -1f,  1f,
                 1f,  1f
        };
        vertexBuffer = ByteBuffer.allocateDirect(verts.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
        vertexBuffer.put(verts).position(0);

        float[] texs = { // tex coords (s,t)
                0f, 1f,
                1f, 1f,
                0f, 0f,
                1f, 0f
        };
        texBuffer = ByteBuffer.allocateDirect(texs.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
        texBuffer.put(texs).position(0);
    }

    @Override
    public void onSurfaceChanged(javax.microedition.khronos.opengles.GL10 gl, int width, int height) {
        viewWidth = width;
        viewHeight = height;
        GLES20.glViewport(0, 0, width, height);
    }

    @Override
    public void onDrawFrame(javax.microedition.khronos.opengles.GL10 gl) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
        byte[] toUpload = null;
        int w = 0, h = 0;
        synchronized (this) {
            if (frameData != null) {
                toUpload = frameData;
                w = frameW; h = frameH;
                frameData = null; // consume
            }
        }

        if (toUpload != null && texId >= 0) {
            // Upload RGBA byte[] as texture
            ByteBuffer bb = ByteBuffer.wrap(toUpload);
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texId);
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, w, h, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, bb);
            // Draw textured quad using simple shader
            GLES20.glUseProgram(program);
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texId);
            GLES20.glUniform1i(uTexLoc, 0);

            GLES20.glEnableVertexAttribArray(aPositionLoc);
            GLES20.glVertexAttribPointer(aPositionLoc, 2, GLES20.GL_FLOAT, false, 0, vertexBuffer);
            GLES20.glEnableVertexAttribArray(aTexCoordLoc);
            GLES20.glVertexAttribPointer(aTexCoordLoc, 2, GLES20.GL_FLOAT, false, 0, texBuffer);

            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);

            GLES20.glDisableVertexAttribArray(aPositionLoc);
            GLES20.glDisableVertexAttribArray(aTexCoordLoc);

            if (captureNext) {
                saveFrame(toUpload, w, h);
                captureNext = false;
            }
        }
    }

    public void requestCapture() {
        captureNext = true;
    }

    private void saveFrame(byte[] data, int w, int h) {
        if (data == null || ctx == null) return;
        try {
            Bitmap bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
            ByteBuffer buffer = ByteBuffer.wrap(data);
            bitmap.copyPixelsFromBuffer(buffer);
            File dir = ctx.getExternalFilesDir(null);
            if (dir != null) {
                File file = new File(dir, "capture_" + System.currentTimeMillis() + ".png");
                FileOutputStream out = new FileOutputStream(file);
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
                out.close();
            }
        } catch (Exception e) {
            // Handle exception
        }
    }

    private int genTexture() {
        int[] tex = new int[1];
        GLES20.glGenTextures(1, tex, 0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex[0]);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        return tex[0];
    }

}