//
//  AlbumModelEntity.h
//  photo_album_manager
//
//  Created by 曹云霄 on 2019/8/19.
//

#import <Foundation/Foundation.h>

@class PHAsset;
@class FlutterStandardTypedData;

@interface AlbumModelEntity : NSObject

/**
 创建时间
 */
@property (nonatomic, copy) NSString *creationDate;
- (AlbumModelEntity *(^)(NSDate *))setCreationDate;

/**
 资源唯一标识(下载原图或原视频使用)
 */
@property (nonatomic, copy) NSString *localIdentifier;
- (AlbumModelEntity *(^)(NSString *))setLocalIdentifier;

/**
 资源大小
 */
@property (nonatomic, copy) NSString *resourceSize;
- (AlbumModelEntity *(^)(NSString *))setResourceSize;

/**
 缩略图路径或视频第一帧图片路径
 */
@property (nonatomic, copy) NSString *thumbPath;
- (AlbumModelEntity *(^)(NSString *))setThumbPath;

/**
 资源路径
 */
@property (nonatomic, copy) NSString *originalPath;
- (AlbumModelEntity *(^)(NSString *))setOriginalPath;

/**
 视频时长
 */
@property (nonatomic, copy) NSString *videoDuration;
- (AlbumModelEntity *(^)(NSString *))setVideoDuration;

/**
 资源类型 image 或 video 或 gif
 */
@property (nonatomic, copy) NSString *resourceType;
- (AlbumModelEntity *(^)(NSString *))setResourceType;

/**********************************************************/

/**
 照片PHAsset
 */
@property (nonatomic, strong) PHAsset *photoAsset;

/**
 下标
 */
@property (nonatomic, assign) NSInteger index;

/**
 转字典

 @return NSDictionary
 */
- (NSDictionary *)toDictionary;

@end

