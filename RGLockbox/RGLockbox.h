@interface RGLockbox : NSObject

/**
 @return `YES` in the event of success; otherwise `NO`.  Error messages are hard :(
 
 This is the "raw" insertion method.
 */
+ (BOOL) setData:(NSData*)value forKey:(NSString*)key;

/**
 @return the last value that was set for the given key.
 
 This is the "raw" access method.
 */
+ (NSData*) dataForKey:(NSString*)key;

/**
 @throw NSInvalidArgument Will bail if `object` cannot be serialized by `NSJSONSerialization`.
 */
+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key;

/**
 If saved with +setJSONObject:forKey: the value can be recovered from this method.
 */
+ (id) objectForKey:(NSString*)key;

/**
 Dates are not part of the JSON standard so they need to be handled in a separate way.
 */
+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key;

/**
 Retrieve a date set with +setDate:forKey:
 */
+ (NSDate*) dateForKey:(NSString*)key;

/**
 Strings aren't allowed as top-level objects in JSON, and most things can become strings easily; hence this method.
 */
+ (BOOL) setString:(NSString*)value forKey:(NSString*)key;

+ (NSString*) stringForKey:(NSString*)key;

@end
