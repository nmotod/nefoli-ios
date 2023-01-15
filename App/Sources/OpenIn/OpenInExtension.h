#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenInExtension : NSObject

+ (NSString *)URLScheme;

+ (void)openURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
