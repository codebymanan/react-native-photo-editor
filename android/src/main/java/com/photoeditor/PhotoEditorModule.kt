package com.photoeditor

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import com.photoeditor.editor.EditImageActivity
import com.photoeditor.editor.EditorLocale

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
    val activity = reactApplicationContext.currentActivity
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

    // Assigned unconditionally so a call without a language clears the tag left
    // behind by an earlier one. The activity reads it from attachBaseContext(),
    // which runs before getIntent() is usable.
    val language = options.getString("language")?.takeIf { it.isNotBlank() }
    EditorLocale.pendingTag = language

    val intent = Intent(activity, EditImageActivity::class.java)
      .putExtra(EditImageActivity.EXTRA_IMAGE_PATH, path)
      .putExtra(EditImageActivity.EXTRA_LANGUAGE, language)
      .putExtra(EditImageActivity.EXTRA_TRANSLATIONS, translationsBundle(options))
      .putStringArrayListExtra(EditImageActivity.EXTRA_STICKERS, stickers)
    activity.startActivityForResult(intent, EDITOR_REQUEST_CODE)
  }

  /**
   * Flattens the `translations` option into a Bundle. Non-string values are
   * dropped rather than coerced, so a mistyped entry falls back to the built-in
   * string instead of rendering something like "true".
   */
  private fun translationsBundle(options: ReadableMap): Bundle? {
    val translations = options.getMap("translations") ?: return null
    val bundle = Bundle()
    val iterator = translations.keySetIterator()
    while (iterator.hasNextKey()) {
      val key = iterator.nextKey()
      if (translations.getType(key) != ReadableType.String) continue
      translations.getString(key)?.let { bundle.putString(key, it) }
    }
    return if (bundle.isEmpty) null else bundle
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
