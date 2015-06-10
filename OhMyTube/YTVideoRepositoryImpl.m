//
//  YTVideoRepositoryImpl.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoRepositoryImpl.h"

NSString *const YTVideoRepositoryErrorDomain = @"YTVideoRepository";
NSString *const YTVideoRepositoryEntityUpdateNotification = @"YTVideoRepositoryEntityUpdate";

@interface YTVideoRepositoryImpl ()
@property (strong, nonatomic) NSMutableArray *collection;
@property (strong, nonatomic) NSMutableDictionary *downloadsInProgress;

@property (strong, nonatomic) AFHTTPSessionManager *httpSessionManager;
@end

@implementation YTVideoRepositoryImpl

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadsInProgress = [NSMutableDictionary new];
        [self setupCollection];
        [self setupHttpSession];
        [self restartDownloadsIfNeeded];
    }
    return self;
}

- (void)setupCollection {
    NSArray *unarchived = [NSKeyedUnarchiver unarchiveObjectWithFile:[self collectionFilePath]];
    if (unarchived == nil) {
        self.collection = [NSMutableArray new];
    }
    else {
        self.collection = [NSMutableArray arrayWithArray:unarchived];
    }
}

- (void)setupHttpSession {
    self.httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    YTVideoRepositoryImpl __weak *welf = self;
    [self.httpSessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTaskInProgress, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSDictionary *downloadDict = welf.downloadsInProgress[@(downloadTaskInProgress.taskIdentifier)];
        if (downloadDict != nil) {
            NSURLSessionDownloadTask *downloadTask = downloadDict[@"task"];
            YTVideo *video = downloadDict[@"video"];
            if (downloadTask != nil && video != nil) {
                double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
                video.downloadProgress = @(progress);
            }
        }
    }];
}

#pragma mark - Helpers

- (NSString*)qualityStringForQuality:(XCDYouTubeVideoQuality)videoQuality {
    NSString *qualityString;
    switch (videoQuality) {
        case XCDYouTubeVideoQualitySmall240:
            qualityString = @"240p";
            break;
            
        case XCDYouTubeVideoQualityMedium360:
            qualityString = @"360p";
            break;
            
        case XCDYouTubeVideoQualityHD720:
            qualityString = @"720p";
            break;
            
        default:
            qualityString = @"default";
            break;
    }
    return qualityString;
}

- (NSString*)fileNameForVideo:(YTVideo *)video quality:(XCDYouTubeVideoQuality)videoQuality {
    NSString *qualityString = [self qualityStringForQuality:videoQuality];
    
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.mp4", video.identifier, qualityString];
    return fileName;
}

- (NSString*)collectionFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"VideoRepositoryData"];
    return filePath;
}

#pragma mark - Private actions

- (void)saveCollection {
    BOOL success = [NSKeyedArchiver archiveRootObject:self.collection toFile:[self collectionFilePath]];
    NSAssert(success, @"Saving must be successful");
}

- (void)getYouTubeVideoForVideo:(YTVideo *)video completion:(void (^)(YTVideo *, NSError *))completion {
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.identifier completionHandler:^(XCDYouTubeVideo *youTubeVideo, NSError *error) {
        if (error == nil) {
            video.youTubeVideo = youTubeVideo;
        }
        else {
            NSLog(@"Error getting video: %@", error);
        }
        completion(video, error);
    }];
}

- (void)restartDownloadsIfNeeded {
    for (YTVideo *video in self.collection) {
        if (video.isDownloaded == NO) {
            YTVideoRepositoryImpl __weak *welf = self;
            [self getYouTubeVideoForVideo:video completion:^(YTVideo *video, NSError *error) {
                if (error == nil) {
                    [welf downloadVideo:video started:^(YTVideo *video, NSError *error) {
                        if (error == nil) {
                            NSLog(@"Restarted download for video with identifier: %@", video.identifier);
                        }
                    }];
                }
            }];
        }
    }
}

- (YTVideo *)videoWithIdentifier:(NSString*)identifier {
    YTVideo *result;
    for (YTVideo *video in self.collection) {
        if ([video.identifier isEqualToString:identifier]) {
            result = video;
            break;
        }
    }
    return result;
}

#pragma mark - <YTVideoRepositoryInterface>

- (void)prepareForDownloadVideoWithIdentifier:(NSString *)videoIdentifier completion:(void (^)(YTVideo *, NSError *))completion  {
    NSAssert(videoIdentifier, @"Identifier must be non-nil");
    
    YTVideo *video = [self videoWithIdentifier:videoIdentifier];
    
    if (video == nil) {
        video = [[YTVideo alloc] initWithIdentifier:videoIdentifier];
    }
    
    if (video.youTubeVideo == nil) {
        [self getYouTubeVideoForVideo:video completion:^(YTVideo *videoOnCompletion, NSError *error) {
            completion(videoOnCompletion, error);
        }];
    }
    else {
        completion(video, nil);
    }
}

- (void)downloadVideo:(YTVideo *)video started:(void (^)(YTVideo *, NSError *))started {
    NSError *error;
    
    if (video == nil || video.youTubeVideo == nil) {
        error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Not enough data to download video", nil)}];
        started(nil, error);
        return;
    }
    
    BOOL isRedownloadingExisting = NO;
    
    YTVideo *duplicateVideo = [self videoWithIdentifier:video.identifier];
    
    if (duplicateVideo != nil) {
        if (duplicateVideo.isDownloaded) {
            error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                    userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"This video is already downloaded", nil)}];
            started(video, error);
            return;
        }
        else {
            // this request is about continuing existing download
            video = duplicateVideo;
            isRedownloadingExisting = YES;
            
            [self stopDownloadForVideo:video];
        }
    }
    
    NSNumber *qualityNumber = [video bestPossibleQuality];
    if (qualityNumber == nil) {
        error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to pick quality", nil)}];
        started(nil, error);
        return;
    }
    
    NSString *qualityString = [self qualityStringForQuality:qualityNumber.unsignedIntegerValue];
    if (qualityString == nil) {
        error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to convert qualty to string", nil)}];
        started(nil, error);
        return;
    }
    
    NSURL *streamURL = video.youTubeVideo.streamURLs[qualityNumber];
    if (streamURL == nil) {
        error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to find stream URL", nil)}];
        started(nil, error);
        return;
    }
    
    NSString *fileName = [self fileNameForVideo:video quality:qualityNumber.unsignedIntegerValue];
    if (fileName == nil) {
        error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to resolve file name", nil)}];
        started(nil, error);
        return;
    }
    
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsURL = [paths lastObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:fileName];
    if (fileURL == nil) {
        error = [NSError errorWithDomain:YTVideoRepositoryErrorDomain code:-1
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to resolve file URL", nil)}];
        started(nil, error);
        return;
    }
    
    NSNumber *duration = @(video.youTubeVideo.duration);
    
    NSURL *thumbnailURL = [video bestPossibleThumbnailURL];
    
    video.title = video.youTubeVideo.title;
    video.qualityString = qualityString;
    video.fileName = fileName;
    video.duration = duration;
    video.thumbnailURL = thumbnailURL;
    video.downloadProgress = @(0.0);
    if (isRedownloadingExisting == NO) {
        [self.collection addObject:video];
    }
    [self saveCollection];
    
    YTVideoRepositoryImpl __weak *welf = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:streamURL];
    NSURLSessionDownloadTask *downloadTask = [self.httpSessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error == nil) {
            NSLog(@"File downloaded to: %@", filePath);
        }
        else if (error.code == NSURLErrorCancelled) {
            NSLog(@"Cancelled download: %@", fileName);
        }
        else {
            NSLog(@"Error downloading file: %@", error);
        }

        [welf.downloadsInProgress removeObjectForKey:@(downloadTask.taskIdentifier)];
        [welf saveCollection];
    }];
    [self.downloadsInProgress setObject:@{@"task":downloadTask, @"video":video} forKey:@(downloadTask.taskIdentifier)];
    [downloadTask resume];
    
    started(video, nil);
}

- (void)stopDownloadForVideo:(YTVideo *)videoToStopDownload {
    NSArray *allDownloadsInProgressKeys = [self.downloadsInProgress allKeys];
    id keyToRemove;
    for (id key in allDownloadsInProgressKeys) {
        NSDictionary *downloadDict =self.downloadsInProgress[key];
        YTVideo *video = downloadDict[@"video"];
        NSURLSessionDownloadTask *task = downloadDict[@"task"];
        if (video == videoToStopDownload) {
            keyToRemove = key;
            [task cancel];
        }
    }
    if (keyToRemove) {
        [self.downloadsInProgress removeObjectForKey:keyToRemove];
    }
}

- (void)deleteVideo:(YTVideo *)videoToDelete {
    if (videoToDelete.fileURL) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:videoToDelete.fileURL error:&error];
        if (error){
            NSLog(@"Error removing file: %@", error);
        }
    }
    [self.collection removeObject:videoToDelete];
}

- (void)stopDownloadAndDeleteVideo:(YTVideo *)video {
    [self stopDownloadForVideo:video];
    [self deleteVideo:video];
}

- (NSArray *)allVideos {
    return [NSArray arrayWithArray:self.collection];
}

@end
