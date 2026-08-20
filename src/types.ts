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
}
