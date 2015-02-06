//
//  DockExchangeFactionsSelection.m
//  Space Dock
//
//  Created by Robert George on 2/5/15.
//  Copyright (c) 2015 Robert George. All rights reserved.
//

#import "DockExchangeFactionsSelection.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@interface DockExchangeFactionsSelection ()
@property (strong, nonatomic) IBOutlet NSWindow* window;
@property (strong, nonatomic) IBOutlet NSWindow* mainWindow;
@property (strong, nonatomic) IBOutlet NSPopUpButton* factionA;
@property (strong, nonatomic) IBOutlet NSPopUpButton* factionB;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) DockSquad* targetSquad;
@property (strong, nonatomic) NSString* faction1;
@property (strong, nonatomic) NSString* faction2;
@end

@implementation DockExchangeFactionsSelection

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [_window orderOut: nil];
}

-(void)show:(DockSquad*)targetSquad context:(NSManagedObjectContext*) managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    _targetSquad = targetSquad;
    NSArray* factions = [[[DockUpgrade allFactions:_managedObjectContext] allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    [_factionA removeAllItems];
    [_factionB removeAllItems];
    [_factionA addItemsWithTitles:factions];
    [_factionB addItemsWithTitles:factions];
    if (_targetSquad.resourceAttributes.length > 0 && [_targetSquad.resourceAttributes containsString:@" & "]) {
        NSArray* selectedFactions = [_targetSquad.resourceAttributes componentsSeparatedByString:@" & "];
        if (selectedFactions.count == 2) {
            [_factionA selectItemWithTitle:[selectedFactions objectAtIndex:0]];
            [_factionB selectItemWithTitle:[selectedFactions objectAtIndex:1]];
        } else {
            [_factionA selectItemAtIndex:0];
            [_factionB selectItemAtIndex:1];
        }
    } else {
        [_factionA selectItemAtIndex:0];
        [_factionB selectItemAtIndex:1];
    }
    [_factionB removeItemWithTitle:_factionA.selectedItem.title];
    [_factionA removeItemWithTitle:_factionB.selectedItem.title];
    _faction1 = _factionA.selectedItem.title;
    _faction2 = _factionB.selectedItem.title;
    [NSApp beginSheet: _window modalForWindow: _mainWindow modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction)selectFaction:(id)sender
{
    NSSet* factions = [DockUpgrade allFactions:_managedObjectContext];
    if (sender == _factionA) {
        _faction1 = _factionA.selectedItem.title;
        [_factionB removeAllItems];
        [_factionB addItemsWithTitles:[[[factions objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            NSString* so = (NSString*)obj;
            return ![so isEqualToString:_faction1];
        }] allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)]];
        if (![_faction2 isEqualToString:_faction1]) {
            [_factionB selectItemWithTitle:_faction2];
        } else {
            [_factionB selectItemAtIndex:0];
        }
    } else if (sender == _factionB) {
        _faction2 = _factionB.selectedItem.title;
        [_factionA removeAllItems];
        [_factionA addItemsWithTitles:[[[factions objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            NSString* so = (NSString*)obj;
            return ![so isEqualToString:_faction2];
        }] allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)]];
        if (![_faction1 isEqualToString:_faction2]) {
            [_factionA selectItemWithTitle:_faction1];
        } else {
            [_factionA selectItemAtIndex:0];
        }
    }
}

-(IBAction)cancel:(id)sender
{
    _targetSquad.resource = nil;
    _targetSquad = nil;
    [NSApp endSheet: _window];
}

-(IBAction)setResource:(id)sender
{
    [_window makeFirstResponder: nil];
    _targetSquad.resourceAttributes = [NSString stringWithFormat:@"%@ & %@", _faction1,_faction2];
    _targetSquad = nil;
    [NSApp endSheet: _window];
}

@end
