//
//  AppDelegate.m
//  stayshons-osx
//
//  Created by Daniel Richelieu on 7/22/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(void) play:(NSMenuItem*) menuItem
{
    for(NSMenuItem *i in menuItems) {
        [i setState:NSOffState];
    }
    [menuItem setState:NSOnState];
    
    if (menuItem.tag >= 0 && menuItem.tag < [stations count]) {
        station = [stations objectAtIndex:menuItem.tag];
 
        NSString *name = [station valueForKey:@"title"];
        [systemStatusItem setTitle:name];
        
        [self playURLString:[station valueForKey:@"uri"]];
    } else {
        [systemStatusItem setTitle:@"Stayshons"];
        [self stop];
    }
}

- (NSDictionary*) getSongMeta
{
    NSString *uri = [station valueForKey:@"playing"];
    NSURL *metaPath = [[NSURL alloc] initWithString:uri];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:metaPath                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest                                     returningResponse:&response error:&error];
    
    NSDictionary* dataHold = [NSJSONSerialization JSONObjectWithData:urlData                       options:0 error:&error];
    
    NSString *actualTitle = [self getFromDict:dataHold
                                     byString:[station valueForKey:@"playing-title"]];
    NSString *actualBand = [self getFromDict:dataHold
                                    byString:[station valueForKey:@"playing-band"]];
    
    NSDictionary *retVal = [[NSDictionary alloc] initWithObjectsAndKeys:actualTitle, @"title", actualBand, @"band", nil];
    
    NSLog(@"Ret: %@", retVal);
    
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

- (void) showSongMeta
{
    NSDictionary *values = [self getSongMeta];
    
    NSString *message = @"";
    
    NSString *title = [values valueForKey:@"title"];
    NSString *band = [values valueForKey:@"band"];
    
    if (title || band) {
        if (band) {
            message = [message stringByAppendingString:
                       [NSString stringWithFormat:@"Band: %@\n", band]];
        }
        
        if (title) {
            message = [message stringByAppendingString:
                       [NSString stringWithFormat:@"Song: %@\n", title]];
        }
        
    } else {
        message = @"Song information could not be found.";
    }
    NSLog(@"Showing %@", message);
    
    ProcessSerialNumber psn = {0, kCurrentProcess};
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Thanks"];
    [alert setMessageText:@"Now Playing:"];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    
    [alert runModal];
    
    TransformProcessType(&psn, kProcessTransformToBackgroundApplication);
}

- (void) createMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    systemStatusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [systemStatusItem setTitle:@"Stayshons"];
    [systemStatusItem setHighlightMode:YES];
    
    appMenu = [[NSMenu alloc] init];
    
    NSURL *stationsPath = [[NSURL alloc] initWithString:@"http://dannyrich.com/api/stayshons.php?key=123456789"];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:stationsPath                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest                                     returningResponse:&response error:&error];
    
    NSArray* stationHold = [NSJSONSerialization JSONObjectWithData:urlData                       options:0 error:&error];
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    stations = [stationHold sortedArrayUsingDescriptors:sortDescriptors];
    
    [appMenu addItem:[NSMenuItem separatorItem]];
    
    for(NSDictionary *station in stations) {
        NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:[station valueForKey:@"title"]                                                   action:@selector(play:) keyEquivalent:@""];
        [mi setTag:[menuItems count]];
        [menuItems addObject:mi];
        [appMenu addItem:mi];
    }
    
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    [systemStatusItem setMenu:appMenu];
    
    
    audioPlayer = [[STKAudioPlayer alloc] init];
    audioPlayer.delegate = self;
}

-(void) playURLString:(NSString*) urlString
{
    [self stop];
    [audioPlayer play:urlString];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    menuItems = [[NSMutableArray alloc] init];
    [self createMenu];
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    if(audioPlayer) {
        [audioPlayer stop];
    }
}

- (void) quit {
    [NSApp terminate:NULL];
}

- (void) stop:(NSMenuItem*) menuItem {
    [self stop];
}

- (void) stop {
    if (audioPlayer) {
        [audioPlayer stop];
    }
    
    NSMenuItem *micheck = [appMenu itemWithTag: -1];
    NSMenuItem *michecktwo = [appMenu itemWithTag: -2];
    
    if (micheck) {
        [appMenu removeItem: micheck];
    }
    if (michecktwo) {
        [appMenu removeItem: michecktwo];
    }
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    NSMenuItem *micheck = [appMenu itemWithTag: -1];
    
    if (micheck == NULL) {
        NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:@"Stop" action:@selector(play:) keyEquivalent:@""];
        [mi setTag:-1];
        
        NSString *uri = [station valueForKey:@"playing"];
        
        if (uri) {
            NSMenuItem *mitwo = [[NSMenuItem alloc] initWithTitle:@"What's Playing?" action:@selector(showSongMeta) keyEquivalent:@""];
            [mitwo setTag:-2];
        
            [appMenu insertItem:mitwo atIndex:0];
        }
        
        [appMenu insertItem:mi atIndex:0];
    }
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

