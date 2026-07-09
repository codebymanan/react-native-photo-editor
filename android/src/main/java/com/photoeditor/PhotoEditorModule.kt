package com.photoeditor

import com.facebook.react.bridge.ReactApplicationContext

class PhotoEditorModule(reactContext: ReactApplicationContext) :
  NativePhotoEditorSpec(reactContext) {

  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  companion object {
    const val NAME = NativePhotoEditorSpec.NAME
  }
}
