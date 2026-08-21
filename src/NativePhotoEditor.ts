import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  open(options: {
    path: string;
    stickers?: string[];
    language?: string;
    translations?: { [key: string]: string };
  }): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('PhotoEditor');
