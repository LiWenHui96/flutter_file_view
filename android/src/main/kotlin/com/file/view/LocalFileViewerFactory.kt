package com.file.view

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * @author LiWeNHuI
 * @date 2022/2/15
 * @describe LocalFileViewFactory
 */
class LocalFileViewerFactory(private val mContext: Context) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>
        return LocalFileViewer(mContext, params)
    }
}