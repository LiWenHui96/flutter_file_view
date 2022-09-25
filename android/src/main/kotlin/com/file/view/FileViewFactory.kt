package com.file.view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * @author LiWeNHuI
 * @date 2022/2/15
 * @describe FileViewFactory
 */
class FileViewFactory(private val mContext: Context, val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>
        return FileView(context = mContext, messenger = messenger, viewId = viewId, args = params)
    }
}