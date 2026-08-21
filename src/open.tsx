import type { PhotoEditorOptions } from './types';

export function open(_options: PhotoEditorOptions): Promise<string> {
  throw new Error(
    "'@codebymanan/react-native-photo-editor' is only supported on native platforms."
  );
}
