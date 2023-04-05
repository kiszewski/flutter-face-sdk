package com.example.haila_display_flutter

import android.util.Log
import com.luxand.FSDK
import com.luxand.FSDK.FSDK_FaceTemplate
import java.nio.ByteBuffer


class FaceService {
    fun initialize(): Boolean {
        val key =
            "ZQ5ljtoJ6GPGFVzV5t5Jpv8n6DOjtI7ztfoPFu3CqDCwZvj3cGn+vfivtaJBSyPDlgFIK4fCeAaZGIStllm0F0gG8QJmH8sb3+q/CG0ZYehdH8GlO845srVzuCU6/Qs62+EwS42RpIqSWSEkt3N0xi0GRkT41/f/sUQcFTveiB0=";

        val res1 = FSDK.ActivateLibrary(key)
        val res2 = FSDK.Initialize()

        return res1 == 0 && res2 == 0
    }

    fun createTemplate(buffer: ByteArray, width: Int, height: Int): ByteArray {
        Log.d("BUFFER1", buffer[0].toString())
        Log.d("BUFFER2", buffer[1].toString())
        Log.d("BUFFER3", buffer[2].toString())
        Log.d("BUFFER Lenght", buffer.size.toString())

        val img = FSDK.HImage()
        val scanLine = width * 3
        val mode = FSDK.FSDK_IMAGEMODE()
        mode.mode = FSDK.FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT

        FSDK.LoadImageFromBuffer(img, buffer, width, height, scanLine, mode)

        val template = FSDK_FaceTemplate()

        val res = FSDK.GetFaceTemplate(img, template)

        Log.d("RESULT", res.toString())

        var highestByte = buffer.max()
        var lowestByte = buffer.min()

        Log.d("HIGHEST BYTE", highestByte.toString())
        Log.d("LOWEST BYTE", lowestByte.toString())


        return template.template
    }
    fun createTemplateFromPixels(pixels: IntArray, width: Int, height: Int): ByteArray {
        Log.d("pixels1", pixels[0].toString())

        Log.d("HEIGHT", height.toString())
        Log.d("WIDTH", width.toString())

        val img = FSDK.HImage()

        val buffer =
            ByteBuffer.allocateDirect(width * height * 3) // Allocate a direct buffer for RGB data


        Log.d("BUFFER SIZE", (width * height * 3).toString())

        for (i in pixels.indices) {
            val r = (pixels[i] shr 16 and 0xFF).toByte()
            val g = (pixels[i] shr 8 and 0xFF).toByte()
            val b = (pixels[i] and 0xFF).toByte()

            if(i == 0) {
                Log.d("RED", r.toString())
                Log.d("GREEN", g.toString())
                Log.d("BLUE", b.toString())
            }

            buffer.put(r) // Extract the red component and put it in the buffer
            buffer.put(g) // Extract the green component and put it in the buffer
            buffer.put(b) // Extract the blue component and put it in the buffer
        }

        val bufferArray = buffer.array()
        val scanLine = width * 3
        val mode = FSDK.FSDK_IMAGEMODE()
        mode.mode = FSDK.FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT

        val loadImageResult = FSDK.LoadImageFromBuffer(img, bufferArray, width, height, scanLine, mode)
        Log.d("loadImageResult", loadImageResult.toString())

        val template = FSDK_FaceTemplate()
        val res = FSDK.GetFaceTemplate(img, template)

        if(res == 0) {
            Log.i("SUCCESS GET TEMPLATE", res.toString())
        } else {
            Log.d("ERROR GET TEMPLATE", res.toString())

        }

        return template.template
    }
    fun createTemplateFromPath(filePath: String): ByteArray {
        val img = FSDK.HImage()
        FSDK.LoadImageFromFile(img, filePath)

        val template = FSDK_FaceTemplate()

        FSDK.GetFaceTemplate(img, template)
        FSDK.FreeImage(img)

        return template.template
    }
    fun matchTemplates(template1: ByteArray, template2: ByteArray): Boolean {
        val t1 = FSDK_FaceTemplate()
        val t2 = FSDK_FaceTemplate()

        t1.template = template1
        t2.template = template2

        var similarity = FloatArray(1)

        FSDK.MatchFaces(t1, t2, similarity)

        return similarity[0] > 0.98
    }


}