/* Copyright (c) 06/12/2016, Ryan Dignard
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#import "RGAtomicMutableDictionary.h"
#import "RGDefines.h"

static const size_t rg_nibbles_per_pointer = (sizeof(void*) * CHAR_BIT) / 4;

/*
 number = [0..15]
 output = '0', '1', '2', '3', '4', '5', '6', '7'
          '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
 */
static char rg_number_to_char(char number) {
    switch (number) {
        case 0 ... 9:
            return '0' + number;
        case 10 ... 15:
        default:
            return ('A' - 10) + number;
    }
}

static char* rg_pointer_to_string(void* pointer) {
    const size_t nibbles_per_byte = CHAR_BIT / 4;
    const size_t output_size = rg_nibbles_per_pointer;
    char* output = malloc(output_size + 1);
    uintptr_t intermediate = (uintptr_t)pointer;
    for (unsigned int i = 0; i < sizeof(void*); i++) {
        for (unsigned int j = 0; j < nibbles_per_byte; j++) {
            char one_letter = rg_number_to_char(intermediate % 16);
            intermediate = intermediate / 16;
            size_t index = output_size - (i * nibbles_per_byte + j + 1);
            output[index] = one_letter;
        }
    }
    output[output_size] = '\0';
    return output;
}

@interface RGAtomicMutableDictionary ()

@property (nonatomic, assign, readonly) char* queueName;
@property (nonatomic, strong) NSMutableDictionary* storage;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation RGAtomicMutableDictionary
@synthesize queueName = _queueName;

- (nonnull instancetype) init {
    self = [super init];
    self->_storage = [NSMutableDictionary new];
    self->_queue = dispatch_queue_create(self.queueName, DISPATCH_QUEUE_CONCURRENT);
    return self;
}

- (nonnull instancetype) initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    self->_storage = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    self->_queue = dispatch_queue_create(self.queueName, DISPATCH_QUEUE_CONCURRENT);
    return self;
}

- (instancetype)initWithObjects:(const RG_SUFFIX_NONNULL __unsafe_unretained id[])objects
                        forKeys:(const RG_SUFFIX_NONNULL __unsafe_unretained id<NSCopying>[])keys
                          count:(NSUInteger)count {
    self = [super init];
    self->_storage = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:count];
    self->_queue = dispatch_queue_create(self.queueName, DISPATCH_QUEUE_CONCURRENT);
    return self;
}

- (void) dealloc {
    free(self->_queueName);
}

#pragma mark -
- (nullable id) objectForKey:(nonnull id<NSCopying>)aKey {
    __block id output;
    dispatch_sync(self.queue, ^{
        output = self.storage[aKey];
    });
    return output;
}

- (void) setObject:(nonnull id)anObject forKey:(nonnull id<NSCopying>)aKey {
    dispatch_barrier_async(self.queue, ^{
        self.storage[aKey] = anObject;
    });
}

- (void) removeObjectForKey:(nonnull id<NSCopying>)aKey {
    dispatch_barrier_async(self.queue, ^{
        [self.storage removeObjectForKey:aKey];
    });
}

- (NSUInteger) count {
    __block NSUInteger output;
    dispatch_sync(self.queue, ^{
        output = self.storage.count;
    });
    return output;
}

- (NSEnumerator*) keyEnumerator {
    __block NSEnumerator* output;
    dispatch_sync(self.queue, ^{
        output = self.storage.keyEnumerator;
    });
    return output;
}

#pragma mark - Properties
- (char*) queueName {
    if (!_queueName) {
        static const char queuePrefix[] = "Atomic-Dictionary-Queue-";
        char* buffer = calloc(sizeof(queuePrefix) + rg_nibbles_per_pointer + 1, 1);
        strcpy(buffer, queuePrefix);
        char* value = rg_pointer_to_string((__bridge void*)self);
        strcpy(buffer + sizeof(queuePrefix) - 1, value);
        free(value);
        _queueName = buffer;
    }
    return _queueName;
}

@end
