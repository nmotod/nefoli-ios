#import "OpenInExtension.h"

@implementation OpenInExtension

+ (NSString *)URLScheme {
    // Defined in GCC_PREPROCESSOR_DEFINITIONS build setting (in project.yml).
    return NFL_URL_SCHEME;
}

+ (void)openURL:(NSURL *)url {
    UIApplication *app = [[UIApplication class] valueForKey:@"sharedApplication"];

    [app performSelector:@selector(openURL:) withObject:url];
}

@end
