#import "FastTabPlugin.h"

@implementation FastTabPlugin

- (id)initWithPlugInController:(CodaPlugInsController*)controller_ bundle:(NSBundle*)bundle_ {
    if (self = [super init]) {
		for (int i = 1; i <= 9; i++) {
			[controller_ registerActionWithTitle:[NSString stringWithFormat:@"Select Tab %d", i]
						   underSubmenuWithTitle:nil
										  target:self 
										selector:@selector(switchToTab:)
							   representedObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:@"tabNum"]
								   keyEquivalent:[NSString stringWithFormat:@"~@%d", i]
									  pluginName:@"FastTab"];
		}
    }
    return self;
}

- (int) numberOfTabs
{
	NSDictionary *scriptError = [[NSDictionary alloc] init]; 
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:@"set numTabs to {}\n"
																		"tell application \"Coda\"\n"
																		"	set numTabs to numTabs & number of tabs of document 1\n"
																		"end tell\n"
																		"return numTabs\n"];
	NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&scriptError];

	if (result == nil) {
//		NSLog(@"AppleScript Error while counting tabs: %@", scriptError);
		return 0;
	}
	
	return [[result descriptorAtIndex:1] int32Value];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
	int tabNum = [[[menuItem representedObject] objectForKey:@"tabNum"] intValue];
	return (tabNum <= [self numberOfTabs]);
}

- (void) switchToTab:(NSMenuItem *)menuItem {
	int tabNum = [[[menuItem representedObject] objectForKey:@"tabNum"] intValue];
	
	if (tabNum > [self numberOfTabs]) {
		return;
	}
	
	NSDictionary *scriptError = [[NSDictionary alloc] init]; 
	NSString *tabScript =	@"tell application \"Coda\"\n"
							"	set NewTab to tab %d of document 1\n"
							"	set current tab of document 1 to NewTab\n"
							"end tell\n"; 

	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:tabScript, tabNum]]; 
	NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&scriptError];

	if (result == nil) {
//		NSLog(@"AppleScript Error: %@", [scriptError description]);
		NSBeep();
	}
}

- (NSString*)name {
    return @"FastTab";
}

@end
