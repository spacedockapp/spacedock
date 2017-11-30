//
//  DockResourceUpgradeRowHandler.m
//  Space Dock iOS
//
//  Created by Robert George on 11/29/17.
//  Copyright © 2017 Robert George. All rights reserved.
//

#import "DockResourceUpgradeRowHandler.h"

#import "DockResourceUpgrade+Addons.h"
#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockExtrasTableViewCell.h"
#import "DockUpgrade+Addons.h"

@implementation DockResourceUpgradeRowHandler

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    DockEquippedUpgrade* eqr = _equippedShip.equippedResource;
    
    NSString* upType = @"Resource";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];
    
    if (eqr != nil) {
        DockResourceUpgrade* resUp = (DockResourceUpgrade*)eqr.upgrade;
        cell.textLabel.text = eqr.title;
        cell.detailTextLabel.text = [[resUp cost] stringValue];
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.text = upType;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @" ";
    }
    
    return cell;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [_equippedShip removeUpgrade: [_equippedShip equippedAdmiral]];
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    DockEquippedUpgrade* eqr = _equippedShip.equippedResource;
    if (eqr == nil) {
        NSManagedObjectContext* ctx = _equippedShip.managedObjectContext;
        NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedUpgrade" inManagedObjectContext: ctx];
        eqr = [[DockEquippedUpgrade alloc] initWithEntity: entity insertIntoManagedObjectContext: ctx];
        eqr.upgrade = [DockUpgrade placeholder:@"Resource" inContext:ctx];
    }
    [self.controller performSegueWithIdentifier: @"PickUpgrade" sender:eqr];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath row:(NSInteger)row
{
    DockEquippedUpgrade* eqr = _equippedShip.equippedResource;
    if (eqr != nil) {
        return EXTRA_ROW_HEIGHT;
    }
    return tableView.rowHeight;
}

@end
