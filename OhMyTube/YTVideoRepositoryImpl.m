//
//  YTVideoRepositoryImpl.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoRepositoryImpl.h"

@interface YTVideoRepositoryImpl ()
@property (strong, nonatomic) NSMutableArray *collection;
@property (strong, nonatomic) NSMutableDictionary *downloadsInProgress;

@property (strong, nonatomic) AFHTTPSessionManager *httpSessionManager;
@end

@implementation YTVideoRepositoryImpl

- (instancetype)init {
    self = [super init];
    if (self) {
        self.collection = [NSMutableArray new];
        self.downloadsInProgress = [NSMutableDictionary new];
        
        self.httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        YTVideoRepositoryImpl __weak *welf = self;
        [self.httpSessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTaskInProgress, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            NSDictionary *downloadDict = welf.downloadsInProgress[@(downloadTaskInProgress.taskIdentifier)];
            if (downloadDict != nil) {
                NSURLSessionDownloadTask *downloadTask = downloadDict[@"task"];
                YTVideoRecord *video = downloadDict[@"video"];
                if (downloadTask != nil && video != nil) {
                    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
                    video.downloadProgress = @(progress);
                }
            }
        }];
    }
    return self;
}

- (void)addVideoWithIdentifier:(NSString *)videoIdentifier completion:(void (^)(YTVideoRecord *, NSError *))completion  {
    NSAssert(videoIdentifier, @"Identifier must be non-nil");
    
    YTVideoRecord *newRecord = [[YTVideoRecord alloc] initWithIdentifier:videoIdentifier];
    [self.collection addObject:newRecord];
    
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        if (error == nil) {
            newRecord.youTubeVideo = video;
        }
        else {
            NSLog(@"Error getting video: %@", error);
        }
        completion(newRecord, error);
    }];
}

- (void)downloadVideo:(YTVideoRecord *)video {
    NSAssert(video, @"Video must be non-nil");
    NSAssert(video.youTubeVideo, @"Video must have youTubeVideo property");
    
    XCDYouTubeVideoQuality quality = XCDYouTubeVideoQualityHD720;
    NSNumber *qualityNum = @(quality);
    NSAssert(qualityNum != nil, @"Quality number must be known");
    
    NSURL *URL = video.youTubeVideo.streamURLs[qualityNum];
    NSAssert(URL, @"There must be a stream URL");
    
    NSString *fileName = [self fileNameForVideo:video quality:quality];
    NSAssert(fileName, @"File name must be defined");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [self.httpSessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:fileName];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [self.downloadsInProgress setObject:@{@"task":downloadTask, @"video":video} forKey:@(downloadTask.taskIdentifier)];
    [downloadTask resume];
}

- (NSString*)fileNameForVideo:(YTVideoRecord*)video quality:(XCDYouTubeVideoQuality)videoQuality {
    NSString *qualityString;
    switch (videoQuality) {
        case XCDYouTubeVideoQualitySmall240:
            qualityString = @"-240p.mp4";
            break;
            
        case XCDYouTubeVideoQualityMedium360:
            qualityString = @"-360p.mp4";
            break;
            
        case XCDYouTubeVideoQualityHD720:
            qualityString = @"-720p.mp4";
            break;
            
        default:
            qualityString = @"-default.mp4";
            break;
    }
    
    NSString *fileName = [video.identifier stringByAppendingString:qualityString];
    return fileName;
}
@end
