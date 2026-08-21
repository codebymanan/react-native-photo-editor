package com.photoeditor.editor

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/**
 * Carries the requested editor language from the module to the activity.
 *
 * The tag cannot simply ride along in the intent. [android.app.Activity.attach]
 * calls `attachBaseContext()` before it assigns `mIntent`, so `getIntent()` is
 * still null at the only point where the locale can be applied to the context
 * the layouts are inflated from. The activity reads the tag from here instead,
 * and the intent extra exists only so the activity can notice that this field
 * was lost to a process kill.
 */
internal object EditorLocale {

    /** Set by the module immediately before launching the editor. */
    @Volatile
    var pendingTag: String? = null

    /**
     * Builds the configuration the editor should render under, or null when no
     * usable tag was given.
     *
     * Deliberately does not touch [Locale.setDefault]: that is process-wide
     * state belonging to the host app, and the editor has no business changing
     * it. The returned configuration is a full copy of [base]'s, so applying it
     * keeps night mode, font scale and everything else the host already set.
     */
    fun overrideConfiguration(base: Context, tag: String?): Configuration? {
        val locale = tag?.takeIf { it.isNotBlank() }?.let(Locale::forLanguageTag)
        if (locale == null || locale.language.isEmpty()) return null

        return Configuration(base.resources.configuration).apply {
            setLocale(locale)
            setLayoutDirection(locale)
        }
    }
}
