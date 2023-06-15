//
//  ChatDetialSectionController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailSectionController.h"

#import "ChatDetailCell.h"
#import "ChatDetailModel.h"

@implementation ChatDetailSectionController {
    ChatDetailModel *_chat;
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
    const Class cellClass = [ChatDetailCell class];
    ChatDetailCell *cell = (ChatDetailCell *)[self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    cell.chat = _chat;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    _chat = (ChatDetailModel *)object;
}

// MARK: - ListSingleSectionControllerDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
//    NSLog(@"Ngon 1 %@", _chat);
    [_delegate didSelect:_chat];
}
@end

