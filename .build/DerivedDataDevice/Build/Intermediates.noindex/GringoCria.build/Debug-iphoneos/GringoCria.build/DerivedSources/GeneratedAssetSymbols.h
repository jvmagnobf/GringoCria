#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "enter_background" asset catalog image resource.
static NSString * const ACImageNameEnterBackground AC_SWIFT_PRIVATE = @"enter_background";

#undef AC_SWIFT_PRIVATE
