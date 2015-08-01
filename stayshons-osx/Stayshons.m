//
//  Stayshons.m
//  Stayshons
//
//  Created by Danny Richelieu on 7/31/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import "Stayshons.h"

NSString * const NOTIFICATION_PLAYING_STATION = @"StayshonsPlayingStation";

@implementation Stayshons
{
    NSArray* stations;
    NSDictionary* station;
    NSInteger currentIndex;
    BOOL canGetMeta;
    STKAudioPlayer *audioPlayer;
}

- (id) init
{
    stations = [[NSArray alloc] init];
    station = [[NSDictionary alloc] init];
    currentIndex = -1;
    canGetMeta = NO;
    
    audioPlayer = [[STKAudioPlayer alloc] init];
    audioPlayer.delegate = self;

    return self;
}

-(NSArray*) stations
{
    return [[NSArray alloc] init];
}

-(NSDictionary*) station
{
    return station;
}

-(NSInteger) currentIndex
{
    return currentIndex;
}

- (BOOL) canGetSongMeta
{
    return canGetMeta;
}

- (void) playStationAtIndex:(NSInteger)index
{
    if ([stations count] > index) {
        currentIndex = index;
        station = stations[index];
        
        NSString *uri = [station valueForKey:@"uri"];
        NSString *meta = [station valueForKey:@"playing"];
        
        canGetMeta = meta ? YES : NO;
        
        [self playURLString:uri];
    }
}

- (NSArray*) loadFromServer
{

    NSData *urlData = [DataFromUrl getDataFromUrl:@"http://dannyrich.com/api/stayshons.php?key=123456789"];
    
    NSError *error;
    
    NSArray* stationHold = [NSJSONSerialization JSONObjectWithData:urlData                       options:0 error:&error];
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    
    stations = [stationHold sortedArrayUsingDescriptors:sortDescriptors];
    
    return stations;
}

- (NSDictionary*) getSongMeta
{
    
    NSString *uri = [station valueForKey:@"playing"];
    NSData *urlData = [DataFromUrl getDataFromUrl:uri];
    NSError *error;
    
    NSDictionary* dataHold = [NSJSONSerialization JSONObjectWithData:urlData                       options:0 error:&error];
    
    NSString *actualTitle = [self getFromDict:dataHold
                                     byString:[station valueForKey:@"playing-title"]];
    
    NSString *actualBand = [self getFromDict:dataHold
                                    byString:[station valueForKey:@"playing-band"]];
    
    NSDictionary *retVal = [[NSDictionary alloc] initWithObjectsAndKeys:actualTitle, @"title", actualBand, @"band", nil];
    
    return retVal;
    
}

- (NSString*) getFromDict:(id)dataHold byString:(NSString*)title
{
    @try
    {
        NSArray *keys = [title componentsSeparatedByString:@"."];
        id holdId = dataHold;
        NSString *holdStr = @"";
        
        for (int i = 0; i < [keys count]; i++) {
            holdId = dataHold[keys[i]];
            
            if ([holdId isKindOfClass:[NSString class]]) {
                holdStr = (NSString*)holdId;
                break;
            }
        }
        
        return holdStr;
    }
    @catch (NSException *except)
    {
        NSLog(@"Error! %@", except);
        return nil;
    }
}

-(void) playURLString:(NSString*) urlString
{
    [self stop];
    [audioPlayer play:urlString];
}


- (void) stop {
    if (audioPlayer) {
        [audioPlayer stop];
    }
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYING_STATION
                                                        object:self];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
}
@end
