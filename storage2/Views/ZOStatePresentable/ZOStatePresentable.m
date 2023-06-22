//
//  ZOStatePresentable.m
//  storage2
//
//  Created by LAP14885 on 22/06/2023.
//

#import <UIKit/UIKit.h>
#import "ZOStatePresentable.h"
#import <Foundation/Foundation.h>

static CGFloat loadingStateViewZPosition = 100;
static CGFloat emptyStateViewZPosition = 101;
static CGFloat errorStateViewZPosition = 102;

@implementation ZOStatePresenter

@synthesize emptyStateView;
@synthesize errorStateView;
@synthesize loadingStateView;
@synthesize stateContainerView;

-(instancetype) init:(UIView*)stateContainerView  loadingStateView:(UIView*)loadingStateView emptyStateView:(UIView*)emptyStateView errorStateView:(UIView*)errorStateView {
    self.stateContainerView = stateContainerView;
    self.loadingStateView = loadingStateView;
    self.emptyStateView = emptyStateView;
    self.errorStateView = errorStateView;
    return self;
}

#pragma mark - loadingView
-(void) removeLoadingViewIfNeeded {
    if (self.loadingStateView.superview != nil) {
        [self.loadingStateView setHidden:TRUE];
    }
}

-(void) removeEmptyStateViewIfNeeded {
    if (self.emptyStateView.superview != nil) {
        [self.emptyStateView setHidden:TRUE];
    }
}

-(void) removeErrorStateViewIfNeeded {
    if (self.errorStateView.superview != nil) {
        [self.errorStateView setHidden:TRUE];
    }
}

-(void) hideLoadingView: (void (^)(void)) completionHandler {
    __weak ZOStatePresenter *weakself = self;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        [weakself.loadingStateView setHidden:TRUE];
        } completion:^(BOOL finished) {
            [weakself.loadingStateView removeFromSuperview];
            if (completionHandler != nil) {
                completionHandler();
            }
        }];
}

-(void) addLoadingViewIfNeeded {
    if (self.loadingStateView.superview == nil) {
        [self.loadingStateView setHidden:NO];
        self.loadingStateView.layer.zPosition = loadingStateViewZPosition;
        [self.stateContainerView addSubview:self.loadingStateView];
        [self.stateContainerView bringSubviewToFront:self.loadingStateView];
        
        NSLayoutConstraint *trailing =[NSLayoutConstraint
                                        constraintWithItem:self.loadingStateView
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.stateContainerView
                                        attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0f
                                        constant:0.f];

        NSLayoutConstraint *leading = [NSLayoutConstraint
                                           constraintWithItem:self.loadingStateView
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.stateContainerView
                                           attribute:NSLayoutAttributeLeading
                                           multiplier:1.0f
                                           constant:0.f];

        //Bottom
        NSLayoutConstraint *bottom =[NSLayoutConstraint
                                         constraintWithItem:self.loadingStateView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.stateContainerView
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1.0f
                                         constant:0.f];
        
        //Bottom
        NSLayoutConstraint *top =[NSLayoutConstraint
                                         constraintWithItem:self.loadingStateView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.stateContainerView
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1.0f
                                         constant:0.f];

        NSLayoutConstraint *height = [NSLayoutConstraint
                                       constraintWithItem:self.loadingStateView
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:nil
                                       attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:0
                                       constant:100];
        
        [self.stateContainerView addConstraint:trailing];
        [self.stateContainerView addConstraint:bottom];
        [self.stateContainerView addConstraint:leading];
        [self.stateContainerView addConstraint:top];
    }
}

-(void) addEmptyStateViewIfNeeded {
    if (self.emptyStateView.superview == nil && self.emptyStateView != nil) {
        
        [self.emptyStateView setHidden:TRUE];
        self.emptyStateView.layer.zPosition = emptyStateViewZPosition;
        [self.stateContainerView addSubview:self.emptyStateView];
        
        [self.emptyStateView.leadingAnchor constraintEqualToAnchor:self.stateContainerView.leadingAnchor].active = YES;
        [self.emptyStateView.trailingAnchor constraintEqualToAnchor:self.stateContainerView.trailingAnchor].active = YES;
        [self.emptyStateView.topAnchor constraintEqualToAnchor:self.stateContainerView.topAnchor].active = YES;
        [self.emptyStateView.bottomAnchor constraintEqualToAnchor:self.stateContainerView.bottomAnchor].active = YES;
    }
}

-(void) addErrorStateViewIfNeeded {
    if (self.errorStateView.superview == nil && self.errorStateView != nil) {
        
        [self.errorStateView setHidden:TRUE];
        self.errorStateView.layer.zPosition = errorStateViewZPosition;
        [self.stateContainerView addSubview:self.errorStateView];
        
        [self.errorStateView.leadingAnchor constraintEqualToAnchor:self.stateContainerView.leadingAnchor].active = YES;
        [self.errorStateView.trailingAnchor constraintEqualToAnchor:self.stateContainerView.trailingAnchor].active = YES;
        [self.errorStateView.topAnchor constraintEqualToAnchor:self.stateContainerView.topAnchor].active = YES;
        [self.errorStateView.bottomAnchor constraintEqualToAnchor:self.stateContainerView.bottomAnchor].active = YES;
    }
}

- (void)handleEndLoadingWithContent:(void (^)(void)) completionHandler {
    [self hideLoadingView:completionHandler];
}

- (void)handleEndLoadingWithError:(void (^)(void)) completionHandler {
    
    if (self.errorStateView == nil) {
        [self hideLoadingView:completionHandler];
        return;
    } else {
        [self addErrorStateViewIfNeeded];
        
        __weak ZOStatePresenter *weakself = self;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
            [weakself.errorStateView setHidden:TRUE];
            } completion:^(BOOL finished) {
                [weakself hideLoadingView:completionHandler];
            }];
    }
}

- (void)handleEndLoadingWithEmptyData:(void (^)(void)) completionHandler {
    
    if (self.emptyStateView == nil) {
        [self hideLoadingView:completionHandler];
        return;
    } else {
        [self addEmptyStateViewIfNeeded];
        
        __weak ZOStatePresenter *weakself = self;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
            [weakself.emptyStateView setHidden:TRUE];
            } completion:^(BOOL finished) {
                
                [weakself hideLoadingView:completionHandler];
            }];
    }
}

- (void)startLoading:(BOOL)animated completionHandler:(void (^)(void)) completionHandler {
    [self addLoadingViewIfNeeded];
    [self removeEmptyStateViewIfNeeded];
    [self removeErrorStateViewIfNeeded];
    
    __weak ZOStatePresenter *weakself = self;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        [weakself.loadingStateView setHidden:FALSE];
        } completion:^(BOOL finished) {
            if (completionHandler != nil) {
                completionHandler();
            }
        }];
}

- (void)endLoading:(BOOL)hasError hasContent:(BOOL)hasContent completionHandler:(void (^)(void))completionHandler {
    
    if (hasContent) {
        [self handleEndLoadingWithContent:completionHandler];
    } else if (hasError) {
        [self handleEndLoadingWithError:completionHandler];
    } else {
        [self handleEndLoadingWithEmptyData:completionHandler];
    }
}

@end
