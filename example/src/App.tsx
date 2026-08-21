import { useState } from 'react';
import { Button, Image, Pressable, StyleSheet, Text, View } from 'react-native';
import { open } from 'react-native-photo-editor';

const SAMPLE_IMAGE =
  'https://raw.githubusercontent.com/burhanrashid52/PhotoEditor/master/app/src/main/res/drawable/paris_tower.jpg';

const STICKERS = [
  'https://cdn-icons-png.flaticon.com/256/4392/4392452.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392455.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392459.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392462.png',
];

// Android only shows a language the app itself provides strings for, so this
// example ships android/app/src/main/res/values-fr/strings.xml. iOS gets its
// translations from the editor's own bundle.
const LANGUAGES = [
  { label: 'Device', tag: undefined },
  { label: 'Français', tag: 'fr' },
  { label: '日本語', tag: 'ja' },
];

export default function App() {
  const [editedImage, setEditedImage] = useState<string | null>(null);
  const [status, setStatus] = useState('Tap the button to start editing');
  const [language, setLanguage] = useState<string | undefined>(undefined);

  const onEdit = async () => {
    try {
      setStatus('Editing…');
      const result = await open({
        path: SAMPLE_IMAGE,
        stickers: STICKERS,
        language,
      });
      setEditedImage(result);
      setStatus(`Saved to: ${result}`);
    } catch (e: any) {
      setStatus(`${e.code ?? 'error'}: ${e.message}`);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.languages}>
        {LANGUAGES.map(({ label, tag }) => (
          <Pressable
            key={label}
            onPress={() => setLanguage(tag)}
            style={[styles.chip, language === tag && styles.chipSelected]}
          >
            <Text style={language === tag && styles.chipTextSelected}>
              {label}
            </Text>
          </Pressable>
        ))}
      </View>
      <Button title="Edit photo" onPress={onEdit} />
      <Text style={styles.status}>{status}</Text>
      {editedImage && (
        <Image
          source={{ uri: `file://${editedImage}` }}
          style={styles.preview}
          resizeMode="contain"
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
  },
  languages: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 16,
  },
  chip: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#999',
  },
  chipSelected: {
    backgroundColor: '#333',
    borderColor: '#333',
  },
  chipTextSelected: {
    color: '#fff',
  },
  status: {
    marginVertical: 12,
    textAlign: 'center',
  },
  preview: {
    width: '100%',
    flex: 1,
  },
});
