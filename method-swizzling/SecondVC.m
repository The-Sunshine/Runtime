//
//  SecondVC.m
//  method-swizzling
//
//  Created by eagle on 2018/10/15.
//  Copyright © 2018 eagle. All rights reserved.
//

#import "SecondVC.h"
#import <objc/runtime.h>

@implementation SecondVC

/*
 load 和 initialize区别：load是只要类所在文件被引用就会被调用，而initialize是在类或者其子类的第一个方法被调用前调用。所以如果类没有被引用进项目，就不会有load调用；但即使类文件被引用进来，但是没有使用，那么initialize也不会被调用。
 */

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 1.
        Method old = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
        Method new = class_getInstanceMethod(self, @selector(zyqDealloc));
        
        method_exchangeImplementations(old, new);
        
        // 2.
//        [self swizzWithClass:self originSel:NSSelectorFromString(@"dealloc") newSel:@selector(zyqDealloc)];
    });
}

- (void)zyqDealloc
{
    NSLog(@"zyqDealloc");
    
    [self zyqDealloc];
}

+ (void)swizzWithClass:(Class)class originSel:(SEL)originSel newSel:(SEL)newSel{
    
    Method old = class_getInstanceMethod(class, originSel);
    Method new = class_getInstanceMethod(class, newSel);
    
    // 方法指针
    IMP newImp =  method_getImplementation(new);
    
    BOOL addMethodSucess = class_addMethod(class, newSel, newImp, method_getTypeEncoding(new));
    
    if (addMethodSucess) {
        class_replaceMethod(class, originSel, newImp, method_getTypeEncoding(new));
    }else{
        method_exchangeImplementations(old, new);
    }
}

-(void)dealloc
{
    NSLog(@"dealloc");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = ({
        
        UIButton * button = [[UIButton alloc]init];
        button.frame = CGRectMake(100, 100, 100, 100);
        
        button.backgroundColor = [UIColor blackColor];
        [button addTarget:self action:@selector(backClick)   forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:button];
}

- (void)backClick
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
