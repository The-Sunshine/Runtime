//
//  Person.m
//  method-swizzling
//
//  Created by eagle on 2018/10/18.
//  Copyright © 2018 eagle. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>


@interface Person ()

@property (nonatomic,strong) NSString * address;

@end

@implementation Person

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _address = @"三里屯SOHO";
        self.name = @"zyq";
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"address: %@, name: %@",self.address,self.name];
}

-(void)sayHello
{
    NSLog(@"hello ,I'm at %@",self.address);
}

- (void)interface
{
    NSLog(@"I'm %@",self.name);
}

// runtime归档
- (void)encodeWithCoder:(NSCoder *)coder
{
    encodeRuntime(coder);
}

// runtime解档
- (instancetype)initWithCoder:(NSCoder *)coder
{
    initCoderRuntime(coder);
}


@end
