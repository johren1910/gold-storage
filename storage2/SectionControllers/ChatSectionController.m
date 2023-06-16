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
    
    ChatCell *cell = (ChatCell *)[self.collectionContext dequeueReusableCellWithNibName:@"ChatCell" bundle:nil forSectionController:self atIndex:index];
   
    cell.chat = _chat;
    return cell;
}

- (UIEdgeInsets)inset {
    UIEdgeInsets myInset = { 2, 0, 0, 0};
    return myInset;
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
