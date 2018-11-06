//
//  ViewController.m
//  method-swizzling
//
//  Created by eagle on 2018/10/15.
//  Copyright © 2018 eagle. All rights reserved.
//

#import "ViewController.h"
#import "SecondVC.h"
#import <objc/runtime.h>
#import "Person.h"

@interface ViewController ()

@end

//iOS模块分解 runtime面试题
//https://www.jianshu.com/p/19f280afcb24

//Runtime Method Swizzling开发实例汇总（持续更新中）
//https://www.jianshu.com/p/f6dad8e1b848

//什么时候会报unrecognized selector错误？iOS有哪些机制来避免走到这一步？

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self runtimeAddClass];
    
//    [self runtimeChangePrivateProperty];
    
    //打印私有方法
//    [self private];
}

#pragma mark - 运行时 动态添加类 添加成员变量
- (void)runtimeAddClass
{
    //1.动态添加一个类
    Class cls = objc_allocateClassPair([NSObject class], "RuntimeClass", 0);
    
    //2.为类添加成员变量
    class_addIvar(cls, "name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    class_addIvar(cls, "age", sizeof(int), sizeof(int), @encode(int));
    
    //3.为类添加方法
    SEL s = sel_registerName("runtimeMethod");
    class_addMethod(cls, s, (IMP)testRuntimeIMP, "i@:@");
    
    //4.注册类到Runtime
    objc_registerClassPair(cls);
    
    //初始化实例
    id person = [[cls alloc]init];
    
    //打印类名和父类
    NSLog(@"类名 - %@, 父类 - %@",object_getClass(person),class_getSuperclass(object_getClass(person)));
    
    //根据名字得到实例变量的Ivar指针
    Ivar name = class_getInstanceVariable(cls, "name");
    //为属性赋值
    [person setValue:@"eagle" forKey:@"name"];
    
    Ivar age = class_getInstanceVariable(cls, "age");
    object_setIvar(person, age, @18);
    
    //打印属性值
    NSLog(@"name - %@,age - %@",object_getIvar(person, name),object_getIvar(person, age));
    
    //调用 添加的方法
    NSDictionary * dic = @{@"name":@"eagle",@"age":@"20"};
    [person performSelector:@selector(runtimeMethod) withObject:dic];
    
}

void testRuntimeIMP(id self,SEL _cmd,NSDictionary * dic)
{
    NSLog(@"dic - %@",dic);
    NSLog(@"name - %@",object_getIvar(self, class_getInstanceVariable([self class], "name")));
}

#pragma mark - 运行时 获取私有属性 强制更改私有属性
- (void)runtimeChangePrivateProperty
{
    Person * p = [[Person alloc]init];
    NSLog(@"first time : %@",[p description]);
    
    unsigned int count = 0;
    
    //获取私有属性key数组
    Ivar * members =class_copyIvarList([Person class], &count);
    
    for (int i = 0; i < count; i ++) {
        
        Ivar var = members[i];
        
        //获取私有属性key
        const char * memberAddress = ivar_getName(var);
        
        //获取私有属性类型
        const char * memberType = ivar_getTypeEncoding(var);
        
        NSLog(@"address = %s ; type = %s",memberAddress,memberType);
    }
    
    Ivar name = members[0];
    Ivar address = members[1];
    
    //修改私有属性
    object_setIvar(p, address, @"美丽会");
    object_setIvar(p, name, @"z");
    
    NSLog(@"second time : %@",[p description]);
}

//获取私有方法
- (void)private
{
    unsigned int count = 0;
    
    Method * member = class_copyMethodList([Person class], &count);
    
    for (int i = 0; i < count; i ++) {
        
        SEL address = method_getName(member[i]);
        NSString * name = [NSString stringWithCString:sel_getName(address) encoding:NSUTF8StringEncoding];
        NSLog(@"member method : %@",name);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SecondVC * vc = [[SecondVC alloc]init];
    vc.view.backgroundColor = [UIColor yellowColor];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
