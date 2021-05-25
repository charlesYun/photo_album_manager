import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'album_model_entity.dart';

export 'album_model_entity.dart';
export 'package:permission_handler/permission_handler.dart';

class PhotoAlbumManager {
  /*flutter主动调用交互*/
  static const MethodChannel _channel =
      const MethodChannel('photo_album_manager');

  /*原生主动调用交互*/
  static const EventChannel _eventChannel =
      const EventChannel('photo_album_manager_back');

  /*检查必要权限*/
  static Future<PermissionStatus> checkPermissions() {
    if (Platform.isIOS) {
      return Permission.photos.request();
    } else {
      return Permission.storage.request();
    }
  }

  /*判断权限状态是否授予*/
  static bool statusIsGranted(PermissionStatus status) {
    if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  /*获取相册资源(降序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getDescAlbum({int? maxCount}) async {
    PermissionStatus status = await checkPermissions();
    if (statusIsGranted(status)) {
      List list = await _channel.invokeMethod('getDescAlbum', maxCount);
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album;
    } else {
      return Future.error(status);
    }
  }

  /*获取相册资源(升序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getAscAlbum({int? maxCount}) async {
    PermissionStatus status = await checkPermissions();
    if (statusIsGranted(status)) {
      List list = await _channel.invokeMethod('getAscAlbum', maxCount);
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album;
    } else {
      return Future.error(status);
    }
  }

  /*获取相册图片资源(升序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getAscAlbumImg({int? maxCount}) async {
    PermissionStatus status = await checkPermissions();
    if (statusIsGranted(status)) {
      List list = await _channel.invokeMethod('getAscAlbumImg', maxCount);
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album;
    } else {
      return Future.error(status);
    }
  }

  /*获取相册视频资源(升序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getAscAlbumVideo(
      {int? maxCount}) async {
    PermissionStatus status = await checkPermissions();
    if (statusIsGranted(status)) {
      List list = await _channel.invokeMethod('getAscAlbumVideo', maxCount);
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album;
    } else {
      return Future.error(status);
    }
  }

  /*获取相册图片资源(降序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getDescAlbumImg({int? maxCount}) async {
    PermissionStatus status = await checkPermissions();
    if (statusIsGranted(status)) {
      List list = await _channel.invokeMethod('getDescAlbumImg', maxCount);
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album;
    } else {
      return Future.error(status);
    }
  }

  /*获取相册视频资源(降序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getDescAlbumVideo(
      {int? maxCount}) async {
    PermissionStatus status = await checkPermissions();
    if (statusIsGranted(status)) {
      List list = await _channel.invokeMethod('getDescAlbumVideo', maxCount);
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album;
    } else {
      return Future.error(status);
    }
  }

  /*通过唯一标识localIdentifier 获取资源（原图、原视频）*/
  static Future<AlbumModelEntity?> getOriginalResource(String localIdentifier,
      {void onProgress(double progress)?, void onError(String error)?}) async {
    if (Platform.isIOS) {
      //监听加载进度
      _eventChannel.receiveBroadcastStream().listen((Object? object) {
        if (object is double) {
          if (onProgress != null) {
            onProgress(object);
          }
        } else {
          if (onError != null) {
            onError(object.toString());
          }
        }
      });
      List list =
          await _channel.invokeMethod('getOriginalResource', localIdentifier);
      if (list.length == 0) {
        if (onError != null) {
          onError("加载失败，请重试");
        }
        return null;
      }
      AlbumModelEntity model = AlbumModelEntity.fromJson(list.first);
      return model;
    } else {
      List list =
          await _channel.invokeMethod('getOriginalResource', localIdentifier);
      if (list.length == 0) {
        if (onError != null) {
          onError("加载失败，请重试");
        }
        return null;
      }
      List<AlbumModelEntity> album = <AlbumModelEntity>[];
      try {
        list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      } catch (error) {
        if (onError != null) {
          onError(error.toString());
        }
      }
      return album.first;
    }
  }
}
