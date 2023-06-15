//
//  ChatSectionController.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatSectionController.h"

#import "ChatCell.h"
#import "ChatModel.h"

@implementation ChatSectionController {
    ChatModel *_chat;
}

#pragma mark - IGListSectionController Overrides

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    const CGFloat width = self.collectionContext.containerSize.width;
    const CGFloat height = 74.0;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    const Class cellClass = [ChatCell class];
    ChatCell *cell = (ChatCell *)[self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    cell.chat = _chat;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    _chat = (ChatModel *)object;
}

@end
