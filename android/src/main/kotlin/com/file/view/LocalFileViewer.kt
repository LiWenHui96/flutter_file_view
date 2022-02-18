package com.file.view

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import com.tencent.smtt.sdk.TbsReaderView
import com.tencent.smtt.sdk.TbsReaderView.*
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import java.io.File

/**
 * @author LiWeNHuI
 * @date 2022/2/15
 * @describe LocalFileView
 */
class LocalFileViewer internal constructor(context: Context, args: Map<String, Any>) : PlatformView,
    ReaderCallback {
    private val tempPrefixPath = context.cacheDir.toString() + File.separator + "TbsFileReaderTmp"

    private var mTbsReaderView: TbsReaderView = TbsReaderView(context, this)

    /**
     * Open File
     */
    private fun openFile(args: Map<String, Any>) {
        val tempFile = File(tempPrefixPath)
        if (!tempFile.exists() || !tempFile.isDirectory) {
            tempFile.mkdir()
        }

        // 加载文件
        val bundle = Bundle()
        bundle.putString(KEY_FILE_PATH, args[KEY_FILE_PATH] as String)
        bundle.putBoolean(IS_BAR_SHOWING, args[IS_BAR_SHOWING] as Boolean)
        bundle.putBoolean(IS_INTO_DOWNLOADING, args[IS_INTO_DOWNLOADING] as Boolean)
        bundle.putBoolean(IS_BAR_ANIMATING, args[IS_BAR_ANIMATING] as Boolean)
        bundle.putString(KEY_TEMP_PATH, tempPrefixPath)
        mTbsReaderView.openFile(bundle)
    }

    /**
     * Determine whether the file can be opened
     *
     * @return
     */
    private fun isSupportFile(fileType: String?): Boolean {
        if (fileType == null) return false
        return mTbsReaderView.preOpen(fileType, false)
    }

    override fun getView(): View {
        return mTbsReaderView
    }

    override fun dispose() {
        Log.i(TAG, "$TAG Dispose")

        mTbsReaderView.onStop()
    }

    override fun onCallBackAction(p0: Int?, p1: Any?, p2: Any?) {
        TODO("Not yet implemented")
    }

    companion object {
        val TAG: String = LocalFileViewer::class.java.name
    }

    init {
        Log.i(TAG, "$TAG Start")

        mTbsReaderView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        if (isSupportFile(args["fileType"] as String?)) openFile(args)
    }
}