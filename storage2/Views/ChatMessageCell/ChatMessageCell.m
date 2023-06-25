//
//  ChatMessageCell.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel.h"
#import "ChatMessageCell.h"
#import "CacheManager.h"
#import "CompressorHelper.h"
#import "FileHelper.h"

@interface ChatMessageCell ()
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (strong, nonatomic) IBOutlet UIButton *selectBtn;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeIconView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic)  UIImage *cachedImage;
@property (weak, nonatomic)  ChatMessageModel *cachedMessageModel;

@end

@implementation ChatMessageCell

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     [indicator startAnimating];
     [indicator setCenter:_thumbnailImageView.center];
     [_thumbnailImageView addSubview:indicator];

    [indicator removeFromSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void) handleLoadingImageWithUrl:(NSString*) filePath {
    [_loadingIndicator startAnimating];
    __weak ChatMessageCell *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.load", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        
        UIImage *image = [FileHelper readFileAtPathAsImage:filePath];
        
        [weakself compressThenCache:image  withKey:weakself.chat.messageData.messageId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.thumbnailImageView setImage:image];
            [weakself.loadingIndicator stopAnimating];
            weakself.cachedImage = image;
        });
    });
}

- (void)compressThenCache: (UIImage*) image withKey:(NSString*)key {
    __weak ChatMessageCell *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cache.image", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
            
            [weakself.delegate updateRamCache:compressedImage withKey:key];
        }];
    });
}

- (void)setChat:(ChatMessageModel *)chat {
    if (chat.messageData.messageId == _cachedMessageModel.messageData.messageId) {
        
        return;
    }
    _chat = [chat copy];
    _cachedMessageModel = chat;
    
    self.sizeLabel.text = [NSString stringWithFormat:@"%.1f Mb", _chat.messageData.size];
    [self.selectBtn.titleLabel setText:nil];
    [self.typeIconView setHidden:true];
    [self.timeLabel setHidden:true];
    [self.thumbnailImageView setImage:nil];
    
    switch (_chat.messageData.type) {
        case Video:
            self.typeIconView.image = [UIImage imageNamed:@"camera"];
            [self.typeIconView setHidden:false];
            [self.timeLabel setHidden:false];
            self.timeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_chat.messageData.duration];
            break;
        case Picture:
            // Read ram-cache
            if (_chat.thumbnail != nil) {
                [_thumbnailImageView setImage:_chat.thumbnail];
            } else {
                [self handleLoadingImageWithUrl:chat.messageData.filePath];
            }
            break;
        default:
            [self.timeLabel setHidden:true];
            [self.typeIconView setHidden:true];
            break;
    }
}

@end
