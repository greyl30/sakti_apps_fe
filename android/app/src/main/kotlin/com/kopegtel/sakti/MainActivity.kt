package com.kopegtel.sakti

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val downloadsChannel = "sakti_apps_fe/downloads"
    private val storagePermissionRequestCode = 7001
    private var pendingDownload: PendingDownload? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, downloadsChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "savePdfToDownloads") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")

                if (fileName.isNullOrBlank() || bytes == null || bytes.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "Data file surat tidak lengkap.", null)
                    return@setMethodCallHandler
                }

                try {
                    val sanitizedFileName = sanitizePdfFileName(fileName)
                    if (requiresLegacyStoragePermission() && !hasLegacyStoragePermission()) {
                        if (pendingDownload != null) {
                            result.error(
                                "DOWNLOAD_IN_PROGRESS",
                                "Proses unduh surat sebelumnya masih berjalan.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        Log.d(
                            "SaktiDownloads",
                            "Requesting WRITE_EXTERNAL_STORAGE for API ${Build.VERSION.SDK_INT}"
                        )
                        pendingDownload = PendingDownload(sanitizedFileName, bytes, result)
                        requestPermissions(
                            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                            storagePermissionRequestCode
                        )
                        return@setMethodCallHandler
                    }

                    val savedPath = savePdfToDownloads(sanitizedFileName, bytes)
                    Log.d("SaktiDownloads", "PDF saved to $savedPath")
                    result.success(savedPath)
                } catch (error: Exception) {
                    Log.e("SaktiDownloads", "Failed to save PDF", error)
                    result.error("SAVE_FAILED", "Gagal menyimpan surat ke Downloads.", error.message)
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (requestCode == storagePermissionRequestCode) {
            val download = pendingDownload
            pendingDownload = null

            if (download == null) {
                super.onRequestPermissionsResult(requestCode, permissions, grantResults)
                return
            }

            val isGranted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (!isGranted) {
                Log.w("SaktiDownloads", "WRITE_EXTERNAL_STORAGE denied")
                download.result.error(
                    "PERMISSION_DENIED",
                    "Izin penyimpanan diperlukan untuk menyimpan surat di Downloads.",
                    null
                )
                return
            }

            try {
                val savedPath = savePdfToDownloads(download.fileName, download.bytes)
                Log.d("SaktiDownloads", "PDF saved to $savedPath after permission grant")
                download.result.success(savedPath)
            } catch (error: Exception) {
                Log.e("SaktiDownloads", "Failed to save PDF after permission grant", error)
                download.result.error(
                    "SAVE_FAILED",
                    "Gagal menyimpan surat ke Downloads.",
                    error.message
                )
            }
            return
        }

        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun savePdfToDownloads(fileName: String, bytes: ByteArray): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            savePdfWithMediaStore(fileName, bytes)
        } else {
            savePdfWithLegacyStorage(fileName, bytes)
        }
    }

    private fun savePdfWithMediaStore(fileName: String, bytes: ByteArray): String {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Tidak dapat membuat file di Downloads.")

        try {
            resolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
            } ?: throw IllegalStateException("Tidak dapat membuka file Downloads.")

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)

            return uri.toString()
        } catch (error: Exception) {
            resolver.delete(uri, null, null)
            throw error
        }
    }

    private fun savePdfWithLegacyStorage(fileName: String, bytes: ByteArray): String {
        val downloadsDirectory = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        if (!downloadsDirectory.exists()) downloadsDirectory.mkdirs()

        val targetFile = File(downloadsDirectory, fileName)
        FileOutputStream(targetFile).use { output ->
            output.write(bytes)
        }

        return targetFile.absolutePath
    }

    private fun sanitizePdfFileName(fileName: String): String {
        val sanitized = fileName
            .replace(Regex("""[\\/:*?"<>|]"""), "_")
            .trim()
            .ifEmpty { "surat-cuti.pdf" }

        return if (sanitized.endsWith(".pdf", ignoreCase = true)) {
            sanitized
        } else {
            "$sanitized.pdf"
        }
    }

    private fun requiresLegacyStoragePermission(): Boolean {
        return Build.VERSION.SDK_INT in Build.VERSION_CODES.M..Build.VERSION_CODES.P
    }

    private fun hasLegacyStoragePermission(): Boolean {
        return checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
            PackageManager.PERMISSION_GRANTED
    }

    private data class PendingDownload(
        val fileName: String,
        val bytes: ByteArray,
        val result: MethodChannel.Result
    )
}
