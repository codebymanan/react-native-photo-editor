import { useState } from 'react';
import {
  Button,
  Image,
  Platform,
  Pressable,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { open } from '@codebymanan/react-native-photo-editor';

const SAMPLE_IMAGE =
  'https://raw.githubusercontent.com/burhanrashid52/PhotoEditor/master/app/src/main/res/drawable/paris_tower.jpg';

const STICKERS = [
  'https://cdn-icons-png.flaticon.com/256/4392/4392452.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392455.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392459.png',
  'https://cdn-icons-png.flaticon.com/256/4392/4392462.png',
];

// Swedish is in neither the iOS editor's 18 languages nor this app's Android
// resources, which is exactly when `translations` is the only way through.
// iOS honours the nine keys the editor exposes; Android honours all of them.
const SWEDISH = {
  pe_label_brush: 'Pensel',
  pe_label_shape: 'Form',
  pe_label_text: 'Text',
  pe_label_eraser: 'Suddgummi',
  pe_label_filter: 'Filter',
  pe_label_emoji: 'Emoji',
  pe_label_sticker: 'Dekal',
  pe_label_cancel: 'Avbryt',
  pe_label_done: 'Klar',
  pe_label_save: 'Spara',
  pe_label_undo: 'Ångra',
  pe_msg_saving: 'Sparar…',
  pe_msg_drag_to_remove: 'Dra hit för att ta bort',
  pe_filter_brightness: 'Ljusstyrka',
  pe_filter_contrast: 'Kontrast',
  pe_filter_saturate: 'Mättnad',
};

// Arabic is the RTL case. iOS ships it; on Android the tag drives the layout
// direction and these strings fill in what the app has no resources for.
const ARABIC = {
  pe_label_brush: 'فرشاة',
  pe_label_shape: 'شكل',
  pe_label_text: 'نص',
  pe_label_eraser: 'ممحاة',
  pe_label_filter: 'مرشح',
  pe_label_emoji: 'إيموجي',
  pe_label_sticker: 'ملصق',
  pe_label_cancel: 'إلغاء',
  pe_label_done: 'تم',
  pe_label_save: 'حفظ',
  pe_label_undo: 'تراجع',
  pe_msg_saving: 'جارٍ الحفظ…',
  pe_filter_brightness: 'السطوع',
  pe_filter_contrast: 'التباين',
  pe_filter_saturate: 'التشبع',
};

// Français comes from android/app/src/main/res/values-fr/strings.xml on Android
// and from the editor's own bundle on iOS, so it needs no translations at all.
const LANGUAGES = [
  { label: 'Device', tag: undefined, translations: undefined },
  { label: 'Français', tag: 'fr', translations: undefined },
  { label: '日本語', tag: 'ja', translations: undefined },
  { label: 'Svenska', tag: 'sv', translations: SWEDISH },
  { label: 'العربية', tag: 'ar', translations: ARABIC },
];

export default function App() {
  const [editedImage, setEditedImage] = useState<string | null>(null);
  const [status, setStatus] = useState('Tap the button to start editing');
  const [selected, setSelected] = useState(LANGUAGES[0]!);
  // Sized from the loaded image so tall photos scroll instead of squashing.
  const [aspectRatio, setAspectRatio] = useState(1);

  const edit = async (path: string) => {
    try {
      setStatus('Editing…');
      const result = await open({
        path,
        stickers: STICKERS,
        language: selected.tag,
        translations: selected.translations,
      });
      setEditedImage(result);
      setStatus(`Saved to: ${result}`);
    } catch (e: any) {
      setStatus(`${e.code ?? 'error'}: ${e.message}`);
    }
  };

  return (
    <ScrollView
      contentContainerStyle={styles.container}
      contentInsetAdjustmentBehavior="automatic"
    >
      <View style={styles.languages}>
        {LANGUAGES.map((entry) => (
          <Pressable
            key={entry.label}
            onPress={() => setSelected(entry)}
            style={[styles.chip, selected === entry && styles.chipSelected]}
          >
            <Text style={selected === entry && styles.chipTextSelected}>
              {entry.label}
            </Text>
          </Pressable>
        ))}
      </View>
      <Button title="Edit photo" onPress={() => edit(SAMPLE_IMAGE)} />
      <Text style={styles.status}>{status}</Text>
      {editedImage && (
        <>
          <Button title="Edit again" onPress={() => edit(editedImage)} />
          <Image
            source={{ uri: `file://${editedImage}` }}
            style={[styles.preview, { aspectRatio }]}
            resizeMode="contain"
            onLoad={(e) => {
              const { width, height } = e.nativeEvent.source;
              if (width > 0 && height > 0) setAspectRatio(width / height);
            }}
          />
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    // iOS insets the scroll view for the safe area itself; Android draws
    // edge-to-edge, so clear the status and navigation bars by hand.
    paddingTop:
      Platform.OS === 'android' ? (StatusBar.currentHeight ?? 0) + 16 : 16,
    paddingBottom: Platform.OS === 'android' ? 64 : 16,
  },
  languages: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: 8,
    marginBottom: 16,
  },
  chip: {
    paddingHorizontal: 12,
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
    marginTop: 12,
  },
});
