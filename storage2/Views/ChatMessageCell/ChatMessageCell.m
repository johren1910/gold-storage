//
//  ChatMessageCell.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel.h"
#import "ChatMessageCell.h"
#import "CompressorHelper.h"
#import "FileHelper.h"

@interface ChatMessageCell ()
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (strong, nonatomic) IBOutlet UIImageView *selectedImage;
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

- (void) createDownloadHolderView {
    [self.loadingIndicator startAnimating];
    [self.timeLabel setHidden:true];
    [self.typeIconView setHidden:true];
    [self.sizeLabel setHidden:true];
    [self.thumbnailImageView setBackgroundColor:[UIColor systemGrayColor]];
}

- (void)setChat:(ChatMessageModel *)chat {
    _chat = [chat copy];
    _cachedMessageModel = chat;
    
    if (_chat.messageData.type == Download) {
        [self createDownloadHolderView];
    } else {
        [self.thumbnailImageView setBackgroundColor:[UIColor clearColor]];
        [self.loadingIndicator stopAnimating];
        self.sizeLabel.text = [NSString stringWithFormat:@"%.1f Mb", _chat.messageData.size];
        [self.typeIconView setHidden:true];
        [self.timeLabel setHidden:true];
        [self.thumbnailImageView setImage:nil];
        
        if (_chat.selected) {
            self.selectedImage.image = [UIImage imageNamed:@"circle-filled"];
        } else {
            self.selectedImage.image = [UIImage imageNamed:@"circle-empty"];
        }
        
        switch (_chat.messageData.type) {
            case Video:
                self.typeIconView.image = [UIImage imageNamed:@"video"];
                [self.typeIconView setHidden:false];
                [self.timeLabel setHidden:false];
                self.timeLabel.text = [self timeFormat:_chat.messageData.duration];
                if (_chat.thumbnail != nil) {
                    [_thumbnailImageView setImage:_chat.thumbnail];
                } else {
                    // TODO: Default video icon
                }
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
                [self.sizeLabel setHidden:true];
                break;
        }
    }
}

- (NSString *)timeFormat:(int)duration
{
    if (duration > 3600) {
        int seconds = duration % 60;
        int minutes = (duration / 60) % 60;
        int hours = duration / 3600;

        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    } else {
        int seconds = duration % 60;
        int minutes = (duration / 60) % 60;

        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
}
@end
