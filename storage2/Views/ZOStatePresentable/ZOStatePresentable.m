//
//  ZOStatePresentable.m
//  storage2
//
//  Created by LAP14885 on 22/06/2023.
//

#import <UIKit/UIKit.h>
#import "ZOStatePresentable.h"
#import <Foundation/Foundation.h>
#import "Skeletonable.h"

static CGFloat loadingStateViewZPosition = 100;
static CGFloat emptyStateViewZPosition = 101;
static CGFloat errorStateViewZPosition = 102;
static CGFloat animationDuration = 0.4;

@implementation ZOStatePresenter

@synthesize emptyStateView;
@synthesize errorStateView;
@synthesize loadingStateView;
@synthesize stateContainerView;

-(instancetype) init:(UIView*)stateContainerView  loadingStateView:(SkeletonView*)loadingStateView emptyStateView:(UIView*)emptyStateView errorStateView:(UIView*)errorStateView {
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
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        [weakself.loadingStateView setAlpha:0];
    } completion:^(BOOL finished) {
        [weakself.loadingStateView setHidden:TRUE];
        [weakself.loadingStateView removeFromSuperview];
        if (completionHandler != nil) {
            completionHandler();
        }
    }];
}

-(void) addLoadingViewIfNeeded {
    if (self.loadingStateView.superview == nil) {
        [self.loadingStateView hideSkeleton];
        
        [self.loadingStateView setHidden:YES];
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
        
        NSLayoutConstraint *bottom =[NSLayoutConstraint
                                     constraintWithItem:self.loadingStateView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.stateContainerView
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:0.f];
        
        NSLayoutConstraint *top =[NSLayoutConstraint
                                  constraintWithItem:self.loadingStateView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.stateContainerView
                                  attribute:NSLayoutAttributeTop
                                  multiplier:1.0f
                                  constant:0.f];
        
        [self.stateContainerView addConstraint:trailing];
        [self.stateContainerView addConstraint:bottom];
        [self.stateContainerView addConstraint:leading];
        [self.stateContainerView addConstraint:top];
        
        [loadingStateView setBounds:self.stateContainerView.bounds];
        [loadingStateView showSkeleton];
    }
}

-(void) addEmptyStateViewIfNeeded {
    if (self.emptyStateView.superview == nil && self.emptyStateView != nil) {
        
        [self.emptyStateView setHidden:TRUE];
        self.emptyStateView.layer.zPosition = emptyStateViewZPosition;
        [self.stateContainerView addSubview:self.emptyStateView];
        
        NSLayoutConstraint *trailing =[NSLayoutConstraint
                                       constraintWithItem:self.emptyStateView
                                       attribute:NSLayoutAttributeTrailing
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.stateContainerView
                                       attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0f
                                       constant:0.f];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.emptyStateView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.stateContainerView
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.f];
        
        NSLayoutConstraint *bottom =[NSLayoutConstraint
                                     constraintWithItem:self.emptyStateView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.stateContainerView
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:0.f];
        
        NSLayoutConstraint *top =[NSLayoutConstraint
                                  constraintWithItem:self.emptyStateView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.stateContainerView
                                  attribute:NSLayoutAttributeTop
                                  multiplier:1.0f
                                  constant:0.f];
        
        [self.stateContainerView addConstraint:trailing];
        [self.stateContainerView addConstraint:bottom];
        [self.stateContainerView addConstraint:leading];
        [self.stateContainerView addConstraint:top];
        
        [emptyStateView setBounds:self.stateContainerView.bounds];
    }
}

-(void) addErrorStateViewIfNeeded {
    if (self.errorStateView.superview == nil && self.errorStateView != nil) {
        
        [self.errorStateView setHidden:TRUE];
        self.errorStateView.layer.zPosition = errorStateViewZPosition;
        [self.stateContainerView addSubview:self.errorStateView];
        
        NSLayoutConstraint *trailing =[NSLayoutConstraint
                                       constraintWithItem:self.errorStateView
                                       attribute:NSLayoutAttributeTrailing
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.stateContainerView
                                       attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0f
                                       constant:0.f];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.errorStateView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.stateContainerView
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.f];
        
        NSLayoutConstraint *bottom =[NSLayoutConstraint
                                     constraintWithItem:self.errorStateView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.stateContainerView
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:0.f];
        
        NSLayoutConstraint *top =[NSLayoutConstraint
                                  constraintWithItem:self.errorStateView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.stateContainerView
                                  attribute:NSLayoutAttributeTop
                                  multiplier:1.0f
                                  constant:0.f];
        
        [self.stateContainerView addConstraint:trailing];
        [self.stateContainerView addConstraint:bottom];
        [self.stateContainerView addConstraint:leading];
        [self.stateContainerView addConstraint:top];
        
        [errorStateView setBounds:self.stateContainerView.bounds];
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
        [weakself.errorStateView setAlpha:0];
        [weakself.errorStateView setHidden:FALSE];
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
            [weakself.errorStateView setAlpha:1];
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
        [weakself.emptyStateView setHidden:FALSE];
        [weakself.emptyStateView setAlpha:0];
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
            [weakself.emptyStateView setAlpha:1];
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
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
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
