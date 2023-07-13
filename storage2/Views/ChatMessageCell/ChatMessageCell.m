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
    [self.thumbnailImageView setBackgroundColor:[UIColor clearColor]];
    [self.loadingIndicator stopAnimating];
    self.sizeLabel.text = nil;
    [self.thumbnailImageView setImage:nil];
    [self.timeLabel setHidden:true];
    [self.typeIconView setHidden:true];
    [self.sizeLabel setHidden:true];
    [self.selectedImage setHidden: true];
    [super prepareForReuse];
}

- (void) handleLoadingImageWithUrl:(NSString*) filePath andChecksum:(NSString*)checksum {
    [_loadingIndicator startAnimating];
    __weak ChatMessageCell *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        UIImage *image = [FileHelper readFileAtPathAsImage:filePath];
        [weakself compressThenCache:image withKey:checksum];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.thumbnailImageView setImage:image];
            [weakself.loadingIndicator stopAnimating];
           
        });
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
//    [self prepareForReuse];
    _chat = [chat copy];
    [self.retryBtn setHidden:true];
    if (_chat.state == Downloading) {
        [self createDownloadHolderView];
    } else {
        [self.loadingIndicator stopAnimating];
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
        
        UIImage* thumbnail = _chat.thumbnail;
        switch (_chat.file.type) {
            case Video:
                self.typeIconView.image = [UIImage imageNamed:@"video"];
                [self.typeIconView setHidden:false];
                [self.timeLabel setHidden:false];
                self.timeLabel.text = [self timeFormat:_chat.file.duration];
                if (thumbnail) {
                    [_thumbnailImageView setImage:thumbnail];
                } else {
                    // TODO: Default video icon
                }
                break;
            case Picture:
                [self.timeLabel setHidden:true];
                if (thumbnail) {
                    [_thumbnailImageView setImage:thumbnail];
                } else {
                    [self handleLoadingImageWithUrl:chat.file.getAbsoluteFilePath andChecksum:chat.file.checksum];
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
