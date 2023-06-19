//
//  ChatMessageCell.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel.h"
#import "ChatMessageCell.h"

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

//    BuildingIcon_ImageView.image=image;
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
        
        NSError* error = nil;
        NSData *pngData = [NSData dataWithContentsOfFile:filePath options: 0 error: &error];

        if (pngData == nil)
        {
           NSLog(@"Failed to read file, error %@", error);
        }
        else
        {
            // parse the value
        }
        
        UIImage *image = [UIImage imageWithData:pngData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.thumbnailImageView setImage:image];
            [weakself.loadingIndicator stopAnimating];
            weakself.cachedImage = image;
        });
    });
}
- (void)setChat:(ChatMessageModel *)chat {
    if (chat.messageId == _cachedMessageModel.messageId) {
        
        return;
    }
    _chat = [chat copy];
    _cachedMessageModel = chat;
    
    self.sizeLabel.text = [NSString stringWithFormat:@"%.1f Mb", _chat.size];
    [self.selectBtn.titleLabel setText:nil];
    [self.typeIconView setHidden:true];
    [self.timeLabel setHidden:true];
    
    switch (_chat.type) {
        case Video:
            self.typeIconView.image = [UIImage imageNamed:@"camera"];
            [self.typeIconView setHidden:false];
            [self.timeLabel setHidden:false];
            self.timeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_chat.duration];
            break;
        case Picture:
            [self handleLoadingImageWithUrl:chat.filePath];
            break;
        default:
            [self.timeLabel setHidden:true];
            [self.typeIconView setHidden:true];
            break;
    }
}

@end
