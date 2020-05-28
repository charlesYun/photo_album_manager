#import "PhotoAlbumManagerPlugin.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "AlbumModelEntity.h"
#import "ConstString.h"

//缓存路径
#define kCachePath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:@"AlbumCache"]
//图片资源类型
#define kResourceImg @"image"
//视频资源类型
#define kResourceVideo @"video"
//gif资源类型
#define kResourceGif @"gif"
//回调
typedef void (^FlutterResult)(id _Nullable result);

@interface PhotoAlbumManagerPlugin ()<FlutterStreamHandler>

@property (nonatomic, strong) PHImageRequestOptions *imageRequestOption;
@property (nonatomic, strong) PHImageRequestOptions *thumbOption;
@property (nonatomic, strong) PHVideoRequestOptions *videoRequestOption;
@property (nonatomic, strong) NSMutableArray <AlbumModelEntity *> *albumList;
@property (nonatomic, copy) FlutterResult resultBlock;
@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation PhotoAlbumManagerPlugin

- (instancetype)init {
    if (self = [super init]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[kCachePath stringByAppendingPathComponent:@"image"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[kCachePath stringByAppendingPathComponent:@"image"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:[kCachePath stringByAppendingPathComponent:@"video"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[kCachePath stringByAppendingPathComponent:@"video"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

#pragma mark - 获取相册资源（视频） maxCount最大个数
- (void)getAlbumDataAsc:(BOOL)asc maxCount:(NSInteger)maxCount video:(BOOL)video {
    [self getAlbumDataAsc:asc maxCount:maxCount image:NO video:video localIdentifier:nil];
}

#pragma mark - 获取相册资源（图片） maxCount最大个数
- (void)getAlbumDataAsc:(BOOL)asc maxCount:(NSInteger)maxCount image:(BOOL)image {
    [self getAlbumDataAsc:asc maxCount:maxCount image:image video:NO localIdentifier:nil];
}

#pragma mark - 获取相册资源（图片、视频） maxCount最大个数
- (void)getAlbumDataAsc:(BOOL)asc maxCount:(NSInteger)maxCount {
    [self getAlbumDataAsc:asc maxCount:maxCount image:YES video:YES localIdentifier:nil];
}

#pragma mark - 通过标识符获取原始资源
- (void)getOriginalResource:(NSString *)localIdentifier {
    [self getAlbumDataAsc:YES maxCount:1 image:YES video:YES localIdentifier:localIdentifier];
}

#pragma mark - 获取相册资源 asc 是否升序 maxCount 最大资源数 image 是否加载图片 video 是否加载视频 localIdentifier PHAsset id单独获取使用
- (void)getAlbumDataAsc:(BOOL)asc maxCount:(NSInteger)maxCount image:(BOOL)image video:(BOOL)video localIdentifier:(NSString *)localIdentifier {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:asc]];
            PHFetchResult *result = nil;
            if (localIdentifier) {
                //根据唯一标识符单独获取
                result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
                self.imageRequestOption.networkAccessAllowed = YES;
                self.videoRequestOption.networkAccessAllowed = YES;
            }else {
                if (image && !video) {
                    allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
                }else if (!image && video) {
                    allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
                }
                result = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
                self.imageRequestOption.networkAccessAllowed = NO;
                self.videoRequestOption.networkAccessAllowed = NO;
            }
            [self.albumList removeAllObjects];
            dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
            dispatch_group_t group = dispatch_group_create();
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            for (NSInteger i=0; i<result.count; i++) {
                //获取maxCount固定数值 maxCount <= 0 表示全部
                if (maxCount > 0 && i == maxCount) {
                    break;
                }
                PHAsset *asset = result[i];
                AlbumModelEntity *model = [[AlbumModelEntity alloc] init];
                model.photoAsset = asset;
                model.index = i;
                [self.albumList addObject:model];
                dispatch_group_enter(group);
                [self getResource:model queue:queue group:group localIdentifier:localIdentifier];
            }
            dispatch_group_notify(group, queue, ^{
                NSLog(@"加载完成");
                CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
                NSLog(@"方法耗时: %f ms", endTime * 1000.0);
                [self.albumList sortUsingComparator:^NSComparisonResult(AlbumModelEntity * obj1, AlbumModelEntity *obj2) {
                    if (obj1.index < obj2.index) {
                        return NSOrderedAscending;
                    }else {
                        return NSOrderedDescending;
                    }
                }];
                if (self->_resultBlock) {
                    NSMutableArray *albums = [NSMutableArray array];
                    for (AlbumModelEntity *model in self.albumList) {
                        [albums addObject:[model toDictionary]];
                    }
                    self.resultBlock(albums);
                }
            });
        }
    }];
}

#pragma mark - 通过PHAsset 获取资源
- (void)getResource:(AlbumModelEntity *)model queue:(dispatch_queue_t)queue group:(dispatch_group_t)group localIdentifier:(NSString *)localIdentifier {
    NSString *assetName = [model.photoAsset valueForKey:@"filename"];
    BOOL isGif = [self isGif:assetName.pathExtension];
    assetName = [assetName stringByDeletingPathExtension];
    NSString *cacheThumbPath = [NSString stringWithFormat:@"%@/image/%@-thumb.jpg",kCachePath,assetName];
    NSString *cacheImagePath = [NSString stringWithFormat:@"%@/image/%@.%@",kCachePath,assetName,isGif ? @"gif" : @"jpg"];
    NSString *cacheVideoPath = [NSString stringWithFormat:@"%@/video/%@.mp4",kCachePath,assetName];
    NSString *key = [NSString stringWithFormat:@"%@-fileSize",assetName];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    model.setLocalIdentifier(model.photoAsset.localIdentifier);

    //资源大小计算
    if (@available(iOS 9, *)) {
        NSDictionary *fileSize = [userDefaults objectForKey:key];
        if (!fileSize) {
            PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:model.photoAsset] firstObject];
            long long longValue = [[resource valueForKey:@"fileSize"] longLongValue];
            NSNumber *longlongNumber = [NSNumber numberWithLongLong:longValue];
            NSString *longlongStr = [longlongNumber stringValue];
            model.setResourceSize(longlongStr).setCreationDate(model.photoAsset.creationDate);
            [userDefaults setObject:@{@"size":longlongStr,@"date":model.photoAsset.creationDate} forKey:key];
            [userDefaults synchronize];
        }else {
            model.setResourceSize(fileSize[@"size"]).setCreationDate(fileSize[@"date"]);
        }
    }
    
    //资源类型
    if (model.photoAsset.mediaType == PHAssetMediaTypeImage) {
        if (isGif) {
            model.setResourceType(kResourceGif);
        }else {
            model.setResourceType(kResourceImg);
        }
    }else if (model.photoAsset.mediaType == PHAssetMediaTypeVideo) {
        model.setResourceType(kResourceVideo);
    }
    
    //先判断缩略图是否存在
    if ([manager fileExistsAtPath:cacheThumbPath]) {
        model.setThumbPath(cacheThumbPath);
        if (model.photoAsset.mediaType == PHAssetMediaTypeImage) {
            //原图是否存在
            if ([manager fileExistsAtPath:cacheImagePath]) {
                model.setOriginalPath(cacheImagePath);
            }
        }else if (model.photoAsset.mediaType == PHAssetMediaTypeVideo) {
            //视频是否存在
            if ([manager fileExistsAtPath:cacheVideoPath]) {
                model.setOriginalPath(cacheVideoPath);
                NSTimeInterval time = [model.photoAsset duration];
                model.setVideoDuration([NSString stringWithFormat:@"%lf",time]);
            }
        }
        dispatch_group_leave(group);
        if ((model.thumbPath && !localIdentifier) || (model.originalPath && localIdentifier)) {
            return;
        }
        dispatch_group_enter(group);
    }
    
    //获取缩略图
    dispatch_async(queue, ^{
        @autoreleasepool {
            [[PHImageManager defaultManager] requestImageForAsset:model.photoAsset targetSize:CGSizeMake(125, 125) contentMode:PHImageContentModeAspectFill options:self.thumbOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                BOOL boolValue = [UIImagePNGRepresentation(result) writeToFile:cacheThumbPath atomically:YES];
                if (boolValue) {
                    model.setThumbPath(cacheThumbPath);
                }
                dispatch_group_leave(group);
            }];
        }
    });
    
    //默认不获取原始资源
    if (!self.imageRequestOption.networkAccessAllowed && !self.videoRequestOption.networkAccessAllowed) {
        return;
    }
    
    //判断是否存在于iCloud
    if (@available(iOS 9, *)) {
        NSArray *resourceArray = [PHAssetResource assetResourcesForAsset: model.photoAsset];
        BOOL locallyAvailable = [[resourceArray.firstObject valueForKey: @"locallyAvailable"] boolValue];
        if (!locallyAvailable && !localIdentifier) {
            return;
        }
    }

    if (model.photoAsset.mediaType == PHAssetMediaTypeImage) {
        //原图
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            @autoreleasepool {
                [[PHImageManager defaultManager] requestImageDataForAsset:model.photoAsset options:self.imageRequestOption resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    //是否存在Cloud端
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![info objectForKey:@"PHImageFileSandboxExtensionTokenKey"]) {
                        dispatch_group_leave(group);
                    }else if (imageData) {
                        BOOL boolValue = [imageData writeToFile:cacheImagePath atomically:YES];
                        if (boolValue) {
                            model.setOriginalPath(cacheImagePath);
                        }
                        dispatch_group_leave(group);
                    }else {
                        dispatch_group_leave(group);
                    }
                }];
            }
        });
    }else if (model.photoAsset.mediaType == PHAssetMediaTypeVideo) {
        //原视频
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            @autoreleasepool {
                [[PHImageManager defaultManager] requestAVAssetForVideo:model.photoAsset options:self.videoRequestOption resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    //是否存在Cloud端
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![info objectForKey:@"PHImageFileSandboxExtensionTokenKey"]) {
                        NSTimeInterval time = [model.photoAsset duration];
                        model.setVideoDuration([NSString stringWithFormat:@"%lf",time]);
                        dispatch_group_leave(group);
                    }else {
                        //判断视频是否已经缓存过
                        if ([manager fileExistsAtPath:cacheVideoPath]) {
                            NSTimeInterval time = [model.photoAsset duration];
                            model.setOriginalPath(cacheVideoPath).setVideoDuration([NSString stringWithFormat:@"%lf",time]);
                            dispatch_group_leave(group);
                        }else {
                            NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
                            if ([presets containsObject:AVAssetExportPresetMediumQuality]) {
                                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
                                exportSession.outputURL = [NSURL fileURLWithPath:cacheVideoPath];
                                exportSession.shouldOptimizeForNetworkUse = true;
                                NSArray *supportedTypeArray = exportSession.supportedFileTypes;
                                if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
                                    exportSession.outputFileType = AVFileTypeMPEG4;
                                    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:asset degrees:[self degressFromVideoFileWithAsset:asset]];
                                    if (videoComposition.renderSize.width) {
                                        //修正视频转向
                                        exportSession.videoComposition = videoComposition;
                                    }
                                    //开始导出
                                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                        switch (exportSession.status) {
                                            case AVAssetExportSessionStatusCancelled:
                                            case AVAssetExportSessionStatusUnknown:
                                            case AVAssetExportSessionStatusFailed: {
                                                if ([asset isKindOfClass:[AVURLAsset class]]) {
                                                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                                                    NSURL *url = urlAsset.URL;
                                                    NSData *videoData = [NSData dataWithContentsOfURL:url];
                                                    [videoData writeToFile:cacheVideoPath atomically:YES];
                                                    NSTimeInterval time = [model.photoAsset duration];
                                                    model.setOriginalPath(cacheVideoPath).setVideoDuration([NSString stringWithFormat:@"%lf",time]);
                                                }else {
                                                    if (self.eventSink) {
                                                        self.eventSink([exportSession.error localizedFailureReason]);
                                                    }
                                                }
                                                dispatch_group_leave(group);
                                            }
                                                break;
                                            case AVAssetExportSessionStatusCompleted: {
                                                NSTimeInterval time = [model.photoAsset duration];
                                                model.setOriginalPath(cacheVideoPath).setVideoDuration([NSString stringWithFormat:@"%lf",time]);
                                                dispatch_group_leave(group);
                                            }
                                                break;
                                            default:
                                                break;
                                        }
                                    }];
                                }else {
                                    if (self.eventSink) {
                                        self.eventSink(MP4ExportNotSupported);
                                    }
                                    dispatch_group_leave(group);
                                }
                            }else {
                                if (self.eventSink) {
                                    self.eventSink(ResolutionExportNotSupported);
                                }
                                dispatch_group_leave(group);
                            }
                        }
                    }
                }];
            }
        });
    }
}

#pragma mark -获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset degrees:(int)degrees {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

#pragma mark - 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

#pragma mark - 是否是GIF判断
- (BOOL)isGif:(NSString *)extension {
    if ([extension isEqualToString:@"GIF"]) {
        return YES;
    }
    return NO;
}

#pragma mark - 注册交互
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    //flutter主动调用交互
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"photo_album_manager" binaryMessenger:[registrar messenger]];
    PhotoAlbumManagerPlugin *instance = [[PhotoAlbumManagerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    //原生主动调用交互
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"photo_album_manager_back" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

#pragma mark - <FlutterStreamHandler>
#pragma mark -flutter开始进行监听
- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

#pragma mark -fluuter主动调用交互回调
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getDescAlbum" isEqualToString:call.method]) {
        //逆序获取相册资源
        self.resultBlock = result;
        NSInteger count = 0;
        if (call.arguments) {
            count = [NSString stringWithFormat:@"%@",call.arguments].integerValue;
        }
        [self getAlbumDataAsc:NO maxCount:count];
    }else if ([@"getAscAlbum" isEqualToString:call.method]) {
        //顺序获取相册资源
        self.resultBlock = result;
        NSInteger count = 0;
        if (call.arguments) {
            count = [NSString stringWithFormat:@"%@",call.arguments].integerValue;
        }
        [self getAlbumDataAsc:YES maxCount:count];
    }else if ([@"getAscAlbumImg" isEqualToString:call.method]) {
        //顺序获取相册图片
        self.resultBlock = result;
        NSInteger count = 0;
        if (call.arguments) {
            count = [NSString stringWithFormat:@"%@",call.arguments].integerValue;
        }
        [self getAlbumDataAsc:YES maxCount:count image:YES];
    }else if ([@"getAscAlbumVideo" isEqualToString:call.method]) {
        //顺序获取相册视频
        self.resultBlock = result;
        NSInteger count = 0;
        if (call.arguments) {
            count = [NSString stringWithFormat:@"%@",call.arguments].integerValue;
        }
        [self getAlbumDataAsc:YES maxCount:count video:YES];
    }else if ([@"getDescAlbumImg" isEqualToString:call.method]) {
        //逆序获取相册图片
        self.resultBlock = result;
        NSInteger count = 0;
        if (call.arguments) {
            count = [NSString stringWithFormat:@"%@",call.arguments].integerValue;
        }
        [self getAlbumDataAsc:NO maxCount:count image:YES];
    }else if ([@"getDescAlbumVideo" isEqualToString:call.method]) {
        //逆序获取相册视频
        self.resultBlock = result;
        NSInteger count = 0;
        if (call.arguments) {
            count = [NSString stringWithFormat:@"%@",call.arguments].integerValue;
        }
        [self getAlbumDataAsc:NO maxCount:count video:YES];
    }else if ([@"getOriginalResource" isEqualToString:call.method]) {
        //获取原始资源
        self.resultBlock = result;
        NSString *localIdentifier = [NSString stringWithFormat:@"%@",call.arguments];
        [self getOriginalResource:localIdentifier];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - lazy
- (PHImageRequestOptions *)imageRequestOption {
    if (!_imageRequestOption) {
        _imageRequestOption = [[PHImageRequestOptions alloc] init];
        _imageRequestOption.resizeMode = PHImageRequestOptionsResizeModeFast;
        _thumbOption.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        _imageRequestOption.synchronous = YES;
        _imageRequestOption.networkAccessAllowed = NO;
        __weak __typeof(self) weakself = self;
        _imageRequestOption.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            weakself.eventSink(@(progress));
        };
    }
    return _imageRequestOption;
}

- (PHImageRequestOptions *)thumbOption {
    if (!_thumbOption) {
        _thumbOption = [[PHImageRequestOptions alloc] init];
        _thumbOption.resizeMode = PHImageRequestOptionsResizeModeFast;
        _thumbOption.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        _thumbOption.networkAccessAllowed = NO;
        _thumbOption.synchronous = YES;
    }
    return _thumbOption;
}

- (PHVideoRequestOptions *)videoRequestOption {
    if (!_videoRequestOption) {
        _videoRequestOption = [[PHVideoRequestOptions alloc] init];
        _videoRequestOption.version = PHVideoRequestOptionsVersionOriginal;
        _imageRequestOption.synchronous = YES;
        _videoRequestOption.networkAccessAllowed = NO;
        __weak __typeof(self) weakself = self;
        _videoRequestOption.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            weakself.eventSink(@(progress));
        };
    }
    return _videoRequestOption;
}

- (NSMutableArray <AlbumModelEntity *>*)albumList {
    if (!_albumList) {
        _albumList = [NSMutableArray array];
    }
    return _albumList;
}

@end
