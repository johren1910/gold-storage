//
//  BaseCoordinator.m
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
#import "BaseCoordinator.h"

@implementation BaseCoordinator

- (NSMutableArray<Coordinator *> *) childCoordinator {
    return [@[] mutableCopy];
}

- (void)start {
    
}

@end
