//
//  SoundSettingsTableDelegate.m
//  SpaceRadio
//
//  Created by Ashutosh on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundSettingsTableDelegate.h"
#import "OverlaySoundSettingTableCell.h"
#import "SoundManager.h"
#import "MKStoreManager.h"

@implementation SoundSettingsTableDelegate

- (id)initWithController:(PurchaseViewController *)c
{
    self = [super init];
    if (self) {
        purchaseController = c;
        audioPlayIndex = -1;
        [self loadSounds];
    }
    return self;
}

- (void)dealloc
{
    [self stopSounds];

    [sounds release];
    sounds = nil;
    purchaseController = nil;
    
    [super dealloc];
}

- (void)loadSounds
{
    audioPlayIndex = -1;
    [sounds release];
    sounds = [[NSMutableArray arrayWithArray:[[SoundManager manager] getUnlockedSounds]] retain];
}

- (void)stopSounds
{
    if (player != nil) {
        [player stop];
        player.delegate = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundStopped" object:nil];
        [player release];
        player = nil;
    }
    audioPlayIndex = -1;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sounds count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger fromIdx = fromIndexPath.row;
    NSUInteger toIdx = toIndexPath.row;

    [[SoundManager manager] moveSoundFromIndex:fromIdx toIndex:toIdx];
    [[SoundManager manager] save];

    NSObject * sound = [[sounds objectAtIndex:fromIdx] retain];
    [sounds removeObjectAtIndex:fromIdx];
    [sounds insertObject:sound atIndex:toIdx];
    [sound release];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundDropped" object:nil];

    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OverlaySoundSettingTableCell *cell = (OverlaySoundSettingTableCell *)[tableView dequeueReusableCellWithIdentifier:@"OverlaySoundSettingTableCell"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OverlaySoundSettingTableCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (OverlaySoundSettingTableCell *) currentObject;
                CGRect rect = cell.bounds;
                rect.size.width = tableView.frame.size.width;
                cell.bounds = rect;
                break;
            }
        }
    }

    NSUInteger index = indexPath.row;
    NSString *soundName = [[sounds objectAtIndex:index] objectForKey:@"sound"];

    cell.tag = index;
    [cell setUpDataForSound:soundName atIndex:index cellHighlighted:(audioPlayIndex == index)];
    
    return cell;

}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // adjust the draggable part of the cell
    cell.showsReorderControl = NO;
    for(UIView* view in cell.subviews)
    {
        if([[[view class] description] isEqualToString:@"UITableViewCellReorderControl"])
        {
            view.tag = indexPath.row;

            // outer resized grip view (required to position properly)
            CGRect rect = CGRectMake(38, 0, CGRectGetMaxX(view.frame)-76, CGRectGetMaxY(view.frame));
            UIView* resizedGripView = [[[UIView alloc] initWithFrame:rect] autorelease];
            [resizedGripView addSubview:view];
            [cell addSubview:resizedGripView];
            
            // inner resized grip view (required to transform properly)
            rect = CGRectMake(0, 0, CGRectGetMaxX(view.frame), CGRectGetMaxY(view.frame));
            UIView* resizedGripView2 = [[[UIView alloc] initWithFrame:rect] autorelease];
            [resizedGripView2 addSubview:view];
            [resizedGripView addSubview:resizedGripView2];
            
            CGSize sizeDifference = CGSizeMake(resizedGripView2.frame.size.width - view.frame.size.width, resizedGripView2.frame.size.height - view.frame.size.height);
            CGSize transformRatio = CGSizeMake(resizedGripView2.frame.size.width / view.frame.size.width, resizedGripView2.frame.size.height / view.frame.size.height);

            // apply transform to inner resized grip view
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformScale(transform, transformRatio.width, transformRatio.height);
            transform = CGAffineTransformTranslate(transform, -sizeDifference.width / 2.0, -sizeDifference.height / 2.0);
            [resizedGripView2 setTransform:transform];

            // add tap gesture for audio play
            UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [view addGestureRecognizer:gr];
            [gr release];

            // add long press gesture for drag-drop
            UILongPressGestureRecognizer * gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            gesture.cancelsTouchesInView = NO;
            gesture.minimumPressDuration = 0.150;
            [view addGestureRecognizer:gesture];
            [gesture release];

            // clear out the image for the default reorder control
            for(UIImageView* cellGrip in view.subviews)
            {
                cellGrip.hidden = YES;
            }
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    // play sound on tap
    NSInteger index = gestureRecognizer.view.tag;
    NSString * soundName = [[sounds objectAtIndex:index] objectForKey:@"sound"];
    NSString *soundlistPath = [[NSBundle mainBundle] pathForResource:@"soundlist" ofType:@"plist"];    
    NSArray *soundlist = [NSDictionary dictionaryWithContentsOfFile:soundlistPath];
    NSDictionary *sound = [soundlist valueForKey:soundName];
  	NSString *path = [[NSBundle mainBundle] pathForResource:[sound valueForKey:@"File"] ofType:@"mp3"];
  	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath: path] autorelease];
    
    // stop previous sound
    if(player!= nil && player.playing) {
        [self stopSounds];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundStopped" object:nil];
    }

    // start playing new sound
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundPlayed" object:[NSNumber numberWithInt:index]];
    audioPlayIndex = index;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: nil];
	player = newPlayer;
	[player prepareToPlay]; 
	[player setDelegate: self];
	[player play];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSInteger index = gestureRecognizer.view.tag;

    // stop previous sound
    if(player!= nil && player.playing) {
        [self stopSounds];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundStopped" object:nil];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundDragged" object:[NSNumber numberWithInt:index]];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    audioPlayIndex = -1;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"settingsTableSoundStopped" object:nil];
}

@end
