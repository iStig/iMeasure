//
//  AudoView.m
//  DYX
//
//  Created by GongXuehan on 13-4-9.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "AudoView.h"
#import "Global.h"

@interface AudoView ()
{
    UITapGestureRecognizer  *_tapGestureREC;
    MPMoviePlayerController *_theMovie;
}
@end

@implementation AudoView

- (void)dealloc
{
    [_theMovie.view removeFromSuperview];
    [_theMovie release];
    [_tapGestureREC release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"video_bg.png"];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)playFile:(NSString *)fileName
{
    if (_theMovie) {
        [_theMovie stop];
        [_theMovie release];
        _theMovie = nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    [self playMovieAtURL:[NSURL fileURLWithPath:path]];
}

- (void)stopPlay
{
    [_theMovie stop];
}

//播放视频
- (void)playMovieAtURL:(NSURL*)theURL
{
    //_stopOrNot = NO;
    _theMovie = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
    
    if (_tapGestureREC == nil) {
        _tapGestureREC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreen)];
        _tapGestureREC.numberOfTouchesRequired = 1;
        _tapGestureREC.numberOfTapsRequired = 2;
    }
    
    [_theMovie.view addGestureRecognizer:_tapGestureREC];
    
    //_thePlayer = theMovie;
    //隐藏系统自带的控制视频播放的控件
    _theMovie.controlStyle = MPMovieControlStyleEmbedded;
    _theMovie.view.frame = CGRectMake(6, 6, self.frame.size.width - 35, self.frame.size.height - 12);
    [self addSubview:_theMovie.view];
    
    // Register for the playback finished notification.
    //当视频播放完毕时添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_theMovie];
    
    // Movie playback is asynchronous, so this method returns immediately.
    [_theMovie play];
}

// When the movie is done,release the controller.
//视频播放完时调用，用于对MPMoviePlayerController的释放
- (void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    //_stopOrNot = YES;
    MPMoviePlayerController* theMovie = [aNotification object];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    
    
    //_smallImgView.image = [UIImage imageNamed:@"ss.png"];
    //[theMovie.view removeFromSuperview];
    // Release the movie instance created in playMovieAtURL
    //[theMovie release];
}

- (void)fullScreen
{
    [_theMovie setFullscreen:YES animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
