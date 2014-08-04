#import "RGLockbox.h"
#import <Security/Security.h>

CFTypeRef defaultAccessibility(void);

static NSString* const _sIsoFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

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

+ (BOOL) setData:(NSData*)obj forKey:(NSString*)key accessibility:(CFTypeRef)accessibility {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", [self bundleIdentifier], key];
    
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue(query, kSecAttrService, (__bridge const void*)hierarchyKey);
    
    if (!obj) {
        return (SecItemDelete(query) == errSecSuccess);
    }

    CFDictionarySetValue(query, kSecValueData, (__bridge const void*)obj);
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

+ (BOOL) setData:(NSData*)value forKey:(NSString*)key {
    return [self setData:value forKey:key accessibility:LB_defaultAccessibility()];
}

+ (NSData*) dataForKey:(NSString*)key {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", [self bundleIdentifier], key];
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue(query, kSecAttrService, (__bridge const void*)hierarchyKey);
    CFDictionarySetValue(query, kSecReturnData, kCFBooleanTrue);
    CFDataRef data;
    if (SecItemCopyMatching(query, (CFTypeRef*)&data) != errSecSuccess) {
        return nil;
    }
    return CFBridgingRelease(data);
}

+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key {
    if (!object) {
        return [self setData:nil forKey:key];
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        @throw NSInvalidArgumentException;
    }
    return [self setData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] forKey:key];
}

+ (id) objectForKey:(NSString*)key {
    NSData* data = [self dataForKey:key];
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return nil;
}

+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = _sIsoFormat;
    NSString* dateString = [formatter stringFromDate:date];
    return [self setString:dateString forKey:key];
}

+ (NSDate*) dateForKey:(NSString*)key {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = _sIsoFormat;
    return [formatter dateFromString:[self stringForKey:key]];
}

+ (BOOL) setString:(NSString*)value forKey:(NSString*)key {
    return [self setData:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}
     
+ (NSString*) stringForKey:(NSString*)key {
    NSData* data = [self dataForKey:key];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

@end
