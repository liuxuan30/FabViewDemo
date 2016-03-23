//
//  ViewController.m
//  FabViewDemo
//
//  Created by Xuan on 3/23/16.
//  Copyright © 2016 Wingzero. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *fabView;
@property (assign, nonatomic) BOOL fixedPostionEnabled; // if enabled, the fab view will never move compared to screen
@property (assign, nonatomic) CGRect originFrame; // original frame for fab view
@property (assign, nonatomic) CGFloat distanceToBottom; // distance to bottom screen when fab view pinned to bottom screen
@property (assign, nonatomic) CGFloat offsetWhenReachEnd; // define what contentOffset reached will make the fab view fixed position

@end

@implementation ViewController {
    CGFloat k;
    CGFloat b;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.containerScrollView.delegate = self;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 1000)];
    [self.containerScrollView addSubview:self.backgroundView];
    self.backgroundView.backgroundColor = [UIColor orangeColor];
    self.fabView = [[UIView alloc] initWithFrame:CGRectMake(screenSize.width - 40, 200, 20, 20)];
    self.fabView.backgroundColor = [UIColor blueColor];
    [self.containerScrollView addSubview:self.fabView];
    self.containerScrollView.contentSize = self.backgroundView.bounds.size;
    self.originFrame = self.fabView.frame;
    self.fixedPostionEnabled = YES;
    self.distanceToBottom = CGRectGetHeight(self.fabView.frame) / 2;
    self.offsetWhenReachEnd = 100;
    [self calculateLinear];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self calculateLinear];
}

/**
 *  when fixedPostionEnabled disabled, fab view will move to distanceToBottom away from bottom screen
 *
 *  we calculate a linear move, so when offsetWhenReachEnd == contentOffset.y, it will reach the right position
 */
-(void)calculateLinear {
    b = self.originFrame.origin.y;
    k = (self.offsetWhenReachEnd + CGRectGetHeight(self.containerScrollView.frame) - self.distanceToBottom - CGRectGetHeight(self.originFrame) - b) / (self.offsetWhenReachEnd);

}

/**
 *  main logic, the only variable is contentOffset.y, others are constants and designable, so it's easy to rewrite it as a category
 *
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat visibleHight = scrollView.bounds.size.height;
    if (scrollView == self.containerScrollView) {
        
        if (self.fixedPostionEnabled) { // fab view is fixed position
            self.fabView.frame = CGRectMake(CGRectGetMinX(self.fabView.frame),
                                            self.originFrame.origin.y + scrollView.contentOffset.y,
                                            CGRectGetWidth(self.fabView.frame),
                                            CGRectGetHeight(self.fabView.frame));
        }
        else { // set fixedPostionEnabled = YES in viewDidLoad
            if (scrollView.contentOffset.y > self.offsetWhenReachEnd) {
                if (scrollView.contentOffset.y + visibleHight < scrollView.contentSize.height) {
                    self.fabView.frame = CGRectMake(CGRectGetMinX(self.fabView.frame),
                                                    self.offsetWhenReachEnd * k + b + scrollView.contentOffset.y - self.offsetWhenReachEnd,
                                                    CGRectGetWidth(self.fabView.frame),
                                                    CGRectGetHeight(self.fabView.frame));
                }
            } else {
                if (scrollView.contentOffset.y >= 0) {
                    self.fabView.frame = CGRectMake(CGRectGetMinX(self.fabView.frame),
                                                    scrollView.contentOffset.y * k + b,
                                                    CGRectGetWidth(self.fabView.frame),
                                                    CGRectGetHeight(self.fabView.frame));
                }
            }
        }
    }
}


@end
