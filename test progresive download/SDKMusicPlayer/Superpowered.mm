//
//  SuperpoweredBridge.m
//  LangitMusik
//
//  Created by Wowo Diergo on 11/22/19.
//  Copyright © 2019 PT. Code Development Indonesia. All rights reserved.
//
#import <Foundation/Foundation.h>
#include "Superpowered.h"
#include "SuperpoweredBandpassFilterbank.h"
#include "SuperpoweredSimple.h"
#include "SuperpoweredBridge.h"
#import "SuperpoweredIOSAudioIO.h"
#include "SuperpoweredAdvancedAudioPlayer.h"

const char* input_global_var = "";

SuperPoweredStatePlayer currentState = none;
bool playerMustStop = false;
bool isSeek = false;

@implementation SuperpoweredBridge{
    SuperpoweredIOSAudioIO *audioIO;
    Superpowered::AdvancedAudioPlayer *player;
    //CADisplayLink *displayLink;
    NSTimer *timer;
    unsigned int lastPositionSeconds, durationMs;
};

- (instancetype)init{
    self = [super init];
    if (!self) return nil;
    
    Superpowered::Initialize("ExampleLicenseKey-WillExpire-OnNextUpdate",false,false,false,false,true,false,false);
    Superpowered::AdvancedAudioPlayer::setTempFolder([NSTemporaryDirectory() fileSystemRepresentation]);
    player = new Superpowered::AdvancedAudioPlayer(44100, 0);
    
    lastPositionSeconds = 0;
    
//    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateRate)];
//    if(@available(iOS 11, *)){
//        displayLink.preferredFramesPerSecond = 1;
//    }
//    else{
//        displayLink.frameInterval = 1;
//    }
    //[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    timer = nil;
    audioIO = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
    [audioIO start];
    
    return self;
}

// Called periodically by the operating system's audio stack to provide audio output.
static bool audioProcessing(void *clientdata, float **inputBuffers, unsigned int inputChannels, float **outputBuffers, unsigned int outputChannels, unsigned int numberOfFrames, unsigned int samplerate, uint64_t hostTime) {
    __unsafe_unretained SuperpoweredBridge *self = (__bridge SuperpoweredBridge *)clientdata;
    self->player->outputSamplerate = samplerate;
    
    float interleavedBuffer[numberOfFrames * 2];
    bool notSilence = self->player->processStereo(interleavedBuffer, false, numberOfFrames);
    if (notSilence) Superpowered::DeInterleave(interleavedBuffer, outputBuffers[0], outputBuffers[1], numberOfFrames);
    return notSilence;
}

-(void)updateRate:(NSTimer *)timer{
    [self updateTime];
    [self updateState];
}

-(void)updateTime{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        //Run UI Updates
        __typeof__(self) strongSelf = weakSelf;
        if(strongSelf == nil){
            return;
        }
        //printf("update time : %f",self->player->getPositionMs());
        [strongSelf->_delegate getTimeRemaining:strongSelf->player->getPositionMs()];
    });
    
}

-(void)updateState{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( QOS_CLASS_BACKGROUND, 0), ^(void){
        //Background Thread
        __typeof__(self) strongSelf = weakSelf;
        if(strongSelf == nil){
            return;
        }
        eventPlayer event = (eventPlayer) strongSelf->player->getLatestEvent();
        switch (event) {
            case PlayerEvent_Opened:
                //player->play();
                printf("\n superpowered PlayerEvent_Opened \n");
                break;
            case PlayerEvent_OpenFailed:
                printf("\n superpowered PlayerEvent_OpenFailed \n");
                NSLog(@"\n Open error %i: %s \n", self->player->getOpenErrorCode(), Superpowered::AdvancedAudioPlayer::statusCodeToString(strongSelf->player->getOpenErrorCode()));
                strongSelf->player->open(input_global_var);
//                strongSelf->player->setTempFolder([NSTemporaryDirectory() fileSystemRepresentation]);
//                if (strongSelf->player->eofRecently()) strongSelf->player->setPosition(0, true, false);
                strongSelf->player->play();
                break;
            case PlayerEvent_None:
                printf("\n superpowered PlayerEvent_None \n");
                //player->open(urls[0]);
                //player->play();
                //player->open(urls[0]);
                if (strongSelf->player->eofRecently()){
                    //player->pause();
                    strongSelf->player->setPosition(0, true, false);
                    [strongSelf->timer invalidate];
                    strongSelf->timer = nil;
                    //playerMustStop = true;
                }
                if (strongSelf->player->isPlaying() == true) {
                    if (strongSelf->player->isWaitingForBuffering() == true) {
                        if(currentState != buffering){
                            currentState = buffering;
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                //Run UI Updates
                                [strongSelf->_delegate getPlayerState:buffering];
                            });
                            
                        }
                    }
                    else{
                        if(currentState != playing){
                            currentState = playing;
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                //Run UI Updates
                                [strongSelf->_delegate getPlayerState:playing];
                            });
                            
                        }
                    }
                    isSeek = false;
                }
                else{
                    if (isSeek == false){
                        if (currentState != paused && playerMustStop == false) {
                            currentState = paused;
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [strongSelf->_delegate getPlayerState:paused];
                            });
                            
                        }
                        else if(currentState != paused && playerMustStop == true){
                            currentState = paused;
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [strongSelf->_delegate getPlayerState:stopped];
                            });
                            
                        }
                    }
                }
                break;
            case PlayerEvent_Opening:
                printf("\n superpowered PlayerEvent_Opening \n");
                break;
            case PlayerEvent_ConnectionLost:
                printf("\n superpowered PlayerEvent_ConnectionLost \n");
                printf("--------connection lost------");
                //self->player->open(input_global_var);
                break;
            case PlayerEvent_ProgressiveDownloadFinished:
                printf("\n superpowered PlayerEvent_ProgressiveDownloadFinished \n");
                break;
            default:
                printf("\n superpowered go to default \n");
                break;
        };
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [strongSelf->_delegate getMusicPlayerEvent:event];
        });
    });
    
    
}

- (void)dealloc{
    //[displayLink invalidate];
    [timer invalidate];
    timer = nil;
    delete player;
    //Superpowered::AdvancedAudioPlayer::clearTempFolder();
}

- (eventPlayer)getLatestEvent{
    return (eventPlayer) player->getLatestEvent();
}

-(void)playSong{
    player->play();
    playerMustStop = false;
    if (timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRate:) userInfo:nil repeats:YES];
        
    }
}

-(void)pauseSong{
    player->pause();
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    currentState = paused;
    [_delegate getPlayerState:paused];
}

-(void)stopSong{
    if (player->getPositionMs() > 0) {
        player->setPosition(0, true, false);
    }
    
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    currentState = paused;
    playerMustStop = true;
    [_delegate getPlayerState:stopped];
}

/**
       set posisi folder untuk simpan temporary file untuk progressive download
*/
-(void)setTempFolder{
    player->setTempFolder([NSTemporaryDirectory() fileSystemRepresentation]);
}

/**
       terima url lagu lalu set url lagu yang akan diplay
*/
-(void)setSong: (NSString*) input{
    const char* input_c = [input cStringUsingEncoding:NSUTF8StringEncoding];
    input_global_var = [input cStringUsingEncoding:NSUTF8StringEncoding];
    player->open(input_c);
    printf("error code: %d for song %s",player->getOpenErrorCode(),[input cStringUsingEncoding:NSUTF8StringEncoding]);
}

-(unsigned int) getTimeElapsed{
    return player->getDisplayPositionSeconds();
}

-(float) getTimeElapsedMS{
    return player->getPositionMs();
}

-(unsigned int) getDurationMs{
    return player->getDurationMs();
}

-(unsigned int) getDurationS{
    return player->getDurationSeconds();
}

/**
       bemberi info apakah player play atau pause
*/
-(bool) isPlaying{
    return player->isPlaying();
}

/**
       bemberi info apakah player sedang menunggu data (nunggu network download)
*/
-(bool) isWaitingForBuffering{
    return player->isWaitingForBuffering();
}

/**
        buat dapetin posisi lagu berjalan saat ini dalam satuan second
 */
-(int) getPositionSecond{
    return player->getDisplayPositionSeconds();
}

/**
       buat dapetin posisi lagu berjalan saat ini dalam satuan Ms
*/
-(double) getPositionMs{
    return player->getDisplayPositionMs();
}

/**
       buat dapetin posisi lagu berjalan saat ini dalam satuan percent (dari 0 ke 1)
*/
-(float) getPositionPercent{
    return player->getDisplayPositionPercent();
}

-(NSString*) getDurationString{
    return [NSString stringWithFormat:@"%02d:%02d", player->getDurationSeconds() / 60, player->getDurationSeconds() % 60];
}

/**
      seek lagu, input yang diterima dengan format persen
 */
-(void) seekTo:(float) input{
    player->seek(input);
    currentState = playing;
    playerMustStop = false;
    [_delegate getPlayerState:playing];
    if (timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRate:) userInfo:nil repeats:YES];
    }
}

/**
     seek lagu, input yang diterima dengan format Ms
*/
-(void) seekTo_Ms:(double) input{
    currentState = playing;
    playerMustStop = false;
    [_delegate getPlayerState:playing];
    isSeek = true;
    player->playSynchronizedToPosition(input);
    if (timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRate:) userInfo:nil repeats:YES];
    }
}

-(void) clearAll{
    delete player;
    //Superpowered::AdvancedAudioPlayer::clearTempFolder();
}

-(float) getBufferedEnd_inPercent{
    return player->getBufferedEndPercent();
}

@end
