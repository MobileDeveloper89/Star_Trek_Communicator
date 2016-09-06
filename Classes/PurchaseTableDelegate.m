//
//  PurchaseTableDelegate.m
//  SpaceRadio
//
//  Created by Ashutosh on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurchaseTableDelegate.h"
#import "PurchaseTableCell.h"

@implementation PurchaseTableDelegate

- (id)initWithController:(PurchaseViewController *)c
{
    self = [super init];
    if (self) {
        purchaseController = c;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
        NSDictionary *purchasesPlistData = [NSDictionary dictionaryWithContentsOfFile:path];
        [purchases release];
        purchases = [[purchasesPlistData valueForKey:@"Purchases"] retain];

        // remove hidden purchases
        NSMutableArray * visiblePurchases = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary * purchaseData in purchases) {
            if ([purchaseData objectForKey:@"Hidden"] == nil) {
                [visiblePurchases addObject:purchaseData];
            }
        }
        [purchases release];
        purchases = [[NSArray alloc] initWithArray:visiblePurchases copyItems:YES];

        font = [[UIFont fontWithName:@"Enterprise" size:11] retain];    
        [self reset];
    }
    return self;
}

- (void)dealloc
{
    purchaseController = nil;
    [purchases release];
    purchases = nil;
    font = nil;
    [super dealloc];
}

- (void)reset
{
    lastSelectedRow = -1;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [purchases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PurchaseTableCell *cell = (PurchaseTableCell *)[tableView dequeueReusableCellWithIdentifier:@"PurchaseCell"];
    if (cell == nil)
    {
        NSArray *topLevelItems = [[NSBundle mainBundle] loadNibNamed:@"PurchaseTableCell" owner:nil options:nil];
        for (id currentObject in topLevelItems)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (PurchaseTableCell *) currentObject;
                cell.delegate = self;
                break;
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(buyClickedOnce:) name:@"buyClickedOnce" object:nil];
    }
    

    cell.indexPath = indexPath;
    NSDictionary *purchaseData = [purchases objectAtIndex:indexPath.row];
    [cell loadPurchaseData:purchaseData font:font];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * indexPathSelectedRow = [tableView indexPathForSelectedRow];
    if (indexPathSelectedRow != nil && indexPathSelectedRow.row == indexPath.row)
    {
        if (lastSelectedRowRect.size.height == 156)
            return 53;
        return 156;
    }
    return 53;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedRow = -1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRowAtIndexPath:indexPath];
}

-(void) installedButtonClicked:(NSString *) soundPackName
{
    [purchaseController soundSettingsButtonPressed:nil];
}

-(void) cellHighlightButtonClicked: (NSIndexPath *) indexPath
{    
    [purchaseController.purchaseTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self selectRowAtIndexPath:indexPath];
}

-(void) selectRowAtIndexPath:(NSIndexPath * ) indexPath 
{
    if (lastSelectedRow == indexPath.row)
    {
        lastSelectedRow = -1;
        [purchaseController.purchaseTable deselectRowAtIndexPath:indexPath animated:YES];
        // update the table. this will do the required animations to update the selected/deselected cell heights.
        [purchaseController.purchaseTable beginUpdates];
        [purchaseController.purchaseTable endUpdates];
        return;
    }
    lastSelectedRow = indexPath.row;
    lastSelectedRowRect = [purchaseController.purchaseTable rectForRowAtIndexPath:indexPath];
    // update the table. this will do the required animations to update the selected/deselected cell heights.
    [purchaseController.purchaseTable beginUpdates];
    [purchaseController.purchaseTable endUpdates];
    [purchaseController.purchaseTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

@end
