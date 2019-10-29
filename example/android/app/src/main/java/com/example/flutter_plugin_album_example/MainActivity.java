package com.example.photo_album_manager_example;

import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import pub.devrel.easypermissions.EasyPermissions;

public class MainActivity extends FlutterActivity implements EasyPermissions.PermissionCallbacks {
  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  /*获取权限后回调*/
  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
  }

  @Override
  public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
    if (requestCode == 0) {

    }
  }

  @Override
  public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
      if (requestCode == 0) {

      }
  }
}
