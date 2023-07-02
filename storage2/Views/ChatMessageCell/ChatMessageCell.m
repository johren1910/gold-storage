//
//  ChatMessageCell.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatDetailEntity.h"
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
@property (weak, nonatomic)  ChatDetailEntity *cachedMessageModel;
@property (strong, nonatomic) IBOutlet UIButton *retryBtn;

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

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.thumbnailImageView setBackgroundColor:[UIColor clearColor]];
    [self.loadingIndicator stopAnimating];
    self.sizeLabel.text = nil;
    [self.thumbnailImageView setImage:nil];
    [self.timeLabel setHidden:true];
    [self.typeIconView setHidden:true];
    [self.sizeLabel setHidden:true];
    [self.selectedImage setHidden: true];
}

- (void) handleLoadingImageWithUrl:(NSString*) filePath {
    [_loadingIndicator startAnimating];
    __weak ChatMessageCell *weakself = self;
  
    UIImage *image = [FileHelper readFileAtPathAsImage:filePath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.thumbnailImageView setImage:image];
        [weakself.loadingIndicator stopAnimating];
       
    });
}

- (void)compressThenCache: (UIImage*) image withKey:(NSString*)key {
    __weak ChatMessageCell *weakself = self;
    
    [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
        
        [weakself.delegate updateRamCache:compressedImage withKey:key];
    }];
}

- (void) createDownloadHolderView {
    [self.loadingIndicator startAnimating];
    [self.timeLabel setHidden:true];
    [self.typeIconView setHidden:true];
    [self.sizeLabel setHidden:true];
    [self.retryBtn setHidden:true];
    [self.thumbnailImageView setBackgroundColor:[UIColor systemGrayColor]];
}

- (void) createErrorView {
    [self.loadingIndicator stopAnimating];
    [self.timeLabel setHidden:true];
    [self.typeIconView setHidden:true];
    [self.sizeLabel setHidden:true];
    [self.retryBtn setHidden:false];
    [self.thumbnailImageView setBackgroundColor:[UIColor systemRedColor]];
}

- (void)setChat:(ChatDetailEntity *)chat {
    [self prepareForReuse];
    _chat = [chat copy];
    _cachedMessageModel = chat;
    
//    if (chat.isError) {
//        [self createErrorView];
//        return;
//    }
    [self.retryBtn setHidden:true];
    if (_chat.file.type == Download) {
        [self createDownloadHolderView];
    } else {
        [self.selectedImage setHidden: false];
        if (_chat.file.size == 0){
            [self.sizeLabel setHidden: TRUE];
        } else {
            self.sizeLabel.text = [NSString stringWithFormat:@"%.1f MB", _chat.file.size];
            [self.sizeLabel setHidden:FALSE];
        }
        
        if (_chat.selected) {
            self.selectedImage.image = [UIImage imageNamed:@"circle-filled"];
        } else {
            self.selectedImage.image = [UIImage imageNamed:@"circle-empty"];
        }
        
        switch (_chat.file.type) {
            case Video:
                self.typeIconView.image = [UIImage imageNamed:@"video"];
                [self.typeIconView setHidden:false];
                [self.timeLabel setHidden:false];
                self.timeLabel.text = [self timeFormat:_chat.file.duration];
                if (_chat.thumbnail != nil) {
                    [_thumbnailImageView setImage:_chat.thumbnail];
                } else {
                    // TODO: Default video icon
                }
                break;
            case Picture:
                if (_chat.thumbnail != nil) {
                    [_thumbnailImageView setImage:_chat.thumbnail];
                } else {
                    [self handleLoadingImageWithUrl:chat.file.filePath];
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
- (IBAction)onRetryBtn:(id)sender {
    [_delegate retryWithModel:_cachedMessageModel];
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
