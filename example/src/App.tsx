import { useState } from 'react';
import {
  Button,
  Image,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { open } from 'react-native-photo-editor';

const SAMPLE_IMAGE =
  'https://raw.githubusercontent.com/burhanrashid52/PhotoEditor/master/app/src/main/res/drawable/paris_tower.jpg';

const STICKERS = [
  'https://cdn-icons-png.flaticon.com/256/4392/4392452.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392455.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392459.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392462.png',
];

export default function App() {
  const [editedImage, setEditedImage] = useState<string | null>(null);
  const [status, setStatus] = useState('Tap the button to start editing');

  const onEdit = async () => {
    try {
      setStatus('Editing…');
      const result = await open({ path: SAMPLE_IMAGE, stickers: STICKERS });
      setEditedImage(result);
      setStatus(`Saved to: ${result}`);
    } catch (e: any) {
      setStatus(`${e.code ?? 'error'}: ${e.message}`);
    }
  };

  return (
    <View style={styles.container}>
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
  status: {
    marginVertical: 12,
    textAlign: 'center',
  },
  preview: {
    width: '100%',
    flex: 1,
  },
});
