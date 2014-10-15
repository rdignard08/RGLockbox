#import "RGLockbox.h"
#import <Security/Security.h>

CFTypeRef LB_defaultAccessibility(void);

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
    
    NSMutableDictionary* query = (__bridge_transfer NSMutableDictionary*)CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecAttrService, (__bridge const void*)hierarchyKey);
    
    if (!obj) {
        return (SecItemDelete((__bridge CFMutableDictionaryRef)query) == errSecSuccess);
    }

    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecValueData, (__bridge const void*)obj);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecAttrAccessible, accessibility);

    OSStatus status = SecItemAdd((__bridge CFMutableDictionaryRef)query, NULL);
    if (status == errSecDuplicateItem) {
        NSMutableDictionary* update = (__bridge_transfer NSMutableDictionary*)CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        CFDictionarySetValue((__bridge CFMutableDictionaryRef)update, kSecValueData, CFDictionaryGetValue((__bridge CFMutableDictionaryRef)query, kSecValueData));
        CFDictionarySetValue((__bridge CFMutableDictionaryRef)update, kSecAttrAccessible, accessibility);
        CFDictionaryRemoveValue((__bridge CFMutableDictionaryRef)query, kSecAttrAccessible);
        return (SecItemUpdate((__bridge CFMutableDictionaryRef)query, (__bridge CFMutableDictionaryRef)update) == errSecSuccess);
    }
    return (status == errSecSuccess);
}

+ (BOOL) setData:(NSData*)value forKey:(NSString*)key {
    return [self setData:value forKey:key accessibility:LB_defaultAccessibility()];
}

+ (NSData*) dataForKey:(NSString*)key {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", [self bundleIdentifier], key];
    NSMutableDictionary* query = (__bridge_transfer NSMutableDictionary*)CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecAttrService, (__bridge const void*)hierarchyKey);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecReturnData, kCFBooleanTrue);
    CFDataRef data;
    if (SecItemCopyMatching((__bridge CFMutableDictionaryRef)query, (CFTypeRef*)&data) != errSecSuccess) {
        return nil;
    }
    return (__bridge_transfer NSData*)data;
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
