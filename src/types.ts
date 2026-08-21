export interface PhotoEditorOptions {
  /**
   * The image to edit. Accepts a local file path, `file://` or `content://`
   * URI, or a remote `http(s)` URL.
   */
  path: string;
  /**
   * Optional list of sticker image URLs shown in the sticker picker.
   */
  stickers?: string[];
  /**
   * BCP-47 language tag (`'fr'`, `'pt-BR'`, `'zh-Hans'`) for the editor UI.
   *
   * Defaults to the device language. Set this only when your app has its own
   * language picker and needs the editor to follow it rather than the device.
   *
   * On Android the tag selects a `values-<lang>` resource folder, so it can be
   * any language your app provides strings for. On iOS it maps onto the
   * languages the underlying editor ships; unsupported tags fall back to
   * English.
   */
  language?: string;
  /**
   * Per-key string overrides, keyed by the editor's string names
   * (`pe_label_save`, `pe_filter_contrast`, ...). See the README for the list.
   *
   * Use this when your strings live in JS rather than in native resources, or
   * to reach a language iOS does not ship. Keys you leave out keep their
   * built-in value, and on Android anything you have already put in a
   * `values-<lang>` folder still applies underneath.
   *
   * Android honours every key. iOS honours the nine the underlying editor
   * exposes; the rest are ignored there.
   */
  translations?: { [key: string]: string };
}
