## use

```dart
/*主要方法如下*/

/*获取相册资源(降序) maxCount 为null 获取全部资源*/
static Future<List<AlbumModelEntity>> getDescAlbum({int maxCount});

/*获取相册资源(升序) maxCount 为null 获取全部资源*/
static Future<List<AlbumModelEntity>> getAscAlbum({int maxCount});

/*获取相册图片资源(升序) maxCount 为null 获取全部资源*/
static Future<List<AlbumModelEntity>> getAscAlbumImg({int maxCount});

/*获取相册视频资源(升序) maxCount 为null 获取全部资源*/
static Future<List<AlbumModelEntity>> getAscAlbumVideo({int maxCount});

/*获取相册图片资源(降序) maxCount 为null 获取全部资源*/
static Future<List<AlbumModelEntity>> getDescAlbumImg({int maxCount});

/*获取相册视频资源(降序) maxCount 为null 获取全部资源*/
static Future<List<AlbumModelEntity>> getDescAlbumVideo{int maxCount});

/*通过唯一标识localIdentifier 获取资源（原图、原视频）*/
static Future<AlbumModelEntity> getOriginalImg(String localIdentifier,
{void onProgress(double progress), void onError(String error)});
```
