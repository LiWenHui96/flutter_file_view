package com.file.view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * @Author: LiWeNHuI
 * @Date: 2021/9/12
 * @Describe: File Local View Factory
 */
class FileLocalViewFactory(private val mBinaryMessenger: BinaryMessenger, private val mContext: Context) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any): PlatformView {
        val params = args as Map<String, Any>
        return FileLocalView(mContext, viewId, params, mBinaryMessenger)
    }
}