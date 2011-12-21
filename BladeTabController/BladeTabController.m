//
//  BladeTabController.m
//  AppSlate
//
//  Created by Tae-han Kim (김태한) on 11. 12. 15..
//  Copyright (c) 2011년 ChocolateSoft. All rights reserved.
//  <blade.kim@gmail.com>

#import "BladeTabController.h"
#import <QuartzCore/QuartzCore.h>

#define LIMIT_Y     300.0

@implementation BladeTabController


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


-(void)viewWillAppear:(BOOL)animated
{
    UIView *contentView;
    if ( [[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] ) {
        contentView = [self.view.subviews objectAtIndex:1];
    } else {
        contentView = [self.view.subviews objectAtIndex:0];
    }
    
    contentView.frame = self.view.bounds;
    [self.tabBar setHidden:YES];

    // Menu Start Button
    actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 435, 40, 40)];
    [actionBtn setTitle:@"≣" forState:UIControlStateNormal];
    [actionBtn.titleLabel setTextAlignment:UITextAlignmentCenter];
    [actionBtn setBackgroundColor:[UIColor redColor]];
    [actionBtn.layer setCornerRadius:8.0];
    [actionBtn.layer setBorderWidth:3.0];
    [actionBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [actionBtn.layer setShadowOpacity:1.0];
    [actionBtn.layer setShadowRadius:6.0];
    [actionBtn.layer setShadowColor:[UIColor blackColor].CGColor];
    [actionBtn.layer setShadowOffset:CGSizeMake(3, 3)];
    [actionBtn addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:actionBtn];
    
    deltaArray = [[NSMutableArray alloc] initWithCapacity:5];
    CGFloat totalHop = LIMIT_Y / self.viewControllers.count;
    for( NSUInteger i = 1; i <= self.viewControllers.count; i++ ){
        [deltaArray addObject:[NSNumber numberWithFloat:(totalHop*i) / 10.0]];
//        NSLog(@"d %d:%@",i,[deltaArray lastObject]);
    }

    layerArray = [[NSMutableArray alloc] initWithCapacity:5];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

// 정해진 탭 인덱스의 저장된 이미지를 반환한다.
-(id)getImageBufferAtIndex:(NSUInteger) idx
{
    UIView *sView = ((UIViewController*)[self.viewControllers objectAtIndex:idx]).view;

    return (id)([self imageFromLayer:sView.layer].CGImage);
}

#pragma mark - Actions

// Started whole the animated effect from here.
-(void) menuAction
{
    for( NSUInteger i = 0 ; i < [self.viewControllers count]; i++ )
    {
        CALayer *cLayer = [CALayer layer];
        [layerArray addObject:cLayer];

        cLayer.contents = [self getImageBufferAtIndex:i];
        cLayer.frame = self.view.frame;
        if( self.selectedIndex != i )
            cLayer.opacity = 0.0;
    }

    menuView = [[UIView alloc] initWithFrame:self.view.frame];
    [menuView setUserInteractionEnabled:NO];
    [menuView.layer setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor].CGColor];
    for( CALayer *layer in layerArray )
        [menuView.layer addSublayer:layer];

    [self.view addSubview:menuView];

    t = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                          target: self
                                        selector:@selector(onOpenTick:)
                                        userInfo:nil repeats:YES];
}

-(void) menuSelectAction:(id)sender
{
    [menuView setUserInteractionEnabled:NO];
    selectedLayerNumber = ((UIButton*)sender).tag - 1;

    NSUInteger idx = 0;
    for( CALayer *clayer in layerArray ){
        clayer.shadowOffset = CGSizeMake(0, 0);
        clayer.shadowOpacity = 0.0f;
        if( selectedLayerNumber != idx )
            [clayer setOpacity:0];
        idx++;
    }

    t = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                         target: self
                                       selector:@selector(onCloseTick:)
                                       userInfo:nil repeats:YES];

}

#pragma mark - Open and Close

-(void)onOpenTick:(NSTimer*)timer
{
    static CGFloat d = 5.0, op = 0.0;
    NSUInteger idx = 0;
    CATransform3D aTransform = CATransform3DMakeRotation((3.141f/180.0f)*d, -1.0f, 0.0f, 0.0f);
    aTransform.m24 = 1.0 / 1500.0;

    for( CALayer *clayer in layerArray ){
        [clayer setTransform:aTransform];
        if( 1.0 > clayer.opacity )
            [clayer setOpacity:op];
        [clayer setPosition:CGPointMake(clayer.position.x, clayer.position.y+(((NSNumber*)[deltaArray objectAtIndex:idx]).floatValue))];
        idx++;
    }
    
    d = d + 10.0;
    op = op + 0.1;

    // end of animation.
    if( 45.0 <= d ){
        d = 3.0; op = 0.0;
        idx = 1;
        [menuView setUserInteractionEnabled:YES];
        for( CALayer *clayer in layerArray ){
            [clayer setOpacity:1.0];
            [clayer setPosition:CGPointMake(clayer.position.x, 240.0+((LIMIT_Y/layerArray.count)*idx))];
            // hack: 4th layer position is not controled properly. I don know the reason now.
            if( idx >= 4 ) [clayer setPosition:CGPointMake(clayer.position.x, clayer.position.y+(((NSNumber*)[deltaArray objectAtIndex:idx-1]).floatValue))];

            UIButton *b = [[UIButton alloc] initWithFrame:clayer.frame];
            [b setTag:idx];
            [b addTarget:self action:@selector(menuSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [menuView addSubview:b];
            idx ++;
            // It will be slow, but good shape.
            //clayer.shadowColor = [UIColor blackColor].CGColor;
            //clayer.shadowOffset = CGSizeMake(0, -6);
            //clayer.shadowOpacity = 0.7f;
        }
        
        [timer invalidate];
    }
}

-(void)onCloseTick:(NSTimer*)timer
{
    static CGFloat d = 40.0, op = 1.0;
    NSUInteger idx = 0;
    CATransform3D aTransform = CATransform3DMakeRotation((3.141f/180.0f)*d, -1.0f, 0.0f, 0.0f);
    aTransform.m24 = 1.0 / 1500.0;
    
    for( CALayer *clayer in layerArray ){
        [clayer setTransform:aTransform];
        [clayer setPosition:CGPointMake(clayer.position.x, clayer.position.y-(((NSNumber*)[deltaArray objectAtIndex:idx]).floatValue))];
        idx++;
    }

    d = d - 10.0;
    
    if( 5.0 >= d ){
        d = 40.0; op = 1.0;        
        [layerArray removeAllObjects];
        [menuView removeFromSuperview];
        [timer invalidate];
        [self setSelectedIndex:selectedLayerNumber];
    }
}

@end
