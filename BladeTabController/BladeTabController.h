//
//  BladeTabController.h
//  AppSlate
//
//  Created by Tae-han Kim (김태한) on 11. 12. 15..
//  Copyright (c) 2011년 ChocolateSoft. All rights reserved.
//  <blade.kim@gmail.com>

#import <UIKit/UIKit.h>

@interface BladeTabController : UITabBarController
{
    UIButton *actionBtn;
    NSUInteger selectedLayerNumber;
    UIView *menuView;
    NSTimer *t;
    NSMutableArray *deltaArray;
    NSMutableArray *layerArray;
}

- (UIImage *)imageFromLayer:(CALayer *)layer;

@end
