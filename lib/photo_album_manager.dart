import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'album_model_entity.dart';

class PhotoAlbumManager {
  /*flutter主动调用交互*/
  static const MethodChannel _channel =
      const MethodChannel('photo_album_manager');

  /*原生主动调用交互*/
  static const EventChannel _eventChannel =
      const EventChannel('photo_album_manager_back');

  /*获取相册资源(降序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getDescAlbum({int maxCount}) async {
    List list = await _channel.invokeMethod('getDescAlbum', maxCount);
    List<AlbumModelEntity> album = List();
    list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
    return album;
  }

  /*获取相册资源(升序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getAscAlbum({int maxCount}) async {
    List list = await _channel.invokeMethod('getAscAlbum', maxCount);
    List<AlbumModelEntity> album = List();
    list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
    return album;
  }

  /*获取相册图片资源(升序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getAscAlbumImg({int maxCount}) async {
    List list = await _channel.invokeMethod('getAscAlbumImg', maxCount);
    List<AlbumModelEntity> album = List();
    list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
    return album;
  }

  /*获取相册视频资源(升序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getAscAlbumVideo({int maxCount}) async {
    List list = await _channel.invokeMethod('getAscAlbumVideo', maxCount);
    List<AlbumModelEntity> album = List();
    list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
    return album;
  }

  /*获取相册图片资源(降序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getDescAlbumImg({int maxCount}) async {
    List list = await _channel.invokeMethod('getDescAlbumImg', maxCount);
    List<AlbumModelEntity> album = List();
    list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
    return album;
  }

  /*获取相册视频资源(降序) maxCount 为null 获取全部资源*/
  static Future<List<AlbumModelEntity>> getDescAlbumVideo(
      {int maxCount}) async {
    List list = await _channel.invokeMethod('getDescAlbumVideo', maxCount);
    List<AlbumModelEntity> album = List();
    list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
    return album;
  }

  /*通过唯一标识localIdentifier 获取资源（原图、原视频）*/
  static Future<AlbumModelEntity> getOriginalImg(String localIdentifier,
      {void onProgress(double progress), void onError(String error)}) async {
    if (Platform.isIOS) {
      //监听加载进度
      _eventChannel.receiveBroadcastStream().listen((Object object) {
        if (object is double) {
          onProgress(object);
        } else {
          onError(object);
        }
      });
      List list =
          await _channel.invokeMethod('getOriginalResource', localIdentifier);
      if (list == null && list.length == 0) {
        onError("加载失败，请重试");
        return null;
      }
      AlbumModelEntity model = AlbumModelEntity.fromJson(list.first);
      return model;
    } else {
      List list =
          await _channel.invokeMethod('getOriginalResource', localIdentifier);
      List<AlbumModelEntity> album = List();
      list.forEach((item) => album.add(AlbumModelEntity.fromJson(item)));
      return album.first;
    }
  }
}
