import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:photo_album_manager/photo_album_manager.dart';
import 'package:toast/toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('photo_album_manager'),
          centerTitle: true,
        ),
        body: PhotoAlbumBodyWidget(),
      ),
    );
  }
}

class PhotoAlbumBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              PermissionStatus status =
              await PhotoAlbumManager.checkPermissions();
              if (status == PermissionStatus.granted) {
                Toast.show("权限同意", context);
              } else {
                Toast.show("权限拒绝", context);
              }
            },
            child: Text("权限申请"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new PhotoAlbumResourceWidget(
                  title: '图片',
                  resourceType: "image",
                );
              }));
            },
            child: Text("图片"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new PhotoAlbumResourceWidget(
                  title: '视频',
                  resourceType: "video",
                );
              }));
            },
            child: Text("视频"),
          ),
        ],
      ),
    );
  }
}

class PhotoAlbumResourceWidget extends StatefulWidget {
  final String title;
  final String resourceType;

  const PhotoAlbumResourceWidget({Key key, this.title, this.resourceType})
      : super(key: key);

  @override
  PhotoAlbumResourceWidgetState createState() =>
      new PhotoAlbumResourceWidgetState();
}

class PhotoAlbumResourceWidgetState extends State<PhotoAlbumResourceWidget> {
  List<AlbumModelEntity> photos = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
      ),
      body: GridView.builder(
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
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    offstage: model.resourceType == "video" ? false : true,
                  ),
                ],
              ),
            ),
            onTap: () {
              PhotoAlbumManager.getOriginalResource(model.localIdentifier,
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
    );
  }

  @override
  // ignore: missing_return
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (widget.resourceType == "image") {
      photos = await PhotoAlbumManager.getDescAlbumImg(maxCount: 50);
      setState(() {});
    } else if (widget.resourceType == "video") {
      photos = await PhotoAlbumManager.getDescAlbumVideo(maxCount: 50);
      setState(() {});
    }
  }
}
