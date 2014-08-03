#import "RGLockbox.h"
#import <Security/Security.h>

CFTypeRef defaultAccessibility(void);

CFTypeRef LB_defaultAccessibility() {
    static dispatch_once_t onceToken;
    static CFTypeRef _sDefaultAccessibility;
    dispatch_once(&onceToken, ^{
        _sDefaultAccessibility = kSecAttrAccessibleAlways;
    });
    return _sDefaultAccessibility;
}

@implementation RGLockbox

+ (NSString*) bundleIdentifier {
    static dispatch_once_t onceToken;
    static NSString* _sBundleIdentifier;
    dispatch_once(&onceToken, ^{
        _sBundleIdentifier = [[NSBundle bundleForClass:[self class]] infoDictionary][(__bridge NSString*)kCFBundleIdentifierKey];
    });
    return _sBundleIdentifier;
}

+ (BOOL) setString:(NSString*)obj forKey:(NSString*)key accessibility:(CFTypeRef)accessibility {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", [self bundleIdentifier], key];
    
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue(query, kSecAttrService, hierarchyKey);
    
    if (!obj) {
        return (SecItemDelete(query) == errSecSuccess);
    }

    CFDictionarySetValue(query, kSecValueData, [obj dataUsingEncoding:NSUTF8StringEncoding]);
    CFDictionarySetValue(query, kSecAttrAccessible, accessibility);

    OSStatus status = SecItemAdd(query, NULL);
    if (status == errSecDuplicateItem) {
        CFMutableDictionaryRef update = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        CFDictionarySetValue(update, kSecValueData, CFDictionaryGetValue(query, kSecValueData));
        CFDictionarySetValue(update, kSecAttrAccessible, accessibility);
        CFDictionaryRemoveValue(query, kSecAttrAccessible);
        return (SecItemUpdate(query, update) == errSecSuccess);
    }
    return (status == errSecSuccess);
}

+ (BOOL) setString:(NSString*)value forKey:(NSString*)key {
    return [self setString:value forKey:key accessibility:LB_defaultAccessibility()];
}

+ (NSString*) stringForKey:(NSString*)key {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", [self bundleIdentifier], key];
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue(query, kSecAttrService, hierarchyKey);
    CFDictionarySetValue(query, kSecReturnData, kCFBooleanTrue);
    NSData* data;
    if (SecItemCopyMatching(query, (CFTypeRef*)&data) != errSecSuccess || !data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
