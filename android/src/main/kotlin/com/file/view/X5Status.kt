package com.file.view

/**
 * @author LiWeNHuI
 * @date 2022/2/14
 * @describe Loading state of the X5 kernel
 */
enum class X5Status(val value: Int) {
    /**
     * Not initialized
     */
    NONE(0),

    /**
     * Ready to start initializing
     */
    START(1),

    /**
     * Initialization complete
     */
    DONE(10),

    /**
     * Initialization exception
     */
    ERROR(11),

    /**
     * TbsCommonCode == 100
     *
     * Download successful
     */
    DOWNLOAD_SUCCESS(20),

    /**
     * Download failed
     */
    DOWNLOAD_FAIL(21),

    /**
     * Downloading
     */
    DOWNLOADING(22),

    /**
     * TbsCommonCode == 110
     *
     * Non-required downloads
     */
    DOWNLOAD_NON_REQUIRED(23),

    /**
     * TbsCommonCode == 111
     *
     * Non-Wi-Fi
     */
    DOWNLOAD_CANCEL_NOT_WIFI(24),

    /**
     * TbsCommonCode == 127
     *
     * The number of downloads initiated more than 1 time (only one download is allowed to be initiated for a process)
     */
    DOWNLOAD_OUT_OF_ONE(25),

    /**
     * TbsCommonCode == 133
     *
     * During the download request, the download is not repeated and the download is canceled
     */
    DOWNLOAD_CANCEL_REQUESTING(26),

    /**
     * TbsCommonCode == -122
     *
     * No download request is initiated
     */
    DOWNLOAD_NO_NEED_REQUEST(27),

    /**
     * TbsCommonCode == -134
     *
     * The bandwidth is not allowed, the download is cancelled
     */
    DOWNLOAD_FLOW_CANCEL(28),

    /**
     * Installation succeeded
     */
    INSTALL_SUCCESS(30),

    /**
     * Installation failed
     */
    INSTALL_FAIL(31);
}