@interface RGLockbox : NSObject

/**
 @return `YES` in the event of success; otherwise `NO`.  Error messages are hard :(
 */
+ (BOOL) setString:(NSString*)value forKey:(NSString*)key;

/**
 @return the last value that was set for the given key.
 */
+ (NSString*) stringForKey:(NSString*)key;

@end
