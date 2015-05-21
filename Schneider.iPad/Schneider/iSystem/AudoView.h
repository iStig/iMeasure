//
//  AudoView.h
//  DYX
//
//  Created by GongXuehan on 13-4-9.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudoView : UIImageView <MPMediaPickerControllerDelegate>

- (void)playFile:(NSString *)fileName;

- (void)stopPlay;

@end
