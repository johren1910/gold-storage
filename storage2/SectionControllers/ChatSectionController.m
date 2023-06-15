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

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    const CGFloat width = self.collectionContext.containerSize.width;
    const CGFloat itemSize = width/3;
    
    return CGSizeMake(itemSize, itemSize);
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

// MARK: - ListSingleSectionControllerDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
//    NSLog(@"Ngon 1 %@", _chat);
    [_delegate didSelect:_chat];
}
@end
