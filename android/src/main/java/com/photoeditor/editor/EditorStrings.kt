package com.photoeditor.editor

import android.content.Context
import android.os.Bundle
import android.widget.TextView
import androidx.annotation.StringRes

/**
 * Runtime string overrides supplied through the `translations` option.
 *
 * A `values-<lang>` folder in the host app is still the idiomatic way to
 * translate the editor on Android, and nothing here replaces it. This exists so
 * that one cross-platform map can drive both platforms, because iOS has no
 * equivalent of dropping a resource folder into the app.
 *
 * Keys are resource entry names, so `pe_label_brush` overrides
 * [com.photoeditor.R.string.pe_label_brush]. Keys with no override fall through
 * to the normal resource lookup, which is what keeps `values-<lang>` working
 * alongside this.
 */
internal object EditorStrings {

    @Volatile
    private var overrides: Map<String, String> = emptyMap()

    /**
     * Replaces the current overrides. Called with the intent's extra on every
     * launch, including null, so one session cannot inherit another's strings.
     */
    fun setOverrides(bundle: Bundle?) {
        overrides = bundle?.keySet().orEmpty()
            .mapNotNull { key -> bundle?.getString(key)?.let { key to it } }
            .toMap()
    }

    fun get(context: Context, @StringRes id: Int): String {
        if (overrides.isEmpty()) return context.getString(id)
        val name = runCatching { context.resources.getResourceEntryName(id) }.getOrNull()
        return overrides[name] ?: context.getString(id)
    }
}

/** Sets text through [EditorStrings] rather than straight from resources. */
internal fun TextView.setEditorText(@StringRes id: Int) {
    text = EditorStrings.get(context, id)
}
