//
//  ServiceFactory.h
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>

@protocol FactoryResolvable
-(id)register;
-(id)resolve;

@end
