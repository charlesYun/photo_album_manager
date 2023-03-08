package com.example.photo_album_manager;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * PhotoAlbumManagerPlugin
 */
public class PhotoAlbumManagerPlugin implements FlutterPlugin, MethodCallHandler {


    /*SD 路径*/
    private static final String IN_PATH = "/thumbnail/pic/";

    private static final String PHOTO_ALBUM_MANAGER = "photo_album_manager";

    //资源类型
    private static final String RESOURCE_VIDEO = "video";
    private static final String RESOURCE_IMAGE = "image";

    /*回调*/
    private Result result;

    /*最大资源数*/
    private int maxCount;

    /*排序*/
    private boolean asc;

    /*图片*/
    private boolean image;

    /*视频*/
    private boolean video;

    /*Context*/
    private Context context;

    /*新的插件注册方式*/
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), PHOTO_ALBUM_MANAGER);
        this.context = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        //刷新MediaStore
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Intent mediaScanIntent = new Intent(
                    Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            Uri contentUri = Uri.fromFile(Environment.getExternalStorageDirectory());
            mediaScanIntent.setData(contentUri);
            context.sendBroadcast(mediaScanIntent);
        } else {
            context.sendBroadcast(new Intent(
                    Intent.ACTION_MEDIA_MOUNTED,
                    Uri.parse("file://"
                            + Environment.getExternalStorageDirectory())));
        }
        switch (call.method) {
            case "getDescAlbum": {
                //逆序获取相册资源
                this.result = result;
                int count = 0;
                if (call.arguments != null) {
                    count = (int) call.arguments;
                }
                getAblumData(false, true, true, count);
                break;
            }
            case "getAscAlbum": {
                //顺序获取相册资源
                this.result = result;
                int count = 0;
                if (call.arguments != null) {
                    count = (int) call.arguments;
                }
                getAblumData(true, true, true, count);
                break;
            }
            case "getAscAlbumImg": {
                //顺序获取相册图片
                this.result = result;
                int count = 0;
                if (call.arguments != null) {
                    count = (int) call.arguments;
                }
                getAblumData(true, true, false, count);
                break;
            }
            case "getAscAlbumVideo": {
                //顺序获取相册视频
                this.result = result;
                int count = 0;
                if (call.arguments != null) {
                    count = (int) call.arguments;
                }
                getAblumData(true, false, true, count);
                break;
            }
            case "getDescAlbumImg": {
                //逆序获取相册图片
                this.result = result;
                int count = 0;
                if (call.arguments != null) {
                    count = (int) call.arguments;
                }
                getAblumData(false, true, false, count);
                break;
            }
            case "getDescAlbumVideo": {
                //逆序获取相册视频
                this.result = result;
                int count = 0;
                if (call.arguments != null) {
                    count = (int) call.arguments;
                }
                getAblumData(false, false, true, count);
                break;
            }
            case "getOriginalResource":
                //获取原始资源
                this.result = result;
                String localId = null;
                if (call.arguments != null) {
                    localId = call.arguments.toString();
                }
                getAblumData(true, true, true, 1, localId);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /*获取相册资源*/
    private void getAblumData(boolean asc, boolean image, boolean video, int maxCount) {
        this.asc = asc;
        this.maxCount = maxCount;
        this.image = image;
        this.video = video;

        long startTime = System.currentTimeMillis();
        getAblumData(asc, image, video, maxCount, null);
        long endTime = System.currentTimeMillis();
        Log.i("getAblumData", "方法执行时间：" + (endTime - startTime) + "ms");
    }

    /*获取相册资源*/
    private void getAblumData(final boolean asc, final boolean image, final boolean video, final int maxCount, final String localIdentifier) {
        List<AlbumModelEntity> albumList = new ArrayList<>();
        if (image) {
            List<AlbumModelEntity> images = getSystemPhotoList(asc, maxCount, localIdentifier);
            if (images != null && images.size() > 0) {
                albumList.addAll(images);
            }
        }
        if (video) {
            List<AlbumModelEntity> videos = getSystemVideoList(asc, maxCount, localIdentifier);
            if (videos != null && videos.size() > 0) {
                albumList.addAll(videos);
            }
        }
        Collections.sort(albumList, new Comparator<AlbumModelEntity>() {
            @Override
            public int compare(AlbumModelEntity o1, AlbumModelEntity o2) {
                int id1 = Integer.parseInt(String.valueOf(o1.getId()));
                int id2 = Integer.parseInt(String.valueOf(o2.getId()));
                if (id1 > id2) {
                    return -1;
                } else if (id1 < id2) {
                    return 1;
                }
                return 0;
            }
        });
        /*判断是否超出maxCount*/
        if (maxCount > 0 && albumList.size() > maxCount) {
            albumList = albumList.subList(0, maxCount);
        }
        List<Map<String, String>> mapList = new ArrayList<>();
        for (AlbumModelEntity entity : albumList) {
            mapList.add(entity.toMap());
        }
        result.success(mapList);
    }

    /*获取相册图片资源*/
    private List<AlbumModelEntity> getSystemPhotoList(boolean asc, int maxCount, String localId) {
        List<AlbumModelEntity> result = new ArrayList<>();

        // 使用 ContentResolver 获取相册中的所有照片
        String[] projection = { MediaStore.Images.Media.DATA };
        String[] thumbProjection = {MediaStore.Images.Thumbnails.DATA};
        ContentResolver contentResolver = this.context.getContentResolver();
        Cursor cursor = contentResolver.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, projection, null, null,
                MediaStore.Images.Media._ID + (asc ? " ASC" : " DESC"));
        Cursor thumbCursor = contentResolver.query(MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI, thumbProjection, null, null, null);
        if (cursor == null || cursor.getCount() <= 0 || thumbCursor == null || thumbCursor.getCount() <= 0 ) return null;
        // 遍历 cursor，将所有照片路径添加到 photoPaths 数组中
        if (cursor != null && thumbCursor != null) {
            while (cursor.moveToNext() && thumbCursor.moveToNext()) {
                String photoPath = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
                String thumbnailPath = thumbCursor.getString(thumbCursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
                AlbumModelEntity imgEntity = new AlbumModelEntity(null, null, thumbnailPath, photoPath, null, RESOURCE_IMAGE, null, 0);
                result.add(imgEntity);
                //获取maxCount固定数值 maxCount <= 0 表示全部
                if (maxCount > 0 && result.size() == maxCount) {
                    cursor.close();
                    thumbCursor.close();
                    return result;
                }
            }
            cursor.close();
            thumbCursor.close();
            return result;
        }
        cursor.close();
        thumbCursor.close();
        return result;
    }

    /*获取相册视频资源*/
    private List<AlbumModelEntity> getSystemVideoList(boolean asc, int maxCount, String localId) {
        List<AlbumModelEntity> result = new ArrayList<>();
        //按视频ID降序获取
        ContentResolver contentResolver = this.context.getContentResolver();
        Cursor cursor;
        if (localId != null) {
            cursor = contentResolver.query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, null, MediaStore.Video.Media._ID + " =?", new String[]{localId}, null,
                    null);
        } else {
            cursor = contentResolver.query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, null, null, null,
                    MediaStore.Video.Media._ID + (asc ? " ASC" : " DESC"));
        }
        if (cursor == null || cursor.getCount() <= 0) return null;
        while (cursor.moveToNext()) {
            String path = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA));
            String duration = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION));
            String size = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE));
            int id = cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID));
            String localIdentifier = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
            String creationDate = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED));
            String thumbnail = getVideoSystemThumbnail(id);
            if (thumbnail == null) {
                File picFile = thumbnailPicFile(this.context, localIdentifier);
                if (!picFile.exists()) {
                    Bitmap bitmap = MediaStore.Video.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Video.Thumbnails.MICRO_KIND, null);
                    if (bitmap != null) {
                        thumbnail = saveBitmap(this.context, bitmap, localIdentifier);
                    }
                } else {
                    thumbnail = picFile.getAbsolutePath();
                }
            }
            AlbumModelEntity videoEntity = new AlbumModelEntity(creationDate, size, thumbnail, path, duration, RESOURCE_VIDEO, localIdentifier, id);
            result.add(videoEntity);
            //获取maxCount固定数值 maxCount <= 0 表示全部
            if (maxCount > 0 && result.size() == maxCount) {
                cursor.close();
                return result;
            }
        }
        cursor.close();
        return result;
    }

    /*获取系统图片缩略图*/
    private String getImageSystemThumbnail(int imageId) {
        String thumbnail = null;
        ContentResolver cr = this.context.getContentResolver();
        Cursor cursor = cr.query(
                MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI,
                new String[]{
                        MediaStore.Images.Thumbnails.DATA
                },
                MediaStore.Images.Thumbnails.IMAGE_ID + "=" + imageId,
                null,
                null);
        if (cursor != null && cursor.moveToFirst()) {
            thumbnail = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
            cursor.close();
        }
        return thumbnail;
    }

    /*获取系统视频缩略图*/
    private String getVideoSystemThumbnail(int videoId) {
        String thumbnail = null;
        ContentResolver cr = this.context.getContentResolver();
        Cursor cursor = cr.query(
                MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI,
                new String[]{
                        MediaStore.Video.Thumbnails.DATA
                },
                MediaStore.Video.Thumbnails.VIDEO_ID + "=" + videoId,
                null,
                null);
        if (cursor != null && cursor.moveToFirst()) {
            thumbnail = cursor.getString(cursor.getColumnIndex(MediaStore.Video.Media.DATA));
            cursor.close();
        }
        return thumbnail;
    }

    /*保存Bitmap到本地返回图片路径*/
    private static String saveBitmap(Context context, Bitmap mBitmap, String localIdentifier) {
        String savePath;
        File filePic = thumbnailPicFile(context, localIdentifier);
        try {
            if (!filePic.exists()) {
                filePic.getParentFile().mkdirs();
                filePic.createNewFile();
                FileOutputStream fos = new FileOutputStream(filePic);
                mBitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
                fos.flush();
                fos.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
        return filePic.getAbsolutePath();
    }

    /*本地路径拼接*/
    private static File thumbnailPicFile(Context context, String localIdentifier) {
        String savePath;
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {
            savePath = Environment.getExternalStorageDirectory().getAbsolutePath() + IN_PATH;
        } else {
            savePath = context.getApplicationContext().getFilesDir()
                    .getAbsolutePath()
                    + IN_PATH;
        }
        File filePic = new File(savePath + localIdentifier + ".jpg");
        return filePic;
    }

}
