//
//  Person.h
//  method-swizzling
//
//  Created by eagle on 2018/10/18.
//  Copyright © 2018 eagle. All rights reserved.
//

#import <Foundation/Foundation.h>

#define encodeRuntime(A) \
\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([A class], &count);\
for (int i = 0; i<count; i++) {\
Ivar ivar = ivars[i];\
const char *name = ivar_getName(ivar);\
NSString *key = [NSString stringWithUTF8String:name];\
id value = [self valueForKey:key];\
[A encodeObject:value forKey:key];\
}\
free(ivars);\

#define initCoderRuntime(A) \
\
if (self = [super init]) {\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([A class], &count);\
for (int i = 0; i<count; i++) {\
Ivar ivar = ivars[i];\
const char *name = ivar_getName(ivar);\
NSString *key = [NSString stringWithUTF8String:name];\
id value = [A decodeObjectForKey:key];\
[self setValue:value forKey:key];\
}\
free(ivars);\
}\
return self;\


NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject <NSObject>

@property (nonatomic,strong) NSString * name;

- (void)sayHello;

@end

NS_ASSUME_NONNULL_END
