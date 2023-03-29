package com.example.haila_display_flutter

import com.luxand.FSDK
import com.luxand.FSDK.FSDK_FaceTemplate


class FaceService {
    fun initialize(): Boolean {
        val key =
            "qko4Ggli3w8Olt0AhLWMaXwpVu5aGY3k74cR/Qtjw7WYjvzttWS5HF7f99oJ5h03tQaaBPp+vu6MQpYKWNpf86HH2syVIZrrg5Tg8IqjU3Etq9elSK/QFwIXyOiTtZhiwm8D+nBiWLTFx5U8j/rhVmhoVhFmc3hK/15BZavB+Qw=";

        val res1 = FSDK.ActivateLibrary(key)
        val res2 = FSDK.Initialize()

        return res1 == 0 && res2 == 0
    }

    fun createTemplate(buffer: ByteArray, width: Int, height: Int): ByteArray {
        val img = FSDK.HImage()
        val scanLine = width * 3
        val mode = FSDK.FSDK_IMAGEMODE()
        mode.mode = FSDK.FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT

        FSDK.LoadImageFromBuffer(img, buffer, width, height, scanLine, mode)

        val template = FSDK_FaceTemplate()

        FSDK.GetFaceTemplate(img, template)
        FSDK.FreeImage(img)

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