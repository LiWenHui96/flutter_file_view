package com.file.view

/**
 * @Author: LiWeNHuI
 * @Date: 2021/9/13
 * @Describe: X5内核加载状态
 */
object X5Status {
    /**
     * Not initialized
     * 尚未初始化
     */
    const val INIT = 0

    /**
     * Initializing
     * 正在初始化
     */
    const val INIT_LOADING = 1

    /**
     * Initialization succeeded
     * 初始化成功
     */
    const val SUCCESS = 10

    /**
     * Initialization failed
     * 初始化失败
     */
    const val FAIL = 11

    /**
     * Download succeeded
     * 下载成功
     */
    const val DOWNLOAD_SUCCESS = 20

    /**
     * Download failed
     * 下载失败
     */
    const val DOWNLOAD_FAIL = 21

    /**
     * Downloading
     * 正在下载
     */
    const val DOWNLOAD_LOADING = 22

    /**
     * Installation succeeded
     * 安装成功
     */
    const val INSTALL_SUCCESS = 30

    /**
     * Installation failed
     * 安装失败
     */
    const val INSTALL_FAIL = 31
}
