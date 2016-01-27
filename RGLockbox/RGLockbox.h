
#import <Foundation/Foundation.h>

@interface RGLockbox : NSObject

/**
 Returns the singleton instance for managing access to the key chain.  Uses the default namespace.
 */
+ (instancetype) manager;

/**
 Returns an instance of `RGLockbox` which is not default namespaced.
 */
- (instancetype) initWithNamespace:(NSString*)namespace accessibility:(NSString*)accessibility NS_DESIGNATED_INITIALIZER;

/**
 Defaults to the app bundle identifier if unspecified.
 */
@property (nonatomic, strong, readonly) NSString* namespace;

/**
 The default accessibility when checking the keychain, defaults to `kSecAttrAccessibleAfterFirstUnlock`.
 */
@property (nonatomic, strong, readonly) NSString* itemAccessibility;

/**
 Return the object set on key in the current namespace.  Only supports NSData at the moment.
 */
- (NSData*) objectForKey:(NSString*)key;

/**
 Allows `[RGLockbox manager][key] = object` syntax for the above.
 */
- (void) setObject:(NSData*)object forKey:(NSString*)key;


//// vvvv Old interface vvvv
//
///**
// @return `YES` in the event of success; otherwise `NO`.  Error messages are hard :(
// 
// This is the "raw" insertion method.
// */
//+ (BOOL) setData:(NSData*)value forKey:(NSString*)key;
//
//+ (BOOL) setData:(NSData*)value forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// @return the last value that was set for the given key.
// 
// This is the "raw" access method.
// */
//+ (NSData*) dataForKey:(NSString*)key;
//
//+ (NSData*) dataForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// @throw NSInvalidArgument Will bail if `object` cannot be serialized by `NSJSONSerialization`.
// */
//+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key;
//
//+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// If saved with +setJSONObject:forKey: the value can be recovered from this method.
// */
//+ (id) objectForKey:(NSString*)key;
//
//+ (id) objectForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Dates are not part of the JSON standard so they need to be handled in a separate way.
// */
//+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key;
//
//+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Retrieve a date set with +setDate:forKey:
// */
//+ (NSDate*) dateForKey:(NSString*)key;
//
//+ (NSDate*) dateForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Strings aren't allowed as top-level objects in JSON, and most things can become strings easily; hence this method.
// */
//+ (BOOL) setString:(NSString*)value forKey:(NSString*)key;
//
//+ (BOOL) setString:(NSString*)value forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Returns as a string, the value set for key
// */
//+ (NSString*) stringForKey:(NSString*)key;
//
//+ (NSString*) stringForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;

@end
