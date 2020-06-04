# photo_album_manager


This is the plug-in can quickly get album resources, support for android and iOS

这是可以快速获取相册资源的插件，支持安卓和iOS


## install

```yaml
dependencies:
photo_album_manager: ^1.1.4
```

## import

```dart
import 'package:photo_album_manager/photo_album_manager.dart';
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

## log

```dart
1.1.4 版本更新内容
*优化pubspec.yaml文件部分语法问题
```

```dart
1.1.3 版本更新内容
*优化安卓插件EventBus 因混淆导致的release版本异常
```

```dart
1.1.2 版本更新内容
*优化iOS相册加载速度
```

```dart
1.1.1 版本更新内容
*优化安卓端第一次相册权限申请后无法获取数据问题

注意：如果没有自己提前申请相册权限需要添加以下操作，参考项目中的example

1、EasyPermissions and EventBus is installed by adding the following dependency to your build.gradle file:

dependencies {
    // For developers using AndroidX in their applications
    implementation 'pub.devrel:easypermissions:3.0.0'
 
    // For developers using the Android Support Library
    implementation 'pub.devrel:easypermissions:2.0.1'
    
    implementation 'org.greenrobot:eventbus:3.2.0'
}

2、MainActivity类修改

public class MainActivity extends FlutterActivity implements EasyPermissions.PermissionCallbacks  {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
  }

  /*权限通过*/
  @Override
  public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
    EventBus.getDefault().post(new MessageEvent());
  }

  /*权限拒绝*/
  @Override
  public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
  
  }
}
```

```dart
1.1.0 版本更新内容
*优化安卓端相册权限申请
```

```dart
1.0.9 版本更新内容
*优化安卓端相册权限申请
```

```dart
1.0.8 版本更新内容
*适配版本v1.12.13+hotfix.9
```

```dart
1.0.7 版本更新内容
*优化Android端缓存问题
```

```dart
1.0.6 版本更新内容
*优化iOS端GIF支持问题
*优化iOS端HEIC格式图片转换JPG问题
```





