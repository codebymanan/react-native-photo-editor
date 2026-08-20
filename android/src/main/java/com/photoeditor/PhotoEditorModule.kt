package com.photoeditor

import android.app.Activity
import android.content.Intent
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.photoeditor.editor.EditImageActivity

class PhotoEditorModule(reactContext: ReactApplicationContext) :
  NativePhotoEditorSpec(reactContext) {

  private var pendingPromise: Promise? = null

  private val activityEventListener = object : BaseActivityEventListener() {
    override fun onActivityResult(
      activity: Activity,
      requestCode: Int,
      resultCode: Int,
      data: Intent?,
    ) {
      if (requestCode != EDITOR_REQUEST_CODE) return
      val promise = pendingPromise ?: return
      pendingPromise = null

      when (resultCode) {
        Activity.RESULT_OK -> {
          val path = data?.getStringExtra(EditImageActivity.RESULT_EXTRA_PATH)
          if (path.isNullOrBlank()) {
            promise.reject(E_FAILED, "Editor returned no image path")
          } else {
            promise.resolve(path)
          }
        }

        Activity.RESULT_CANCELED ->
          promise.reject(E_CANCELLED, "User cancelled image editing")

        EditImageActivity.RESULT_ERROR -> {
          val message = data?.getStringExtra(EditImageActivity.RESULT_EXTRA_ERROR)
          promise.reject(E_FAILED, message ?: "Photo editor failed")
        }

        else -> promise.reject(E_FAILED, "Photo editor failed")
      }
    }
  }

  init {
    reactContext.addActivityEventListener(activityEventListener)
  }

  override fun open(options: ReadableMap, promise: Promise) {
    val activity = currentActivity
    if (activity == null) {
      promise.reject(E_NO_ACTIVITY, "No activity attached to React context")
      return
    }
    if (pendingPromise != null) {
      promise.reject(E_IN_PROGRESS, "Another editor session is already open")
      return
    }

    val path = options.getString("path")
    if (path.isNullOrBlank()) {
      promise.reject(E_INVALID_OPTIONS, "Missing required option: path")
      return
    }

    val stickers = ArrayList<String>()
    options.getArray("stickers")?.let { array ->
      for (i in 0 until array.size()) {
        array.getString(i)?.let(stickers::add)
      }
    }

    pendingPromise = promise

    val intent = Intent(activity, EditImageActivity::class.java)
      .putExtra(EditImageActivity.EXTRA_IMAGE_PATH, path)
      .putStringArrayListExtra(EditImageActivity.EXTRA_STICKERS, stickers)
    activity.startActivityForResult(intent, EDITOR_REQUEST_CODE)
  }

  override fun invalidate() {
    reactApplicationContext.removeActivityEventListener(activityEventListener)
    super.invalidate()
  }

  companion object {
    const val NAME = NativePhotoEditorSpec.NAME

    private const val EDITOR_REQUEST_CODE = 4521

    private const val E_NO_ACTIVITY = "E_NO_ACTIVITY"
    private const val E_IN_PROGRESS = "E_IN_PROGRESS"
    private const val E_INVALID_OPTIONS = "E_INVALID_OPTIONS"
    private const val E_CANCELLED = "E_CANCELLED"
    private const val E_FAILED = "E_FAILED"
  }
}
