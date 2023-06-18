//
//  ChatDetialSectionController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailSectionController.h"

#import "ChatDetailCell.h"
#import "ChatMessageModel.h"

@implementation ChatDetailSectionController {
    ChatMessageModel *_chat;
}

#pragma mark - IGListSectionController Overrides

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    const CGFloat width = self.collectionContext.containerSize.width;
    const CGFloat itemSize = width/3 - self.minimumInteritemSpacing;
    
    return CGSizeMake(itemSize, itemSize);
}

- (UIEdgeInsets)inset {
    UIEdgeInsets myLabelInsets = {self.minimumInteritemSpacing, 0, 0, 0};
    return myLabelInsets;
}


- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    
    ChatDetailCell *cell = (ChatDetailCell *)[self.collectionContext dequeueReusableCellWithNibName:@"ChatDetailCell" bundle:nil forSectionController:self atIndex:index];
    cell.chat = _chat;
    return cell;
}

- (CGFloat)minimumInteritemSpacing {
    return 2;
}

- (void)didUpdateToObject:(id)object {
    _chat = (ChatMessageModel *)object;
}

// MARK: - ListSingleSectionControllerDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
//    NSLog(@"Ngon 1 %@", _chat);
    [_delegate didSelect:_chat];
}
@end

