class AlbumModelEntity {
  /*视频时长(秒)*/
  String? videoDuration;

  /*资源大小*/
  String? resourceSize;

  /*缩略图路径或视频第一帧图片路径*/
  String? thumbPath;

  /*资源路径*/
  String? originalPath;

  /*创建时间*/
  String? creationDate;

  /*资源类型 image 或 video 或 gif*/
  String? resourceType;

  /*资源唯一标识(下载原图或原视频使用)*/
  String? localIdentifier;

  AlbumModelEntity(
      {this.videoDuration,
      this.resourceSize,
      this.thumbPath,
      this.originalPath,
      this.creationDate,
      this.resourceType,
        this.localIdentifier});

  AlbumModelEntity.fromJson(Map<dynamic, dynamic> json) {
    videoDuration = json['videoDuration'];
    resourceSize = json['resourceSize'];
    thumbPath = json['thumbPath'];
    originalPath = json['originalPath'];
    creationDate = json['creationDate'];
    resourceType = json['resourceType'];
    localIdentifier = json['localIdentifier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoDuration'] = this.videoDuration;
    data['resourceSize'] = this.resourceSize;
    data['thumbPath'] = this.thumbPath;
    data['originalPath'] = this.originalPath;
    data['creationDate'] = this.creationDate;
    data['resourceType'] = this.resourceType;
    data['localIdentifier'] = this.localIdentifier;
    return data;
  }
}
