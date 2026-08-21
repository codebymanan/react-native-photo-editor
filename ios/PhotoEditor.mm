#import "PhotoEditor.h"

#if __has_include("PhotoEditor/PhotoEditor-Swift.h")
#import "PhotoEditor/PhotoEditor-Swift.h"
#else
#import "PhotoEditor-Swift.h"
#endif

@implementation PhotoEditor

- (void)open:(JS::NativePhotoEditor::SpecOpenOptions &)options
     resolve:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject
{
    NSString *path = options.path();
    if (path.length == 0) {
        reject(@"E_INVALID_OPTIONS", @"Missing required option: path", nil);
        return;
    }

    NSMutableArray<NSString *> *stickers = [NSMutableArray new];
    if (options.stickers().has_value()) {
        auto vector = options.stickers().value();
        for (size_t i = 0; i < vector.size(); i++) {
            [stickers addObject:vector[i]];
        }
    }

    // Codegen hands dictionaries back untyped, so check before casting.
    id rawTranslations = options.translations();
    NSDictionary *translations = [rawTranslations isKindOfClass:[NSDictionary class]]
        ? (NSDictionary *)rawTranslations
        : nil;

    [PhotoEditorManager open:path
                    stickers:stickers
                    language:options.language()
                translations:translations
                     resolve:^(NSString *outputPath) {
                         resolve(outputPath);
                     }
                      reject:^(NSString *code, NSString *message) {
                          reject(code, message, nil);
                      }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativePhotoEditorSpecJSI>(params);
}

+ (NSString *)moduleName
{
  return @"PhotoEditor";
}

@end
