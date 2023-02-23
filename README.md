# photo_album_manager


This is the plug-in can quickly get album resources, support for android and iOS

这是可以快速获取相册资源的插件，支持安卓和iOS

## demo
![二维码](https://www.pgyer.com/app/qrcode/SFcx?sign=&auSign=&code=)

## install
```dart
dependencies: photo_album_manager: ^1.2.0
```

## import
```dart
import 'package:photo_album_manager/photo_album_manager.dart';
```

## example
```dart
//先权限申请
PermissionStatus status = await PhotoAlbumManager.checkPermissions();
if (status == PermissionStatus.granted) {
  Toast.show("权限同意", context);
} else {
  Toast.show("权限拒绝", context);
}
//再获取相册资源
List<AlbumModelEntity> photos = await PhotoAlbumManager.getDescAlbum(maxCount: 50);
```

```dart
//或者直接获取相册资源（权限内部判断）
List<AlbumModelEntity> photos = await PhotoAlbumManager.getDescAlbum(maxCount: 50);
```

## api
```dart
/*检查必要权限*/
static Future<PermissionStatus> checkPermissions();

/*判断权限状态是否授予*/
static bool statusIsGranted(PermissionStatus status);

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
static Future<AlbumModelEntity> getOriginalResource(String localIdentifier,
{void onProgress(double progress), void onError(String error)});
```

