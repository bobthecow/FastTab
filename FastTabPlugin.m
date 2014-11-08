#import "FastTabPlugin.h"

@implementation FastTabPlugin


- (id)initWithPlugInController:(CodaPlugInsController*)controller_ plugInBundle:(id <CodaPlugInBundle>)bundle_ {
    if (self = [super init]) {
        [self initMenuWithController:controller_];
    }
    return self;
}

- (id)initWithPlugInController:(CodaPlugInsController*)controller_ bundle:(NSBundle*)bundle_ {
    if (self = [super init]) {
        [self initMenuWithController:controller_];
    }
    return self;
}

- (void)initMenuWithController:(CodaPlugInsController*)controller_ {
    for (int i = 1; i <= 8; i++) {
        [controller_ registerActionWithTitle:[NSString stringWithFormat:@"Select Tab %d", i]
                       underSubmenuWithTitle:nil
                                      target:self
                                    selector:@selector(switchToTab:)
                           representedObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:@"tabNum"]
                               keyEquivalent:[NSString stringWithFormat:@"^%d", i]
                                  pluginName:@"FastTab"];
    }

    [controller_ registerActionWithTitle:@"Select Last Tab"
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(switchToTab:)
                       representedObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"tabNum"]
                           keyEquivalent:@"^9"
                              pluginName:@"FastTab"];
}

- (int) numberOfTabs
{
    NSDictionary *scriptError  = [[NSDictionary alloc] init];
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:@"set numTabs to {}\n"
                                                                        "tell application id \"com.panic.Coda2\"\n"
                                                                        "   set numTabs to numTabs & number of tabs of window 1\n"
                                                                        "end tell\n"
                                                                        "return numTabs\n"];
    NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&scriptError];

    [appleScript release];

    if (result == nil) {
        NSLog(@"AppleScript Error while counting tabs: %@", scriptError);
        [scriptError release];
        return 0;
    }

    [scriptError release];

    return [[result descriptorAtIndex:1] int32Value];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    int tabNum = [[[menuItem representedObject] objectForKey:@"tabNum"] intValue];
    int numberOfTabs = [self numberOfTabs];

    return (numberOfTabs > 0 && tabNum <= numberOfTabs);
}

- (void) switchToTab:(NSMenuItem *)menuItem {
    int tabNum = [[[menuItem representedObject] objectForKey:@"tabNum"] intValue];
    int numberOfTabs = [self numberOfTabs];

    if (tabNum == 0) {
        tabNum = numberOfTabs;
    }

    if (tabNum > numberOfTabs) {
        return;
    }

    NSDictionary *scriptError = [[NSDictionary alloc] init];
    NSString *tabScript =   @"tell application id \"com.panic.Coda2\"\n"
                            "   set selected tab of window 1 to tab %d of window 1\n"
                            "end tell\n";

    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:tabScript, tabNum]];
    NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&scriptError];

    if (result == nil) {
        NSLog(@"AppleScript Error: %@", [scriptError description]);
        NSBeep();
    }

    [appleScript release];
    [scriptError release];
}

- (NSString*)name {
    return @"FastTab";
}

@end
