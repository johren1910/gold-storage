//
//  ZOStatePresentable.h
//  storage2
//
//  Created by LAP14885 on 22/06/2023.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/// This protocol represents the all states of a view that have to load data from a server.
/// At this time this protocol will support to show 3 states of a UIView or UIViewController which will need a show a placeholder when they are loading data
/// from server.
/// - Note: 3 states this protocol propose is `Loading`, `Error` and `Empty`
///
/// To use this protocol you must have to make the `UIView` or the `UIViewController` confirm the protocol `ZOStatePresentable.
/// and also make sure that your have provided the loading view  by confirm `loadingStateView` from `UIView` or `UIViewController`.
///
/// Example for UIViewController:
///
///     @interface HomeViewController () <ZOStatePresentable> {
///     }
///
///     @implementation HomeViewController
///     - (UIView*) loadingStateView {
///     UIView *loadingView = [[UIView alloc] init];
///     [loadingView setBackgroundColor: UIColor.systemPinkColor];
///     [loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
///     [loadingView removeConstraints:loadingView.constraints];
///     return loadingView;
///     }

@protocol ZOStatePresentable

/// [This property is] the container which will keep all of the state views
@property (nonatomic, readwrite, retain) UIView* stateContainerView;

/// [This property is] the  view will show when start fetching data
@property (nonatomic, readwrite, retain) UIView* loadingStateView;

/// [This property is]  the view will show when fetching data run into errors
@property (nonatomic, readwrite, retain) UIView* errorStateView;

/// [This property is] the view will show when fetching empty data
@property (nonatomic, readwrite, retain) UIView* emptyStateView;

/// The action for trigger loading
/// - Parameters:
///    - animated: the flag to enable or disable the animation when hidden a view
///    - completionHandler: Void call back that will be trigger when start loading finished
- (void)startLoading:(BOOL)animated completionHandler:(void (^)(void)) completionHandler;

/// The action for trigger after got the data after fetching data.
///
/// Use this method to hidden all of the states view inside a view or a controller.
/// By default we supported for both of `UIView` and `UIViewController`
///
/// - Parameters:
///    - hasContent:  if this parameter is `true` then hidden the states view
///    - hasError: if this parameters is `true` and `hasContent` is `false` then will show the error state.
///    if this parameters is `false` and `hasContent` is `false` the will show empty state
///    - completionHandler: Void call back that will be trigger when end loading finished
///
- (void)endLoading:(BOOL)hasError hasContent:(BOOL)hasContent completionHandler:(void (^)(void)) completionHandler;
@end

@interface ZOStatePresenter : NSObject <ZOStatePresentable>
-(instancetype) init:(UIView*)stateContainerView  loadingStateView:(UIView*)loadingStateView emptyStateView:(UIView*)emptyStateView errorStateView:(UIView*)errorStateView;
@end
