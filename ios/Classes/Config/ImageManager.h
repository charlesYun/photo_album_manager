//
//  ImageManager.h
//  photo_album_manager
//
//  Created by amber on 2023/2/24.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageManager : NSObject
/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

@property (nonatomic, assign) BOOL shouldFixOrientation;

@property (nonatomic, strong) NSMutableDictionary *assertDict;

+ (instancetype)manager;

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;
@end

NS_ASSUME_NONNULL_END
