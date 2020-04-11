package com.example.photo_album_manager;

import java.util.HashMap;
import java.util.Map;

class AlbumModelEntity {

    /*创建时间*/
    private String creationDate;

    /*资源大小*/
    private String resourceSize;

    /*缩略图路径或视频第一帧图片路径*/
    private String thumbPath;

    /*资源路径*/
    private String originalPath;

    /*视频时长*/
    private String videoDuration;

    /*资源类型 image 或 video*/
    private String resourceType;

    /*资源唯一标识(下载原图或原视频使用)*/
    private String localIdentifier;

    /*资源id*/
    private int id;

    /*构造方法*/
    AlbumModelEntity(String creationDate, String resourceSize, String thumbPath, String originalPath, String videoDuration, String resourceType, String localIdentifier, int id) {
        this.creationDate = creationDate;
        this.resourceSize = resourceSize;
        this.thumbPath = thumbPath;
        this.originalPath = originalPath;
        this.videoDuration = videoDuration;
        this.resourceType = resourceType;
        this.localIdentifier = localIdentifier;
        this.id = id;
    }

    int getId() {
        return id;
    }

    void setThumbPath(String thumbPath) {
        this.thumbPath = thumbPath;
    }

    /*对象转Map*/
    Map<String, String> toMap() {
        Map<String, String> data = new HashMap<>();
        data.put("videoDuration", this.videoDuration);
        data.put("resourceSize", this.resourceSize);
        data.put("thumbPath", this.thumbPath);
        data.put("originalPath", this.originalPath);
        data.put("creationDate", this.creationDate);
        data.put("resourceType", this.resourceType);
        data.put("localIdentifier", this.localIdentifier);
        return data;
    }
}
