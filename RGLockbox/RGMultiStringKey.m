/* Copyright (c) 06/19/2016, Ryan Dignard
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

#import "RGMultiStringKey.h"

#define RIGHT_ROTATE_13(number) ((number << 13) | (number >> (sizeof(NSUInteger) * CHAR_BIT - 13)))

@implementation RGMultiStringKey

- (BOOL) isEqual:(RGMultiStringKey*)object {
    return [object isMemberOfClass:[self class]] &&
           ((!object.first && !self.first) || [object.first isEqual:self.first]) &&
           ((!object.second && !self.second) || [object.second isEqual:self.second]);
}

- (NSUInteger) hash { /* without rotate, first = hello, second = world would have the same hash as (world, hello) */
    return self.first.hash ^ RIGHT_ROTATE_13(self.second.hash);
}

- (id) copyWithZone:(__unused NSZone *)zone {
    RGMultiStringKey* copy = [[self class] new];
    copy->_first = self->_first;
    copy->_second = self->_second;
    return copy;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@\n\tfirst:%@\n\tsecond:%@", super.description, self.first, self.second];
}

@end
