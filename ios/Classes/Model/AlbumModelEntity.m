//
//  AlbumModelEntity.m
//  photo_album_manager
//
//  Created by 曹云霄 on 2019/8/19.
//

#import "AlbumModelEntity.h"

@implementation AlbumModelEntity

- (AlbumModelEntity * _Nonnull (^)(NSDate * _Nonnull))setCreationDate {
    return ^(NSDate *tmp) {
        self.creationDate = [NSString stringWithFormat:@"%.0f",[tmp timeIntervalSince1970]];
        return self;
    };
}

- (AlbumModelEntity *(^)(NSString *))setLocalIdentifier {
    return ^(NSString *tmp) {
        self.localIdentifier = tmp;
        return self;
    };
}

- (AlbumModelEntity * _Nonnull (^)(NSString * _Nonnull))setResourceSize {
    return ^(NSString *tmp) {
        self.resourceSize = tmp;
        return self;
    };
}

- (AlbumModelEntity * _Nonnull (^)(NSString * _Nonnull))setThumbPath {
    return ^(NSString *tmp) {
        self.thumbPath = tmp;
        return self;
    };
}


- (AlbumModelEntity * _Nonnull (^)(NSString * _Nonnull))setOriginalPath {
    return ^(NSString *tmp) {
        self.originalPath = tmp;
        return self;
    };
}

- (AlbumModelEntity * _Nonnull (^)(NSString * _Nonnull))setVideoDuration {
    return ^(NSString *tmp) {
        self.videoDuration = tmp;
        return self;
    };
}

- (AlbumModelEntity * _Nonnull (^)(NSString * _Nonnull))setResourceType {
    return ^(NSString *tmp) {
        self.resourceType = tmp;
        return self;
    };
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.creationDate) {
        [dict setObject:self.creationDate forKey:@"creationDate"];
    }
    if (self.localIdentifier) {
        [dict setObject:self.localIdentifier forKey:@"localIdentifier"];
    }
    if (self.resourceSize) {
        [dict setObject:self.resourceSize forKey:@"resourceSize"];
    }
    if (self.thumbPath) {
        [dict setObject:self.thumbPath forKey:@"thumbPath"];
    }
    if (self.originalPath) {
        [dict setObject:self.originalPath forKey:@"originalPath"];
    }
    if (self.videoDuration) {
        [dict setObject:self.videoDuration forKey:@"videoDuration"];
    }
    if (self.resourceType) {
        [dict setObject:self.resourceType forKey:@"resourceType"];
    }
    return dict;
}

@end
