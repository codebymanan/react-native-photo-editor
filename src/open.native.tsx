import PhotoEditor from './NativePhotoEditor';
import type { PhotoEditorOptions } from './types';

export function open(options: PhotoEditorOptions): Promise<string> {
  return PhotoEditor.open(options);
}
