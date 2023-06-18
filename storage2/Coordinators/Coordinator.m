//
//  Coordinator.m
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
#import "Coordinator.h"

@implementation Coordinator

- (void)start {
    
}

- (void)store: (Coordinator*)coordinator {
    
    [_childCoordinator addObject:coordinator];
}
- (void)free: (Coordinator*)coordinator {
    [_childCoordinator removeObject:coordinator];
}

@end
