//
//  ZODownloadManagerType.h
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import <Foundation/Foundation.h>
#import "ZODownloadUnit.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServiceFactory.h"

#define MAX_DOWNLOAD_CONRRUENT 10
#define MAX_DOWNLOAD_TIMEOUT 10

/// This protocol provide methods to handle all media/files download of a client that need to request from remote server or api.
/// At this time this interface will support to download/pause/resume/cancel the download
/// from server.
///
/// To use this interface you must get the sharedInstance
/// and also make sure that you have configured the `maxConcurrentDownloads` to suit your need

/// - Note: Supported features
///     - Multiple async downloads
///     - Background download
///     - Block based callback
///     - Cancel/Suspend/Resume 1 download or all downloads
///     - Resume interrupted download (App terminate)
///     - Remaining time & speed estimation
///
///     - TODO: RETRY ON FAILED DOWNLOAD
///     - TODO: AUTO RETRY ON GAIN INTERNET
///
@protocol ZODownloadManagerType <FactoryResolvable>

/// The action to trigger new download.
///
/// Use this method to init a new download with your URL, and tracking progress, completion, error with block approach.
/// By default `isBackgroundDownload` is false
///
/// - Parameters:
///    - downloadUrl: an URL to download the files
///    - progressBlock: Call back with progress, speed and remainingSeconds parameter to keep track of file downloading.
///    if this parameters is `false` and `hasContent` is `false` the will show empty state
///    - completionBlack: Call back with a returned destinationPath where the downloaded file stored
///    - errorBlock:Call back with a returned error
///    - isBackgroundDownload:Define if the url session is background supported. Allow to download & resume even when the app crash.
///
- (void)startDownloadWithUrl:(NSString *)downloadUrl destinationDirectory:(NSString *)dstDirectory
        isBackgroundDownload:(BOOL)isBackgroundDownload progressBlock:(ZODownloadProgressBlock)progressBlock
                  completionBlock:(ZODownloadCompletionBlock)completionBlock
                     errorBlock:(ZODownloadErrorBlock)errorBlock;

/// The action to suspend download of the according URL
///
/// - Note: This will allow a new pending task to start if it's waitting
///
/// - Parameters:
///    - url:the url to suspend
- (void)suspendDownloadOfUrl:(NSString *)url;

/// The action to suspend download of the according URL
///
/// - Note: This will suspend all current downloads without triggering the pending queue
- (void)suspendAllDownload;

/// The action to resume  download of the according URL
///
/// - Note: If the maximum count reached, the download will be put into pending queue
///
/// - Parameters:
///    - url:the url to resume
- (void)resumeDownloadOfUrl:(NSString *)url;

/// The action to resume all downloads
///
/// - Note: All Pending, Suspended tasks will be put into pendingQueue
- (void)resumeAllDownload;

/// The action to cancel  download of the according URL
///
/// - Note: If the maximum count reached, the download will be put into pending queue
///
/// - Parameters:
///    - url:the url to cancel
- (void)cancelDownloadOfUrl:(NSString *)url;

/// The action to cancel all downloads
///
/// - Note: This also clear the temp directory
- (void)cancelAllDownload;
@end
