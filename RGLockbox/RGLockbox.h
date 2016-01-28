
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

@end
