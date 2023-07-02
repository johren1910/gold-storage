//
//  Coordinator.h
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
@interface Coordinator : NSObject
    
@property (strong,nonatomic) NSMutableArray<Coordinator *> *childCoordinator;
    
- (void)start;
- (void)store: (Coordinator*)coordinator;
- (void)free: (Coordinator*)coordinator;

@end
