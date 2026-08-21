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
}
