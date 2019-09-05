package com.example.photo_album_manager;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * FlutterPluginAlbumPlugin
 */
public class FlutterPluginAlbumPlugin implements MethodCallHandler, ActivityCompat.OnRequestPermissionsResultCallback {

    /*权限code*/
    private static final int REQUEST_PERMISSION = 10002;

    /*SD 路径*/
    @SuppressLint("SdCardPath")
    private static final String SD_PATH = "/sdcard/thumbnail/pic/";
    private static final String IN_PATH = "/thumbnail/pic/";

    //资源类型
    private static final String RESOURCE_VIDEO = "video";
    private static final String RESOURCE_IMAGE = "image";

    /*回调*/
    private Result result;

    /*最大资源数*/
    private int maxCount;

    /*排序*/
    private boolean asc;

    /*构造方法*/
    private final Registrar registrar;

    private FlutterPluginAlbumPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    /*获取相册图片资源*/
    private List<AlbumModelEntity> getSystemPhotoList(boolean asc, int maxCount, String localId) {
        List<AlbumModelEntity> result = new ArrayList<>();
        //按图片ID降序获取
        ContentResolver contentResolver = registrar.context().getContentResolver();
        Cursor cursor;
        if (localId != null) {
            cursor = contentResolver.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, null, MediaStore.Images.Media._ID + " =?", new String[]{localId}, null,
                    null);
        } else {
            cursor = contentResolver.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, null, null, null,
                    MediaStore.Images.Media._ID + (asc ? " ASC" : " DESC"));
        }
        if (cursor == null || cursor.getCount() <= 0) return null;
        while (cursor.moveToNext()) {
            String path = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA));
            String size = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE));
            int id = cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
            String localIdentifier = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
            String creationDate = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED));
            File file = new File(path);
            if (file.exists()) {
                AlbumModelEntity imgEntity = new AlbumModelEntity(creationDate, size, null, path, null, RESOURCE_IMAGE, localIdentifier, id);
                Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Images.Thumbnails.MINI_KIND, null);
                if (bitmap != null) {
                    String thumbPath = saveBitmap(this.registrar.context(), bitmap);
                    if (thumbPath != null) {
                        imgEntity.setThumbPath(thumbPath);
                    }
                }
                result.add(imgEntity);
            }
            //获取maxCount固定数值 maxCount <= 0 表示全部
            if (maxCount > 0 && result.size() == maxCount) {
                cursor.close();
                return result;
            }
        }
        cursor.close();
        return result;
    }

    /*获取相册视频资源*/
    private List<AlbumModelEntity> getSystemVideoList(boolean asc, int maxCount, String localId) {
        List<AlbumModelEntity> result = new ArrayList<>();
        //按视频ID降序获取
        ContentResolver contentResolver = registrar.context().getContentResolver();
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
            File file = new File(path);
            if (file.exists()) {
                AlbumModelEntity videoEntity = new AlbumModelEntity(creationDate, size, null, path, duration, RESOURCE_VIDEO, localIdentifier, id);
                Bitmap bitmap = MediaStore.Video.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Video.Thumbnails.MINI_KIND, null);
                if (bitmap != null) {
                    String thumbPath = saveBitmap(this.registrar.context(), bitmap);
                    if (thumbPath != null) {
                        videoEntity.setThumbPath(thumbPath);
                    }
                }
                result.add(videoEntity);
            }
            //获取maxCount固定数值 maxCount <= 0 表示全部
            if (maxCount > 0 && result.size() == maxCount) {
                cursor.close();
                return result;
            }
        }
        cursor.close();
        return result;
    }


    /*保存Bitmap到本地返回图片路径*/
    private static String saveBitmap(Context context, Bitmap mBitmap) {
        String savePath;
        File filePic;
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {
            savePath = SD_PATH;
        } else {
            savePath = context.getApplicationContext().getFilesDir()
                    .getAbsolutePath()
                    + IN_PATH;
        }
        try {
            filePic = new File(savePath + UUID.randomUUID().toString() + ".jpg");
            if (!filePic.exists()) {
                filePic.getParentFile().mkdirs();
                filePic.createNewFile();
            }
            FileOutputStream fos = new FileOutputStream(filePic);
            mBitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
        return filePic.getAbsolutePath();
    }

    /*获取相册资源*/
    private void getAblumData(boolean asc, boolean image, boolean video, int maxCount) {
        getAblumData(asc, image, video, maxCount, null);
    }

    /*获取相册资源*/
    private void getAblumData(boolean asc, boolean image, boolean video, int maxCount, String localIdentifier) {
        /*权限判断*/
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && (ContextCompat.checkSelfPermission(registrar.context(), Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED)) {
            this.asc = asc;
            this.maxCount = maxCount;
            ActivityCompat.requestPermissions(registrar.activity(), new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_PERMISSION);
        } else {
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
            this.result.success(mapList);
        }
    }


    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "photo_album_manager");
        channel.setMethodCallHandler(new FlutterPluginAlbumPlugin(registrar));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getDescAlbum")) {
            //逆序获取相册资源
            this.result = result;
            int count = 0;
            if (call.arguments != null) {
                count = (int) call.arguments;
            }
            getAblumData(false, true, true, count);
        } else if (call.method.equals("getAscAlbum")) {
            //顺序获取相册资源
            this.result = result;
            int count = 0;
            if (call.arguments != null) {
                count = (int) call.arguments;
            }
            getAblumData(true, true, true, count);
        } else if (call.method.equals("getAscAlbumImg")) {
            //顺序获取相册图片
            this.result = result;
            int count = 0;
            if (call.arguments != null) {
                count = (int) call.arguments;
            }
            getAblumData(false, true, false, count);
        } else if (call.method.equals("getAscAlbumVideo")) {
            //顺序获取相册视频
            this.result = result;
            int count = 0;
            if (call.arguments != null) {
                count = (int) call.arguments;
            }
            getAblumData(false, false, true, count);
        } else if (call.method.equals("getDescAlbumImg")) {
            //逆序获取相册图片
            this.result = result;
            int count = 0;
            if (call.arguments != null) {
                count = (int) call.arguments;
            }
            getAblumData(true, true, false, count);
        } else if (call.method.equals("getDescAlbumVideo")) {
            //逆序获取相册视频
            this.result = result;
            int count = 0;
            if (call.arguments != null) {
                count = (int) call.arguments;
            }
            getAblumData(true, false, true, count);
        } else if (call.method.equals("getOriginalResource")) {
            //获取原始资源
            this.result = result;
            String localId = null;
            if (call.arguments != null) {
                localId = call.arguments.toString();
            }
            getAblumData(true, true, true, 1, localId);
        } else {
            result.notImplemented();
        }
    }

    /*获取权限后回调*/
    @Override
    public void onRequestPermissionsResult(int i, @NonNull String[] strings, @NonNull int[] ints) {
        if (i == REQUEST_PERMISSION) {
            if (ints.length > 0 && ints[0] == PackageManager.PERMISSION_GRANTED) {
                getAblumData(this.asc, true, true, this.maxCount);
            }
        }
    }
}

