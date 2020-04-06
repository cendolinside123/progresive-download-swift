//
//  SuperpoweredBridge.h
//  LangitMusik
//
//  Created by Wowo Diergo on 11/22/19.
//  Copyright © 2019 PT. Code Development Indonesia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, eventPlayer){
    PlayerEvent_None = 0,
    PlayerEvent_Opening = 1,
    PlayerEvent_OpenFailed = 2,
    PlayerEvent_Opened = 10,
    PlayerEvent_ConnectionLost = 3,
    PlayerEvent_ProgressiveDownloadFinished = 11
};

typedef NS_ENUM(int, SuperPoweredStatePlayer){
    playing = 1,
    paused = 2,
    buffering = 3,
    stopped = 4,
    none = 0
};

@protocol SuperpowerDelegate

-(void) getTimeRemaining:(unsigned int) time;
-(void) getMusicPlayerEvent:(eventPlayer) state;
-(void) getPlayerState:(SuperPoweredStatePlayer) state;
@end


@interface SuperpoweredBridge: NSObject{
    //id delegate;
}
@property (nonatomic, weak) id<SuperpowerDelegate> delegate;
-(eventPlayer)getLatestEvent;
-(void)playSong;
-(void)pauseSong;
-(void)setTempFolder;
-(void)setSong: (NSString*) input;
-(unsigned int) getDurationMs;
-(unsigned int) getDurationS;
-(NSString*) getDurationString;
-(void) seekTo:(float) input;
-(void)stopSong;
-(int) getPositionSecond;
-(double) getPositionMs;
-(float) getPositionPercent;
-(void) seekTo_Ms:(double) input;
-(float) getBufferedEnd_inPercent;
-(bool) isPlaying;
-(bool) isWaitingForBuffering;
@end
