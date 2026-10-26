/* global jest */
// Stands in for the native module in Jest, where TurboModules are unavailable.
// Usage: jest.mock('@codebymanan/react-native-photo-editor', () =>
//   require('@codebymanan/react-native-photo-editor/jest/mock'));
module.exports = {
  open: jest.fn(() => Promise.resolve('/tmp/photo_editor/edited.png')),
};
