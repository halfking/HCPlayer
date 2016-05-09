# HCPlayer
播放视频与音频，可以加入导唱，即多加一个音轨同时播放。同时，可以使用播放时的缓冲文件功能。

用法：
      playView = [[HCPlayerWrapper alloc] initWithFrame:CGRectMake(0, 0, screenWidth_, playerHeightMax_)];
        playView.delegate = self;
        [self.view addSubview:playView];
        playView.userInteractionEnabled = YES;
        
        //是否使用缓存
        [[UserManager sharedUserManager]currentSettings].EnbaleCacheWhenPlaying = YES;
        [playView setLyricBottomSpace:30];
        [playView setPlayRange:10 end:-1];
        playView.backgroundColor = [UIColor blackColor];
有3种方式设置需要播放的源：        
1、直接设置PlayerItem:        
        AVURLAsset *movieAsset = nil;
        NSString * urlString = 。。。。。。;
        movieAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:urlString] options:nil];
        AVPlayerItem * playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        [playView setPlayeritem:playerItem lyric:nil];
2、直接设置URL： 
        [playView setPlayerUrl:[NSURL URLWithString:urlString] lyric:nil];
3、使用MTV：
        [playView setPlayerData:currentMtv_ sample:nil];
播放：        
        [playView setPlayRate:1];
        playView.isLoop = YES;
        [playView play];
        
