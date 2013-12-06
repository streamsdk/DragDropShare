//
//  AdditionalSourcesViewController.m
//  OBDragDropTest
//
//  Created by Zai Chang on 2/25/13.
//  Copyright (c) 2013 Oblong Industries. All rights reserved.
//

#import "AdditionalSourcesViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface AdditionalSourcesViewController ()

@end

@implementation AdditionalSourcesViewController

-(void) loadView
{
  self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
  
  CGRect viewFrame = CGRectInset(self.view.frame, 12.0, 12.0);
  UIScrollView *sourcesView = [[[UIScrollView alloc] initWithFrame:viewFrame] autorelease];
  sourcesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  sourcesView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
  [self.view addSubview:sourcesView];
  
  
  CGSize margin = CGSizeMake(12.0, 12.0);
  CGFloat itemWidth = sourcesView.bounds.size.width - 2 * margin.width;
  CGFloat itemHeight = itemWidth * 9 / 16.0;
  CGFloat y = margin.height;
  CGRect contentBounds = sourcesView.bounds;
  CGFloat (^randFloat)(CGFloat, CGFloat) = ^(CGFloat min, CGFloat max) { return min + (max-min) * (CGFloat)random() / RAND_MAX; };
  
  for (NSInteger i=0; i<10; i++)
  {
    CGRect frame = CGRectMake(margin.width, y, itemWidth, itemHeight);
    UIView *itemView = [[[UIView alloc] initWithFrame:frame] autorelease];
    itemView.backgroundColor = [UIColor colorWithHue:randFloat(0.0, 1.0) saturation:randFloat(0.5, 1.0) brightness:randFloat(0.3, 1.0) alpha:1.0];
    [sourcesView addSubview:itemView];
    
    // Drag drop with long press gesture
    UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
    [itemView addGestureRecognizer:recognizer];
    
    y += itemHeight + margin.height;
    
    contentBounds = CGRectUnion(contentBounds, frame);
  }
  
  sourcesView.contentSize = contentBounds.size;
}



#pragma mark - OBOvumSource

-(OBOvum *) createOvumFromView:(UIView*)sourceView
{
  OBOvum *ovum = [[[OBOvum alloc] init] autorelease];
  ovum.dataObject = sourceView.backgroundColor;
  return ovum;
}


-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)window
{
  CGRect frame = [sourceView convertRect:sourceView.bounds toView:sourceView.window];
  frame = [window convertRect:frame fromWindow:sourceView.window];
  
  UIView *dragView = [[[UIView alloc] initWithFrame:frame] autorelease];
  dragView.backgroundColor = sourceView.backgroundColor;
  dragView.layer.cornerRadius = 5.0;
  dragView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
  dragView.layer.borderWidth = 1.0;
  dragView.layer.masksToBounds = YES;
  return dragView;
}


-(void) dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location
{
  dragView.transform = CGAffineTransformIdentity;
  dragView.alpha = 0.0;
  
  [UIView animateWithDuration:0.25 animations:^{
    dragView.center = location;
    dragView.transform = CGAffineTransformMakeScale(0.80, 0.80);
    dragView.alpha = 0.75;
  }];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // For the iPhone case
    [UIView animateWithDuration:0.12
                     animations:^{
                       self.view.alpha = 0.0;
                     }];
  }
}

@end
