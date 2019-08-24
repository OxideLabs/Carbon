#include "headers.h"

// Listener
%hook NSObject
%property (nonatomic, assign) BOOL hasToggleNotifier;
%end
// End Listener

// Keyboard
%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
  light = enabled && keyboard ? NO : light;
  %orig(light);
}
%end
// End Keyboard

%group SpringBoard
// Blanket
%hook UIView
%property (nonatomic, retain) UIColor *carbonBackgroundColor;
%property (nonatomic, retain) UIColor *normalBackgroundColor;
- (void)setBackgroundColor:(UIColor *)color {
  if(!self.normalBackgroundColor)
    self.normalBackgroundColor = color;
  
  %orig(color);
}
%new
- (void)setCarbonEnabled:(BOOL)enable {
  self.backgroundColor = enable && self.carbonBackgroundColor ? self.carbonBackgroundColor : self.normalBackgroundColor;
}
%end

%hook UILabel
%property (nonatomic, retain) UIColor *carbonTextColor;
%property (nonatomic, retain) UIColor *normalTextColor;
- (void)setTextColor:(UIColor *)color {
  if(!self.normalTextColor)
    self.normalTextColor = color;

  %orig(color);
}
%new
- (void)setCarbonEnabled:(BOOL)enable {
  self.textColor = enable && self.carbonTextColor ? self.carbonTextColor : self.normalTextColor;
}
%end

%hook CALayer
%property (nonatomic, retain) NSArray *carbonFilters;
%property (nonatomic, retain) NSArray *normalFilters;
- (void)setFilters:(NSArray *)filters {
  if(!self.normalFilters) {
    self.normalFilters = filters;
    if(enabled && self.carbonFilters) {
      filters = self.carbonFilters;
    }
  }
  %orig(filters);
}
%new
- (void)setCarbonEnabled:(BOOL)enable {
  self.filters = enable && self.carbonFilters ? self.carbonFilters : self.normalFilters;
}
%end
// End Blanket

// 3D Touch
%hook MTMaterialView
-(void)layoutSubviews {
  %orig;
  if([self.superview isKindOfClass:%c(SBFView)]) {
    ((UILabel *)[self valueForKey:@"_primaryOverlayView"]).backgroundColor = [UIColor colorWithWhite:enabled && forcetouch ? 0.0 : 1.0 alpha:0.44];
    if(self.frame.size.height == 150)
      ((UILabel *)[self valueForKey:@"_primaryOverlayView"]).backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];  
  }
}
%end

%hook SBUIActionView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
- (void)setHighlighted:(BOOL)highlighted {
  %orig(highlighted);
  if(enabled && notifications) {
    if(([[[UIDevice currentDevice] systemVersion] compare:@"11.4.1" options:NSNumericSearch] != NSOrderedDescending)) {
      self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:highlighted ? 0.2 : 0.44];
    }
  }
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled && forcetouch ? [NSArray arrayWithObjects:[%c(CAFilter) filterWithType:@"colorInvert"], nil] : nil;
  if([[[UIDevice currentDevice] systemVersion] compare:@"11.4.1" options:NSNumericSearch] == NSOrderedDescending) {
    ((UIImageView *)[self valueForKey:@"_legibilityTreatedImageView"]).alpha = enabled && forcetouch ? 0.95 : 0.34;
    ((UILabel *)[self valueForKey:@"_legibilityTreatedTitleLabel"]).alpha = enabled && forcetouch ? 0.95 : 0.34;
  } else {
    self.backgroundColor = [UIColor colorWithWhite:1.0  alpha:0.44];
  }
}
%end

%hook SBUIActionKeylineView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled && forcetouch ? nil : [NSArray arrayWithObjects:[%c(CAFilter) filterWithType:@"colorInvert"], nil];
}
%end
// End 3D Touch

// Dock (iPad + iPhone)
%hook SBFloatingDockPlatterView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  [[self valueForKey:@"_backgroundView"] transitionToStyle:enabled && dock ? 2030 : 2020];
}
%end

%hook SBDockView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = TRUE;
  }
}
%new
- (void)toggleCarbon {
  [((SBWallpaperEffectView *)[self valueForKey:@"_backgroundView"]) setStyle:enabled && dock ? 14 : 12];
}
%end
// End Dock

// Folders
%hook SBIconBlurryBackgroundView
- (void)didAddSubview:(id)view {
	return;
}
%end

%hook SBFolderIconBackgroundView
%property (retain, nonatomic) _UIBackdropView *darkBackdropView;
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = TRUE;
  }

  if(!self.darkBackdropView){
    self.darkBackdropView = [[_UIBackdropView alloc] initWithStyle:1001];
		self.darkBackdropView.frame = self.bounds;
		[self addSubview:self.darkBackdropView];
  }
}
%new
- (void)toggleCarbon {
  self.darkBackdropView.hidden = enabled && folders ? FALSE : TRUE;
}
%end

%hook SBFolderBackgroundView
%property (retain, nonatomic) _UIBackdropView *darkBackdropView;
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = TRUE;
  }
  if(!self.darkBackdropView){
    self.darkBackdropView = [[_UIBackdropView alloc] initWithStyle:1001];
		self.darkBackdropView.frame = self.bounds;
		[self addSubview:self.darkBackdropView];
  }
}
%new
- (void)toggleCarbon {
  self.darkBackdropView.hidden = !(enabled && folders);
  ((UIImageView *)[self valueForKey:@"_tintView"]).hidden = enabled && folders;
  ((UIImageView *)[self valueForKey:@"_tintView"]).alpha = enabled && folders ? 0 : 1;
}
%end
// End Folders

// Launchscreens
%hook SBUIController
+(id)zoomViewForDeviceApplicationSceneHandle:(id)arg1 displayConfiguration:(id)arg2 interfaceOrientation:(long long)arg3 snapshot:(id)arg4 snapshotSize:(CGSize)arg5 statusBarDescriptor:(id)arg6 decodeImage:(BOOL)arg7 {
	id view = %orig;
  if(!launchscreens) {
		return view;
	}
  if(enabled) {
    UIView* newView = [[UIView alloc] init];
    newView.backgroundColor = [UIColor blackColor];
    newView.frame = [view frame];
    return newView;
  }
  return view;
}
%end
// End Launchscreens

// Notifications Page
%hook NCNotificationClearAllView
-(void)layoutSubviews {
	%orig;
	((UILabel *)[self valueForKey:@"_clearAllLabel"]).layer.filters = nil;
  ((UILabel *)[self valueForKey:@"_clearAllLabel"]).textColor = enabled && notifications ? [UIColor whiteColor] : [UIColor blackColor];
}
%end

%hook NCNotificationListCellActionButton
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
- (void)setHighlighted:(BOOL)highlighted {
  %orig(highlighted);
  if(enabled && notifications) {
    ((UILabel *)[self valueForKey:@"_backgroundOverlayView"]).backgroundColor = [UIColor colorWithWhite:0.0 alpha:highlighted ? 0.44 : 0.54];
  }
}
%new
- (void)toggleCarbon {
  [[self valueForKey:@"_backgroundOverlayView"] setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.54]];
  [[self valueForKey:@"_backgroundOverlayView"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  
  [((UILabel *)[self valueForKey:@"_titleLabel"]).layer setCarbonFilters:[NSArray arrayWithObjects:darkFilter, nil]];
  [((UILabel *)[self valueForKey:@"_titleLabel"]).layer setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
}
%end

%hook NCNotificationOptions
-(BOOL)prefersDarkAppearance {
  return notifications ? FALSE : %orig;
}
%end

%hook NCToggleControl
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
- (void)setHighlighted:(BOOL)highlighted {
  %orig(highlighted);
  if(enabled && notifications) {
    ((UILabel *)[self valueForKey:@"_overlayMaterialView"]).backgroundColor = [UIColor colorWithWhite:0.0 alpha:highlighted ? 0.44 : 0.54];
  }
}
%new
- (void)toggleCarbon {
  [[self valueForKey:@"_overlayMaterialView"] setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.54]];
  [[self valueForKey:@"_overlayMaterialView"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  
  [((UILabel *)[self valueForKey:@"_titleLabel"]).layer setCarbonFilters:[NSArray arrayWithObject:darkFilter]];
  [((UILabel *)[self valueForKey:@"_titleLabel"]).layer setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  
  [((UIView *)[self valueForKey:@"_glyphView"]).layer setCarbonFilters:[NSArray arrayWithObject:darkFilter]];
  [((UIView *)[self valueForKey:@"_glyphView"]).layer setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
}
%end

%hook NCNotificationShortLookView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
}
-(void)setHighlighted:(BOOL)highlighted {
  %orig(highlighted);
  if(enabled && notifications)
    ((UIView *)[self valueForKey:@"_mainOverlayView"]).backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.54];
}
%new
- (void)toggleCarbon {
  [[self valueForKey:@"_mainOverlayView"] setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.54]];
  [[self valueForKey:@"_mainOverlayView"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  
  [[[self valueForKey:@"_notificationContentView"] valueForKey:@"_primaryLabel"] setCarbonTextColor:[UIColor whiteColor]];
  [[[self valueForKey:@"_notificationContentView"] valueForKey:@"_primaryLabel"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];

	[[[self valueForKey:@"_notificationContentView"] valueForKey:@"_primarySubtitleLabel"] setCarbonTextColor:[UIColor whiteColor]];
  [[[self valueForKey:@"_notificationContentView"] valueForKey:@"_primarySubtitleLabel"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];

  ((UILabel *)[[self valueForKey:@"_notificationContentView"] valueForKey:@"_secondaryTextView"]).textColor = enabled && notifications ? [UIColor whiteColor] : [UIColor blackColor];
  
  ((UILabel *)[[self _headerContentView] valueForKey:@"_titleLabel"]).layer.filters = [NSArray arrayWithObjects:enabled && notifications ? darkFilter : lightFilter, nil];
  ((UILabel *)[[self _headerContentView] valueForKey:@"_titleLabel"]).textColor = enabled && notifications ? [UIColor whiteColor] : [UIColor blackColor];

  ((UILabel *)[[self _headerContentView] valueForKey:@"_dateLabel"]).layer.filters = [NSArray arrayWithObjects:enabled && notifications ? darkFilter : lightFilter, nil];
  ((UILabel *)[[self _headerContentView] valueForKey:@"_dateLabel"]).textColor = enabled && notifications ? [UIColor whiteColor] : [UIColor blackColor];

  if([[[UIDevice currentDevice] systemVersion] compare:@"11.4.1" options:NSNumericSearch] == NSOrderedDescending) {
    ((UILabel *)[[self valueForKey:@"_notificationContentView"] valueForKey:@"_summaryLabel"]).layer.filters = [NSArray arrayWithObjects:enabled && notifications ? darkFilter : lightFilter, nil];
    
    [[[self valueForKey:@"_notificationContentView"] _secondaryLabel] setCarbonTextColor:[UIColor whiteColor]];
    [[[self valueForKey:@"_notificationContentView"] _secondaryLabel] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  }
}
%end

%hook NCPreviewInteractionPresentedContentView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  ((UILabel *)[self valueForKey:@"_titleLabel"]).layer.filters = nil;
  ((UILabel *)[self valueForKey:@"_titleLabel"]).textColor = [UIColor colorWithWhite:enabled && notifications ? 1.0 : 0.0 alpha:0.8];
}
%end

%hook NCPreviewInteractionPresentedControl
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  ((MTMaterialView *)[self valueForKey:@"_overlayMaterialView"]).backgroundColor = [UIColor colorWithWhite:enabled && notifications ? 0.0 : 1.0 alpha:0.44];
}
%end

%hook NCNotificationLongLookView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {  
  [[self valueForKey:@"_notificationContentView"] setCarbonBackgroundColor:[UIColor blackColor]];
  [[self valueForKey:@"_notificationContentView"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];

  [[[self valueForKey:@"_notificationContentView"] _primaryLabel] setCarbonTextColor:[UIColor whiteColor]];
  [[[self valueForKey:@"_notificationContentView"] _primaryLabel] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];

  [[[self valueForKey:@"_notificationContentView"] _primarySubtitleLabel] setCarbonTextColor:[UIColor whiteColor]];
  [[[self valueForKey:@"_notificationContentView"] _primarySubtitleLabel] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];

  ((UITextView *)[[self valueForKey:@"_notificationContentView"] valueForKey:@"_secondaryTextView"]).textColor = enabled && notifications ? [UIColor whiteColor] : [UIColor blackColor];
  
  [[self valueForKey:@"_mainContentView"] setCarbonBackgroundColor:[UIColor blackColor]];
  [[self valueForKey:@"_mainContentView"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];

  [self.customContentView setCarbonBackgroundColor:[UIColor blackColor]];
  [self.customContentView setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  
  [[self valueForKey:@"_headerContentView"] setCarbonBackgroundColor:[UIColor blackColor]];
  [[self valueForKey:@"_headerContentView"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
  
  [[self valueForKey:@"_headerDivider"] setCarbonBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
  [[self valueForKey:@"_headerDivider"] setCarbonEnabled:enabled && notifications ? TRUE : FALSE];
}
%end

%hook PLGlyphControl
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  [((UIImageView *)[self valueForKey:@"_glyphView"]).layer setFilters:[NSArray arrayWithObjects:enabled && notifications ? darkFilter : lightFilter, nil]];
  ((UIView *)[[self valueForKey:@"_backgroundMaterialView"] valueForKey:@"_baseOverlayView"]).backgroundColor = [UIColor colorWithWhite:enabled ? 0 : 1 alpha:0.24];
}
%end

%hook PLPlatterView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  ((UIView *)[self valueForKey:@"_mainOverlayView"]).backgroundColor = [UIColor colorWithWhite:0 alpha:0.44];
  ((UIView *)[self valueForKey:@"_mainOverlayView"]).alpha = enabled && notifications ? 1 : 0;
}
%end
// End Notifications Page

// Screen Time
%hook FALockOutView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:[%c(CAFilter) filterWithType:@"colorInvert"], nil] : nil;
  self.mainButton.layer.filters = enabled ? [NSArray arrayWithObjects:[%c(CAFilter) filterWithType:@"colorInvert"], nil] : nil;
}
%end

%hook _WGLockedOutWidgetView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:[%c(CAFilter) filterWithType:@"colorInvert"], nil] : nil;
}
%end
// End Screen Time

// Search
%hook SPUIHeaderBlurView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  self.effect = [UIBlurEffect effectWithStyle:enabled ? UIBlurEffectStyleDark : UIBlurEffectStyleRegular];
}
%end

%hook SearchUITableViewCell
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor colorWithWhite:0 alpha:0.24] : [UIColor colorWithWhite:1 alpha:0.14]; 
}
%end
// End Search

// Springboard Toggle
%hook SpringBoard
%new
-(void)toggleCarbon {
  NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
  NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:prefs];
  [dict setValue:[NSNumber numberWithBool:enabled ? FALSE : TRUE] forKey:@"enabled"];
  [dict writeToFile:PREFERENCES_PATH atomically:YES];

  if(enabled)
    carbonDisabled();
  else
    carbonEnabled();
  
  CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:enabled], CFSTR("com.oxidelabs.carbon"));
}
%end
// End Springboard Toggle

// Widgets Page
%hook WGWidgetPlatterView
- (void)layoutSubviews {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  [[self valueForKey:@"_mainOverlayView"] setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.49]];
  [[self valueForKey:@"_mainOverlayView"] setCarbonEnabled:enabled && widgets ? TRUE : FALSE];

  [[self valueForKey:@"_headerOverlayView"] setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:headers ? 0.59 : 0.49]];
  [[self valueForKey:@"_headerOverlayView"] setCarbonEnabled:enabled && widgets ? TRUE : FALSE];
  
  ((UILabel *)[[self _headerContentView] valueForKey:@"_titleLabel"]).layer.filters = [NSArray arrayWithObjects:enabled && widgets ? darkFilter : lightFilter, nil];
  ((UILabel *)[[self _headerContentView] valueForKey:@"_titleLabel"]).textColor = enabled && widgets ? [UIColor whiteColor] : [UIColor blackColor];

  ((UILabel *)[[self _headerContentView] valueForKey:@"_utilityButton"]).layer.filters = [NSArray arrayWithObjects:enabled && widgets ? darkFilter : lightFilter, nil];
  ((UILabel *)[[self _headerContentView] valueForKey:@"_utilityButton"]).textColor = enabled && widgets ? [UIColor whiteColor] : [UIColor blackColor];
}
%end

%hook WGShortLookStyleButton
- (void)layoutSubviews {
  %orig;
	self.clipsToBounds = TRUE;
	self.layer.cornerRadius = self.frame.size.height/2;

  [self toggleCarbon]; 
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
}
%new
- (void)toggleCarbon {
  ((UILabel *)[self valueForKey:@"_titleLabel"]).layer.filters = [NSArray arrayWithObjects:enabled && widgets ? darkFilter : lightFilter, nil];
  ((UILabel *)[self valueForKey:@"_titleLabel"]).textColor = enabled && widgets ? [UIColor whiteColor] : [UIColor blackColor];
  
  if(([[[UIDevice currentDevice] systemVersion] compare:@"11.4.1" options:NSNumericSearch] != NSOrderedDescending)) {
    self.backgroundColor = [UIColor colorWithWhite:0.0  alpha:enabled && widgets ? 0.4 : 0.0];
  } else {
    ((UIView *)[[self valueForKey:@"_backgroundView"] valueForKey:@"_baseOverlayView"]).backgroundColor = [UIColor colorWithWhite:enabled && widgets ? 0.0 : 1.0 alpha:0.24];
  }
}
%end
// End Widgets Page
%end

// Begin Widgets Text
%group Widgets
%hook CALayer
%property (nonatomic, retain) NSArray *carbonFilters;
%property (nonatomic, retain) NSArray *normalFilters;
%property (nonatomic, retain) CAFilter *normalFilter;
- (void)layoutSublayers {
  %orig;
  [self toggleCarbon];
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
}
- (void)setFilters:(NSArray *)filters {
  if(!self.filters) {
    self.normalFilters = self.filters;
  }
  %orig(filters);
}
- (void)setCompositingFilter:(CAFilter *)filter {
  if(!self.compositingFilter) {
    self.normalFilter = self.compositingFilter;
  }
  %orig(filter);
}
%new
- (void)toggleCarbon {
  if(self.filters && self.compositingFilter) {
    [self setCarbonFilters:[NSArray arrayWithObjects:[%c(CAFilter) filterWithType:@"colorInvert"], nil]];
  }
  self.filters = enabled && widgets ? self.carbonFilters : self.normalFilters;
  self.compositingFilter = enabled && widgets ? nil : self.normalFilters;
}
%end

%hook UIButton
%property (nonatomic, retain) UIColor *stockTintColor;
- (void)setTintColor:(UIColor *)color {
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }

  if(!self.stockTintColor)
    self.stockTintColor = color;
  
  if(enabled && widgets)
    color = [UIColor whiteColor];

  %orig(color);
}
%new
- (void)toggleCarbon {
  self.tintColor = enabled && widgets ? [UIColor whiteColor] : self.stockTintColor;
}
%end

%hook UILabel
- (void)setTextColor:(UIColor *)color {
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }

  if(enabled && widgets)
    color = [UIColor colorWithWhite:1 alpha:0.8];
  
  %orig(color);
}
%new
- (void)toggleCarbon {
  self.textColor = [UIColor colorWithWhite:enabled && widgets ? 1.0 : 0.0 alpha:0.8];
}
%end
%end
// End Widgets Text

// Credits to iPhoneDevWiki CFNotificationCenter Example
static void setCarbonEnabled(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  enabled = YES;
  CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:YES], CFSTR("com.oxidelabs.carbon"));
  [[NSNotificationCenter defaultCenter] postNotificationName:@"com.oxidelabs.carbon.update" object:nil userInfo:nil];
}

static void setCarbonDisabled(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  enabled = NO;
  CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:NO], CFSTR("com.oxidelabs.carbon"));
  [[NSNotificationCenter defaultCenter] postNotificationName:@"com.oxidelabs.carbon.update" object:nil userInfo:nil];
}

static void carbonEnabled() {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.oxidelabs.carbon.enabled"), nil, nil, true);
}

static void carbonDisabled() {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.oxidelabs.carbon.disabled"), nil, nil, true);
}

// Credits to iPhoneDevWiki PreferenceBundles -> Loading Preferences
static void updatePrefs() {
  CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.oxidelabs.carbon"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if(keyList) {
    prefs = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.oxidelabs.carbon"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
    if(!prefs) prefs = [NSMutableDictionary new];
      CFRelease(keyList);
  }
  if (!prefs) {
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
  }

  enabled = [([prefs objectForKey:@"enabled"] ?: @(YES)) boolValue];

  dock = [([prefs objectForKey:@"dock"] ?: @(YES)) boolValue];
  folders = [([prefs objectForKey:@"folders"] ?: @(YES)) boolValue];
  forcetouch = [([prefs objectForKey:@"forcetouch"] ?: @(YES)) boolValue];
  headers = [([prefs objectForKey:@"headers"] ?: @(YES)) boolValue];
  keyboard = [([prefs objectForKey:@"keyboard"] ?: @(YES)) boolValue];
  launchscreens = [([prefs objectForKey:@"launchscreens"] ?: @(YES)) boolValue];
  notifications = [([prefs objectForKey:@"notifications"] ?: @(YES)) boolValue];
  widgets = [([prefs objectForKey:@"widgets"] ?: @(YES)) boolValue];

  lightFilter = [%c(CAFilter) filterWithType:@"vibrantLight"];
  [lightFilter setValue:(id)[[UIColor colorWithWhite:0.0 alpha:0.6] CGColor] forKey:@"inputColor0"];
  [lightFilter setValue:(id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor] forKey:@"inputColor1"];
  [lightFilter setValue:[NSNumber numberWithBool:YES] forKey:@"inputReversed"];

  darkFilter = [%c(CAFilter) filterWithType:@"vibrantDark"];
	[darkFilter setValue:(id)[[UIColor colorWithWhite:1 alpha:0.6] CGColor] forKey:@"inputColor0"];
	[darkFilter setValue:(id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor] forKey:@"inputColor1"];
	[darkFilter setValue:[NSNumber numberWithBool:YES] forKey:@"inputReversed"];
}

// Credits to iPhoneDevWiki Updating extensions for iOS 9.3.3
static void respringDevice() {
  [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor {
  updatePrefs();
  
  prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
  
  BOOL shouldLoadSpringBoardHooks = NO;
  BOOL shouldLoadWidgetHooks = NO;

  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) updatePrefs, CFSTR("com.oxidelabs.carbon.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) respringDevice, CFSTR("com.oxidelabs.respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setCarbonEnabled, CFSTR("com.oxidelabs.carbon.enabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setCarbonDisabled, CFSTR("com.oxidelabs.carbon.disabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

  if([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
    shouldLoadSpringBoardHooks = YES;
  }
  if([(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"]) {
    if([[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"]) {
      if([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.widget-extension"]]) {
        shouldLoadWidgetHooks = YES;
      }
    }
  }
  if([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.Fitness.activity-widget"]) {
    shouldLoadWidgetHooks = NO;
  }
  if(shouldLoadSpringBoardHooks) {
    %init(SpringBoard);
  }
  if(shouldLoadWidgetHooks) {
    %init(Widgets);
  }
  %init;
}
