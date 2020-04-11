package com.example.photo_album_manager_example;

import androidx.annotation.NonNull;

import com.example.photo_album_manager.MessageEvent;

import org.greenrobot.eventbus.EventBus;

import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import pub.devrel.easypermissions.EasyPermissions;

public class MainActivity extends FlutterActivity implements EasyPermissions.PermissionCallbacks {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

  /*获取权限后回调*/
  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
  }

  @Override
  public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
    EventBus.getDefault().post(new MessageEvent());
  }

  @Override
  public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {

  }
}
