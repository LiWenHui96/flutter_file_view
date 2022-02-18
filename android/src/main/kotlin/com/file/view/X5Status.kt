package com.file.view

/**
 * @author LiWeNHuI
 * @date 2022/2/14
 * @describe Loading state of the X5 kernel
 */
object X5Status {
    /**
     * Not initialized
     */
    const val NONE = 0

    /**
     * Ready to start initializing
     */
    const val START = 1

    /**
     * Initialization complete
     */
    const val DONE = 10

    /**
     * Initialization exception
     */
    const val ERROR = 11

    /**
     * Download successful
     */
    const val DOWNLOAD_SUCCESS = 20

    /**
     * Download failed
     */
    const val DOWNLOAD_FAIL = 21

    /**
     * Downloading
     */
    const val DOWNLOADING = 22

    /**
     * Installation succeeded
     */
    const val INSTALL_SUCCESS = 30

    /**
     * Installation failed
     */
    const val INSTALL_FAIL = 31
}