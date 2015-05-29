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

- (NSNumber*)bestPossibleQualityForVideo:(YTVideo *)video {
    NSNumber *quality;
    NSArray *qualityOptionsArray = @[@(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)];
    for (NSNumber *qualityNumber in qualityOptionsArray) {
        NSURL *streamURL = video.youTubeVideo.streamURLs[qualityNumber];
        if (streamURL != nil) {
            quality = qualityNumber;
            break;
        }
    }
    return quality;
}

- (NSURL*)bestPossibleThumbnailURLForVideo:(YTVideo *)video {
    NSURL *thumbnailURL;
    if (video.youTubeVideo.largeThumbnailURL != nil) {
        thumbnailURL = video.youTubeVideo.largeThumbnailURL;
    }
    else if (video.youTubeVideo.mediumThumbnailURL != nil) {
        thumbnailURL = video.youTubeVideo.mediumThumbnailURL;
    }
    else if (video.youTubeVideo.smallThumbnailURL != nil) {
        thumbnailURL = video.youTubeVideo.smallThumbnailURL;
    }
    return thumbnailURL;
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
    NSAssert(success, @"Saving tabs must be successful");
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
                    [welf downloadVideo:video];
                }
                else {
                    
                }
            }];
        }
    }
}

#pragma mark - <YTVideoRepositoryInterface>

- (void)addVideoWithIdentifier:(NSString *)videoIdentifier completion:(void (^)(YTVideo *, NSError *))completion  {
    NSAssert(videoIdentifier, @"Identifier must be non-nil");
    
    YTVideo *newRecord = [[YTVideo alloc] initWithIdentifier:videoIdentifier];
    [self.collection addObject:newRecord];
    [self saveCollection];
    
    [self getYouTubeVideoForVideo:newRecord completion:^(YTVideo *video, NSError *error) {
        completion(video, error);
    }];
}

- (void)downloadVideo:(YTVideo *)video {
    NSAssert(video, @"Video must be non-nil");
    NSAssert(video.youTubeVideo, @"Video must have youTubeVideo property");
    
    NSNumber *qualityNumber = [self bestPossibleQualityForVideo:video];
    NSAssert(qualityNumber, @"Quality number must be found");
    
    NSString *qualityString = [self qualityStringForQuality:qualityNumber.unsignedIntegerValue];
    NSAssert(qualityString, @"Quality string must be found");
    
    NSURL *streamURL = video.youTubeVideo.streamURLs[qualityNumber];
    NSAssert(streamURL, @"There must be a stream URL");
    
    NSString *fileName = [self fileNameForVideo:video quality:qualityNumber.unsignedIntegerValue];
    NSAssert(fileName, @"File name must be defined");
    
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsURL = [paths lastObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    NSNumber *duration = @(video.youTubeVideo.duration);
    
    NSURL *thumbnailURL = [self bestPossibleThumbnailURLForVideo:video];
    
    video.title = video.youTubeVideo.title;
    video.qualityString = qualityString;
    video.fileName = fileName;
    video.duration = duration;
    video.thumbnailURL = thumbnailURL;
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

- (NSArray *)videos {
    return [NSArray arrayWithArray:self.collection];
}

@end
