#import "CarbonToggle.h"

#define PREFERENCES_FILE @"/var/mobile/Library/Preferences/com.oxidelabs.carbon.plist"

static BOOL carbonEnabled;

@implementation CarbonToggle
- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]]];
}

- (UIColor *)selectedColor {
	return [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
}

- (BOOL)isSelected {
	NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:PREFERENCES_FILE]?:[NSDictionary dictionary] copy];
	carbonEnabled = (BOOL)[[settings objectForKey:@"enabled"]?:@TRUE boolValue];

	return carbonEnabled;
}
- (void)setSelected:(BOOL)selected {
	[[NSClassFromString(@"SpringBoard") sharedApplication] toggleCarbon];
	
	self.contentViewController.view.userInteractionEnabled = FALSE;

	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[super refreshState];
		self.contentViewController.view.userInteractionEnabled = TRUE;
	});
}
@end
