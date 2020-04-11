package com.example.photo_album_manager;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import pub.devrel.easypermissions.EasyPermissions;

/**
 * PhotoAlbumManagerPlugin
 */
public class PhotoAlbumManagerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    /*权限code*/
    private static final int REQUEST_PERMISSION = 200;

    /*SD 路径*/
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

    /*图片*/
    private boolean image;

    /*视频*/
    private boolean video;

    /*Activity*/
    private Activity activity;

    /*Context*/
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "photo_album_manager");
        this.context = flutterPluginBinding.getApplicationContext();
        EventBus.getDefault().register(this);
        channel.setMethodCallHandler(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEventMainThread(MessageEvent messageEvent) {
        getAblumData(asc, image, video, maxCount, null);
        EventBus.getDefault().unregister(this);
    }


    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
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
        /*权限判断*/
        String[] perms = {Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE};
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !EasyPermissions.hasPermissions(this.activity, perms)) {
            EasyPermissions.requestPermissions(this.activity, "需要获取相册权限", REQUEST_PERMISSION, perms);
        } else {
            getAblumData(asc, image, video, maxCount, null);
        }
    }

    /*获取相册资源*/
    private void getAblumData(boolean asc, boolean image, boolean video, int maxCount, String localIdentifier) {
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

    /*获取相册图片资源*/
    private List<AlbumModelEntity> getSystemPhotoList(boolean asc, int maxCount, String localId) {
        List<AlbumModelEntity> result = new ArrayList<>();
        //按图片ID降序获取
        ContentResolver contentResolver = this.context.getContentResolver();
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
                Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Images.Thumbnails.MICRO_KIND, null);
                if (bitmap != null) {
                    String thumbPath = saveBitmap(this.context, bitmap, localIdentifier);
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
            File file = new File(path);
            if (file.exists()) {
                AlbumModelEntity videoEntity = new AlbumModelEntity(creationDate, size, null, path, duration, RESOURCE_VIDEO, localIdentifier, id);
                Bitmap bitmap = MediaStore.Video.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Video.Thumbnails.MICRO_KIND, null);
                if (bitmap != null) {
                    String thumbPath = saveBitmap(this.context, bitmap, localIdentifier);
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
    private static String saveBitmap(Context context, Bitmap mBitmap, String localIdentifier) {
        String savePath;
        File filePic;
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {
            savePath = Environment.getExternalStorageDirectory().getAbsolutePath() + IN_PATH;
        } else {
            savePath = context.getApplicationContext().getFilesDir()
                    .getAbsolutePath()
                    + IN_PATH;
        }
        try {
            filePic = new File(savePath + localIdentifier + ".jpg");
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

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
