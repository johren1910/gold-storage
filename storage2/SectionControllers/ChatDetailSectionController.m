//
//  ChatDetialSectionController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailSectionController.h"

#import "ChatMessageCell.h"
#import "ChatMessageModel.h"

@interface ChatDetailSectionController () <ChatMessageCellDelegate>
@end

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
    
    ChatMessageCell *cell = (ChatMessageCell *)[self.collectionContext dequeueReusableCellWithNibName:@"ChatMessageCell" bundle:nil forSectionController:self atIndex:index];
    cell.chat = _chat;
    cell.delegate = self;
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
    if (_chat.selected) {
        [_delegate didDeselect:_chat];
    } else {
        [_delegate didSelect:_chat];
    }
}

#pragma mark - ChatMessageCellDelegate
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_delegate updateRamCache:image withKey:key];
}
@end
