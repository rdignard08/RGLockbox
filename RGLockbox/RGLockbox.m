#import "RGLockbox.h"
#import <Security/Security.h>

static NSString* const _sIsoFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

@implementation RGLockbox

+ (NSString*) bundleIdentifier {
    static dispatch_once_t onceToken;
    static NSString* _sBundleIdentifier;
    dispatch_once(&onceToken, ^{
        _sBundleIdentifier = [[NSBundle bundleForClass:[self class]] infoDictionary][(id)kCFBundleIdentifierKey];
    });
    return _sBundleIdentifier;
}

+ (BOOL) setData:(NSData*)value forKey:(NSString*)key {
    return [self setData:value forKey:key inNameSpace:[self bundleIdentifier] accessibility:kSecAttrAccessibleAlways];
}

+ (BOOL) setData:(NSData*)value forKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    return [self setData:value forKey:key inNameSpace:nameSpace accessibility:kSecAttrAccessibleAlways];
}

+ (BOOL) setData:(NSData*)obj forKey:(NSString*)key inNameSpace:(NSString*)nameSpace accessibility:(CFTypeRef)accessibility {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", nameSpace, key];
    
    NSMutableDictionary* query = (__bridge_transfer NSMutableDictionary*)CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)query, kSecAttrService, (__bridge const void*)hierarchyKey);
    
    if (!obj) {
        return SecItemDelete((__bridge CFMutableDictionaryRef)query) == errSecSuccess;
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
    return status == errSecSuccess;
}

+ (NSData*) dataForKey:(NSString*)key {
    return [self dataForKey:key inNameSpace:[self bundleIdentifier]];
}

+ (NSData*) dataForKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    NSString* hierarchyKey = [NSString stringWithFormat:@"%@.%@", nameSpace, key];
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
    return [self setJSONObject:object forKey:key inNameSpace:[self bundleIdentifier]];
}

+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    if (!object) {
        return [self setData:nil forKey:key inNameSpace:nameSpace];
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        @throw NSInvalidArgumentException;
    }
    return [self setData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] forKey:key inNameSpace:nameSpace];
}

+ (id) objectForKey:(NSString*)key {
    return [self objectForKey:key inNameSpace:[self bundleIdentifier]];
}

+ (id) objectForKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    NSData* data = [self dataForKey:key inNameSpace:nameSpace];
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return nil;
}

+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key {
    return [self setDate:date forKey:key inNameSpace:[self bundleIdentifier]];
}

+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = _sIsoFormat;
    NSString* dateString = [formatter stringFromDate:date];
    return [self setString:dateString forKey:key inNameSpace:nameSpace];
}

+ (NSDate*) dateForKey:(NSString*)key {
    return [self dateForKey:key inNameSpace:[self bundleIdentifier]];
}

+ (NSDate*) dateForKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = _sIsoFormat;
    return [formatter dateFromString:[self stringForKey:key inNameSpace:nameSpace]];
}

+ (BOOL) setString:(NSString*)value forKey:(NSString*)key {
    return [self setString:value forKey:key inNameSpace:[self bundleIdentifier]];
}

+ (BOOL) setString:(NSString*)value forKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    return [self setData:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:key inNameSpace:nameSpace];
}

+ (NSString*) stringForKey:(NSString*)key {
    return [self stringForKey:key inNameSpace:[self bundleIdentifier]];
}
     
+ (NSString*) stringForKey:(NSString*)key inNameSpace:(NSString*)nameSpace {
    NSData* data = [self dataForKey:key inNameSpace:nameSpace];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

@end
