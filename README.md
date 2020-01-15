# photo_album_manager


This is the plug-in can quickly get album resources, support for android and iOS

这是可以快速获取相册资源的插件，支持安卓和iOS


## install


```yaml
dependencies:
photo_album_manager: ^1.0.6
```

## import

```dart
import 'package:album_manager/photo_album_manager.dart';
```

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

1.0.6 版本更新内容
*优化iOS端GIF支持问题
*优化iOS端HEIC格式图片转换JPG问题
