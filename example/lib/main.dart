import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:photo_album_manager/photo_album_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<AlbumModelEntity> photos = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    photos = await PhotoAlbumManager.getDescAlbum(maxCount: 30);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('相册'),
          centerTitle: true,
        ),
        body: new GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, int index) {
            AlbumModelEntity model = photos[index];
            return GestureDetector(
              child: Card(
                child: Stack(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints.expand(),
                      child: Image.file(
                        File(model.thumbPath ?? model.originalPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Offstage(
                      child: Center(
                        child: Icon(Icons.play_circle_outline,size: 40,color: Colors.white,),
                      ),
                      offstage: model.resourceType == "video" ? false : true,
                    ),
                  ],
                ),
              ),
              onTap: () {
                PhotoAlbumManager.getOriginalImg(model.localIdentifier,
                    onProgress: (progress) {
                      print("下载进度" + progress.toString());
                    }, onError: (error) {
                      print("下载错误" + error);
                    }).then((value) {
                  print("下载完成" + value.originalPath);
                });
              },
            );
          },
        ),
      ),
    );
  }
}
