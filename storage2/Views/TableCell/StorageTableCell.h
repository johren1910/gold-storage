//
//  StorageTableCell.h
//  storage2
//
//  Created by LAP14885 on 12/07/2023.
//

#import <UIKit/UIKit.h>
#import "StorageEntity.h"

@interface StorageTableCell : UITableViewCell
-(void)setItem:(StorageSpaceItem*)item;
-(void)didTouch;
@end
