#import "headers.h"

%hook NSObject
%property (nonatomic, assign) BOOL hasToggleNotifier;
%property (nonatomic, retain) UIColor *textColor;
%end

%group Calendar
%hook MonthTitleView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor blackColor]];
  [self setCarbonEnabled:enabled];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor blackColor] : color);
}
%end

%hook CompactMonthWeekTodayCircle
-(void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
  [self toggleCarbon];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor blackColor] : color);
}
%new
-(void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook CompactYearMonthView
-(void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
  [self toggleCarbon];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
%new
-(void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
  self.interactionTintColor = enabled ? [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:1.0] : [UIColor colorWithRed:1.0 green:0.188 blue:0.188 alpha:1.0];
}
%end

%hook CompactMonthWeekView
-(void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
  [self toggleCarbon];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
%new
-(void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook EKUIVisualEffectView
-(void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
  [self toggleCarbon];
}
%new
-(void)toggleCarbon {
  for(UIView *view in self.contentView.subviews) {
    view.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
  }
}
%end
%end

%group Applications
%hook UILabel
%property (nonatomic, retain) UIColor *carbonTextColor;
%property (nonatomic, retain) UIColor *normalTextColor;
- (void)layoutSubviews {
  %orig;
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
  [self.textColor getRed:&red green:&green blue:&blue alpha:&alpha];

  if(red == 1.0 && green < 0.232 && green > 0.230 && blue < 0.189 && blue > 0.187) {
    return;
  }
  if(!self.hasToggleNotifier) {
    self.carbonTextColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
  [self toggleCarbon];
}
- (void)setTextColor:(UIColor *)color {
  if(!self.hasToggleNotifier) {
    self.carbonTextColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    [self toggleCarbon];
  }
  if(color != self.carbonTextColor) {
    self.normalTextColor = color;
  }

  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
  [self.normalTextColor getRed:&red green:&green blue:&blue alpha:&alpha];

  if(red == 1.0 && green < 0.232 && green > 0.230 && blue < 0.189 && blue > 0.187) {
    %orig(self.normalTextColor);
    return;
  }

  if(self.carbonTextColor && enabled) {
    %orig(self.carbonTextColor);
  } else {
    %orig;
  }
}
%new
- (void)toggleCarbon {
  if(self.carbonTextColor) {
    if(enabled) {
      self.textColor = self.carbonTextColor;
    } else {
      self.textColor = self.normalTextColor;
    }
  }
}
%end

%hook UIView
%property (nonatomic, retain) UIColor *carbonBackgroundColor;
%property (nonatomic, retain) UIColor *normalBackgroundColor;
-(void)layoutSubviews {
  %orig;
  self.backgroundColor = self.backgroundColor;
}
- (void)setBackgroundColor:(UIColor *)color {
  if(!self.normalBackgroundColor)
    self.normalBackgroundColor = color;

  if([NSStringFromClass([self class]) rangeOfString:@"WDMonthWeekView"].location == NSNotFound && [NSStringFromClass([self.superview class]) rangeOfString:@"BackdropView"].location == NSNotFound && [NSStringFromClass([self.superview class]) rangeOfString:@"VisualEffectView"].location == NSNotFound) {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self.normalBackgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];

    if(red >= 0.9){
      if(green >= 0.9){
        if(blue >= 0.9){
          if(alpha > 0.0){
            if(enabled) {
              if(!self.carbonBackgroundColor) {
                color = [UIColor colorWithWhite:0.0 alpha:alpha];
                self.carbonBackgroundColor = color;
              } else {
                color = self.carbonBackgroundColor;
              }
              if(!self.hasToggleNotifier) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
                self.hasToggleNotifier = TRUE;
              }
            }
          }
        }
      }
    }
  }

  if([NSStringFromClass([self class]) rangeOfString:@"Label"].location != NSNotFound) {
    color = [UIColor clearColor];
  }

  if([self isKindOfClass:NSClassFromString(@"WFAssociationStateView")])
  color = [UIColor clearColor];

  if(self.tag == 3939393) {
    if(enabled)
    color = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
  }

  %orig(color);
}
%new
- (void)setCarbonEnabled:(BOOL)enable {
  self.backgroundColor = enabled && self.carbonBackgroundColor ? self.carbonBackgroundColor : self.normalBackgroundColor;
}
%new
-(void)toggleCarbon {
  self.backgroundColor = enabled && self.carbonBackgroundColor ? self.carbonBackgroundColor : self.normalBackgroundColor;
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

%hook UITableViewCellContentView
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
-(id)backgroundColor {
  return enabled ? [UIColor clearColor] : %orig;
}
%end

%hook UITableViewCell
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:oledMode ? 0.0 : 0.1 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook UITableView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook UITableViewHeaderFooterView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook _UITableViewHeaderFooterViewBackground
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook _UITableViewHeaderFooterContentView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:enabled ? 1.0 : 0.0];
}
%end

%hook _UITableViewCellSeparatorView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.hidden = enabled && separators ? TRUE : FALSE;
  self.alpha = enabled && separators ? 0.0 : 1.0; 
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook WDCalendarScrollViewController
-(void)viewDidLayoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    self.hasToggleNotifier = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
  }
  [self toggleCarbon];
}
%new
-(void)toggleCarbon {
  self.view.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook SXTextView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
-(void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook UITableViewCellSelectedBackground
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.hidden = enabled;
  self.alpha = enabled ? 0.0 : 1.0;
}
%end

%hook WFAssociationStateView
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook EKExpandingTextView
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook UIImageView
-(void)layoutSubviews {
  %orig;
  if([self.superview.superview isKindOfClass:NSClassFromString(@"RemindersSearchView")]) {
    self.hidden = enabled;
    self.alpha = enabled ? 0.0 : 1.0;
  }
}
-(int)_defaultRenderingMode {
  if(![self.superview isKindOfClass:NSClassFromString(@"UIButton")]) {
    if([self.superview.superview isKindOfClass:NSClassFromString(@"WFNetworkListCell")] || [self.superview.superview isKindOfClass:NSClassFromString(@"WFAssociationStateView")]) {
      self.tintColor = enabled ? [UIColor whiteColor] : [UIColor blackColor];
      return 2;
    }
  }
  return %orig;
}
%end

%hook NSAssertionHandler
- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format {
  if([format isEqualToString:@"UISearchBarTextField supports all configurations, we support only the one we expect"]) {
    return;
  }
  %orig;
}
%end

%hook UINavigationBar
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setBarStyle:enabled ? 1 : 0];
}
%end

%hook UITabBar
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setBarStyle:enabled ? 1 : 0];
}
%end

%hook UIToolbar
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setBarStyle:enabled ? 1 : 0];
  [self _updateBarForStyle];
}
%end

%hook UISearchBar
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setBarStyle:enabled ? 1 : 0];
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook _UINavigationBarLargeTitleView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
- (void)updateContent {
  %orig;
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.accessibilityTitleView.textColor = enabled ? [UIColor whiteColor] : [UIColor blackColor];
}
%end

%hook _UINavigationBarContentView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
- (void)updateContent {
  %orig;
  [self toggleCarbon];
}
-(id)currentContentSize {
  [self toggleCarbon];
  return %orig;
}
%new
- (void)toggleCarbon {
  self.accessibilityTitleView.textColor = enabled ? [UIColor whiteColor] : [UIColor blackColor];
}
%end

%hook WDMonthWeekView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor whiteColor]];
  [self setCarbonEnabled:enabled];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor whiteColor] : color);
}
-(UIColor *)backgroundColor {
  return enabled ? [UIColor whiteColor] : %orig;
}
%end

%hook _WDMonthTitleView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook WDTodayPaletteScrollView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook AppStoreSearchCell
- (void)layoutSubviews {
  %orig;

  if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"12.2")) {
    AppStoreSearchCell *searchCell = (AppStoreSearchCell *)self;
    if(!searchCell.hasToggleNotifier) {
      [[NSNotificationCenter defaultCenter] addObserver:searchCell selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
      searchCell.hasToggleNotifier = YES;
    }
    [searchCell toggleCarbon];
  }
}
%new
- (void)toggleCarbon {
  if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"12.2")) {
    AppStoreSearchCell *searchCell = (AppStoreSearchCell *)self;
    searchCell.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
  }
}
%end

%hook AppStoreOfferButton
%property (nonatomic, retain) UIColor *fillColor;
%property (nonatomic, retain) UIColor *strokeColor;
- (void)layoutSubviews {
  %orig;
  AppStoreOfferButton *offerButton = (AppStoreOfferButton *)self;

  if(!offerButton.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:offerButton selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    offerButton.hasToggleNotifier = YES;
  }
  [offerButton toggleCarbon];
}
%new
- (void)toggleCarbon {
  AppStoreOfferButton *offerButton = (AppStoreOfferButton *)self;
  // TO:DO REDO
  if(enabled) {
    for(UIView *view in offerButton.subviews) {
      if(view.frame.size.height > 20 && view.frame.size.width != view.frame.size.height) {
        view.tag = 3939393;
        view.layer.cornerRadius = 15;
        view.clipsToBounds = TRUE;
        view.backgroundColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
      }
    }
  } else {
    for(UIView *view in offerButton.subviews) {
      if(view.frame.size.height > 20 && view.frame.size.width != view.frame.size.height) {
        view.tag = 3939393;
        view.layer.cornerRadius = 15;
        view.clipsToBounds = TRUE;
        view.backgroundColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:0];
      }
    }
  }
}
%end

%hook AppStoreExpand
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? nil : color);
}
%end

%hook AppStoreExpandableTextView
- (void)layoutSubviews {
  %orig;
  AppStoreExpandableTextView *textView = (AppStoreExpandableTextView *)self;
  if(!textView.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:textView selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    textView.hasToggleNotifier = YES;
  }
  [textView toggleCarbon];
}
%new
- (void)toggleCarbon {
  AppStoreExpandableTextView *textView = (AppStoreExpandableTextView *)self;
  textView.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook UIStatusBar
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.foregroundColor = enabled ? [UIColor whiteColor] : nil;
}
%end

%hook UIStatusBar_Modern
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.foregroundColor = enabled ? [UIColor whiteColor] : nil;
}
%end

%hook UIActivityIndicatorView
-(void)layoutSubviews {
  %orig;
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook TopHitCompletionView
-(void)layoutSubviews {
  %orig;
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook NewsViewController
-(void)viewWillAppear:(BOOL)arg1 {
  %orig;
  if(enabled)
    self.view.backgroundColor = [UIColor blackColor];
}
%end

%hook FeaturedViewController
-(void)viewWillAppear:(BOOL)arg1 {
  %orig;
  if(enabled)
    self.view.backgroundColor = [UIColor blackColor];
}
%end

%hook FeaturedPackageView
-(void)layoutSubviews {
  %orig;
  if(enabled)
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook DepictionMarkdownView
-(void)layoutSubviews {
  %orig;
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook CKTextBalloonView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook CKMessageEntryView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  _UIBackdropView *backdropView = [self valueForKey:@"_backdropView"];
  backdropView.grayscaleTintView.backgroundColor = [UIColor colorWithWhite:enabled ? 0.0 : 1.0 alpha:0.8];
}
%end

%hook CKGradientView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook CKBalloonImageView
- (void)layoutSubviews {
  %orig;
  if([NSStringFromClass([self class]) rangeOfString:@"CKBalloonImageView"].location == NSNotFound) {
    return;
  }
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end


%hook CKBalloonTextView
- (void)layoutSubviews {
  %orig;
  if(!self.normalTextColor) {
    self.normalTextColor = self.textColor;
  }

  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
  self.textColor = enabled ? [UIColor whiteColor] : self.normalTextColor;
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook PSPasscodeField
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook NSString

- (void)drawAtPoint:(CGPoint)point withFont:(UIFont *)font {
	if(doCydiaStuff)
		[[UIColor whiteColor] setFill];

	%orig;
}
- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode {
  if(doCydiaStuff)
    [[UIColor whiteColor] setFill];

  return %orig;
}
%end

%hook CyteTableViewCellContentView
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
-(id)backgroundColor {
  return enabled ? [UIColor clearColor] : %orig;
}
- (void)drawRect:(CGRect)rect {
  if(!enabled) {
    %orig;
    return;
  }
	doCydiaStuff = YES;
	%orig;
	doCydiaStuff = NO;
}
%end

%hook PackageCell
- (void)drawContentRect:(CGRect)rect {
  if(!enabled) {
    %orig;
    return;
  }
  BOOL commercial = [self valueForKey:@"commercial_"];
  if(commercial == TRUE) {
    %orig;
    return;
  }
	doCydiaStuff = YES;
	%orig;
	doCydiaStuff = NO;
}
%end

%hook _UIDatePickerView
-(void)layoutSubviews{
  %orig;
  if(enabled)
    self.backgroundColor = [UIColor clearColor];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
%end

%hook PHHandsetDialerView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook CNContactListTableViewCell
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
  self.backgroundView.hidden = enabled;
}
%end

%hook AppStoreDetail
-(void)layoutSubviews {
  %orig;
  AppStoreDetail *detail = (AppStoreDetail *)self;
  if(!detail.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:detail selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    detail.hasToggleNotifier = YES;
  }
  [detail toggleCarbon];
}
%new
- (void)toggleCarbon {
  AppStoreDetail *detail = (AppStoreDetail *)self;
  detail.titleLabel.textColor = enabled ? [UIColor whiteColor] : [UIColor blackColor];
}
%end

%hook AppStoreSearch
-(void)layoutSubviews {
  %orig;
  AppStoreSearch *detail = (AppStoreSearch *)self;
  if(!detail.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:detail selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    detail.hasToggleNotifier = YES;
  }
  [detail toggleCarbon];
}
%new
- (void)toggleCarbon {
  AppStoreSearch *search = (AppStoreSearch *)self;
  search.layer.compositingFilter = nil;
  search.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook PKPassGroupsViewController
- (void)viewDidLayoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self.view setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self.view setCarbonEnabled:enabled];
  ((UIView *)[self valueForKey:@"_footerBackground"]).hidden = enabled;
}
%end

%hook PKWelcomeView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  ((UIImageView *)[self valueForKey:@"_backgroundView"]).hidden = enabled;
}
%end

%hook PXRoundedCornerOverlayView
-(UIColor *)overlaycolor {
  return enabled ? [UIColor blackColor] : %orig;
}
%end

%hook MusicReusableControlsView
-(void)layoutSubviews {
  %orig;
  MusicReusableControlsView *object = (MusicReusableControlsView *)self;
  object.accessibilityPlayButton.titleLabel.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
  object.accessibilityShuffleButton.titleLabel.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook MusicTransportButton
-(void)layoutSubviews {
  %orig;
  if(colorflow | !enabled) {
    return;
  }
  MusicTransportButton *button = (MusicTransportButton *)self;
  button.tintColor = [UIColor colorWithWhite:1 alpha:0.7];
}
-(void)setTintColor:(UIColor *)color {
  if(colorflow) {
    %orig(color);
    return;
  }
  %orig(enabled ? [UIColor colorWithWhite:1 alpha:0.7] : [UIColor colorWithWhite:0 alpha:0.5]);
}
%end

%hook MusicArtworkView
-(void)layoutSubviews {
  %orig;
  MusicArtworkView *artworkView = (MusicArtworkView *)self;
  if(enabled)
  artworkView.layer.cornerRadius = 4;
}
%end

%hook _TtCC5Music23PaletteTabBarController23PaletteVisualEffectView
-(void)layoutSubviews {
  %orig;
  for(UIVisualEffectView *effect in self.subviews) {
    if([effect isKindOfClass:[UIVisualEffectView class]]) {
      effect.effect = [UIBlurEffect effectWithStyle:enabled ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
    }
  }
}
%end

%hook _TtCC5Music30PlaylistDetailHeaderLockupViewP33_478656266B9A46DBA1F9B06CD023FE0712TitleTextView
-(void)setBackgroundColor:(id)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
-(id)backgroundColor {
  return enabled ? [UIColor clearColor] : %orig;
}
%end

%hook MusicPlayerViewController
-(void)viewDidLayoutSubviews {
  %orig;
  MusicPlayerViewController *miniPlayer = (MusicPlayerViewController *)self;
  for(UIVisualEffectView *effect in miniPlayer.view.subviews) {
    if([effect isKindOfClass:[UIVisualEffectView class]]) {
      effect.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
    }
  }
}
%end

%hook _TtCV5Music4Text9StackView
-(void)layoutSubviews {
  %orig;
  if(!enabled) {
    return;
  }
  if([NSStringFromClass([self.superview.superview class]) rangeOfString:@"Album"].location != NSNotFound || [NSStringFromClass([self.superview.superview.superview.superview class]) rangeOfString:@"Playlist"].location != NSNotFound || [NSStringFromClass([self.superview.superview.superview.superview class]) rangeOfString:@"SearchResult"].location != NSNotFound || [NSStringFromClass([self.superview.superview.superview.superview class]) rangeOfString:@"Person"].location != NSNotFound || [NSStringFromClass([self.superview.superview.superview.superview class]) rangeOfString:@"Song"].location != NSNotFound) {
    self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
  }
}
%end

%hook _TtCVV5Music4Text7Drawing4View
-(void)layoutSubviews {
  %orig;
  if(!enabled) {
    return;
  }
  if([NSStringFromClass([self.superview.superview class]) rangeOfString:@"Composite"].location != NSNotFound) {
    self.layer.filters = [NSArray arrayWithObjects:filter, nil];
  }
}
%end

%hook _MPUMarqueeContentView
-(void)layoutSubviews {
  %orig;
  for(UIView *subview in self.subviews) {
    subview.layer.filters = nil;
    subview.layer.contentsMultiplyColor = nil;
  }
}
%end

%hook MiniPlayerViewController
-(void)viewDidLayoutSubviews {
  %orig;
  MiniPlayerViewController *miniPlayer = (MiniPlayerViewController *)self;
  miniPlayer.nowPlayingItemTitleLabel.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)viewDidAppear:(BOOL)arg1 {
  %orig;
  MiniPlayerViewController *miniPlayer = (MiniPlayerViewController *)self;
  miniPlayer.nowPlayingItemTitleLabel.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook _TtCC5Music24NowPlayingViewController14CollectionView
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor clearColor] : color);
}
-(UIColor *)backgroundColor {
  return enabled ? [UIColor clearColor] : %orig;
}
%end

%hook PHHandsetDialerDeleteButton
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;  
}
%end

%hook TPNumberPadButton
+(id)imageForCharacter:(unsigned)arg1 highlighted:(BOOL)arg2 whiteVersion:(BOOL)arg3 {
  return %orig(arg1, arg2, enabled ? YES : arg3);
}
%end

%hook AppStoreGradient
%property (nonatomic, retain) UIView *colorSquare;
- (void)layoutSubviews {
  %orig;
  AppStoreGradient *gradient = (AppStoreGradient *)self;

  if(!gradient.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    gradient.hasToggleNotifier = YES;
  }

  if(!gradient.colorSquare) {
    gradient.colorSquare = [[UIView alloc] init];
    gradient.colorSquare.frame = gradient.bounds;
    [gradient addSubview:gradient.colorSquare];
    gradient.colorSquare.backgroundColor = [UIColor blackColor];
  }

  [gradient sendSubviewToBack:gradient.colorSquare];
  gradient.colorSquare.userInteractionEnabled = FALSE;

  [gradient toggleCarbon];
}
%new
- (void)toggleCarbon {
  AppStoreGradient *gradient = (AppStoreGradient *)self;  
  gradient.colorSquare.backgroundColor = [UIColor colorWithWhite:enabled ? 0.0 : 1.0 alpha:1];
  gradient.layer.filters = nil;
  for(CAGradientLayer *sublayer in gradient.layer.sublayers) {
    if([sublayer isKindOfClass:NSClassFromString(@"CAGradientLayer")]) {
      sublayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    }
  }
  if(class_getProperty([gradient class], "fadeLayer")) {
    gradient.fadeLayer.colors = enabled ? [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:oledMode ? 0.0 : 0.1 alpha:0] CGColor], (id)[[UIColor blackColor] CGColor], nil] : [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:0] CGColor], (id)[[UIColor colorWithWhite:1 alpha:1] CGColor], nil];
  }
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook AppProductReview
- (void)layoutSubviews {
  %orig;
  AppProductReview *gradient = (AppProductReview *)self;
  if(!gradient.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    gradient.hasToggleNotifier = YES;
  }
  [gradient toggleCarbon];
}
%new
- (void)toggleCarbon {
  AppProductReview *gradient = (AppProductReview *)self;    
  gradient.backgroundView.backgroundColor = [UIColor colorWithWhite:enabled ? 0.0 : 1.0 alpha:1];
  gradient.contentView.backgroundColor = [UIColor colorWithWhite:enabled ? 0.0 : 1.0 alpha:1];
  gradient.contentView.layer.filters = nil;
  gradient.contentView.layer.contentsMultiplyColor = nil;
  if(class_getProperty([gradient class], "ratingView")) {
    gradient.ratingView.backgroundColor = [UIColor colorWithWhite:enabled ? 0.0 : 1.0 alpha:1];
  }
}
%end

%hook CNContactHeaderDisplayView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook CNContactHeaderEditView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook _TVOrganizerView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook CNContactViewController
-(void)viewDidLayoutSubviews{
  %orig;
  self.view.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook CNContactContentViewController
- (void)viewDidLayoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.displayHeaderOverflowView.hidden = enabled;
  self.actionsWrapperView.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook FRCollectionBackgroundReusableView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.hidden = enabled;
}
%end

%hook FRSearchResultsSectionHeaderView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundView.hidden = enabled;
}
%end

%hook FRAsyncTextLabel
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook PSBulletedPINView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook PLWallpaperButton
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
  self.backdropView.hidden = enabled;
}
%end

%hook MKBasicMapView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
  self.backgroundColor = [UIColor clearColor];
}
%end

%hook PUPhotosSectionHeaderView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  ((UIView *)[self valueForKey:@"_backdropView"]).alpha = enabled ? 0.0 : 1.0;
  [[self valueForKey:@"_backdropView"] setHidden:enabled];
}
%end

%hook SKUITextBoxView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook SKUIAttributedStringView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end

%hook SKUITabBarBackgroundView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
  [self setCarbonEnabled:enabled];
  ((UIView *)[self valueForKey:@"_backdropView"]).hidden = enabled;
}
%end

%hook CKTextComponentView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook CKTranscriptCollectionView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook RemindersScrollingBackgroundView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook RemindersCheckboxView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook RemindersCheckboxCell
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end


%hook WFTextTokenEditorView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor blackColor] : color);
}
%end

%hook WFModuleView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor blackColor] : color);
}
%end

%hook PUPhotosSharingSelectionView
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook MFMessageHeaderMessageInfoBlock 
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook MFExpandableCaptionView 
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook MFConversationItemHeaderBlock 
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook MailboxContentViewCell
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
  [self forceSummaryUpdate];
}
%end

%hook MFComposeTextContentView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.textColor = enabled ? [UIColor whiteColor] : [UIColor blackColor];
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor blackColor] : color);
}
%end

%hook RemindersTitleTextView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.textColor = enabled ? [UIColor whiteColor] : [UIColor blackColor];
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
-(void)setTextColor:(UIColor *)color {
  %orig(enabled ? [UIColor whiteColor] : color);
}
-(UIColor *)textColor {
  return enabled ? [UIColor whiteColor] : %orig;
}
-(void)setText:(id)text {
  %orig(text);
  [self toggleCarbon];
}
-(void)_observeScrollViewDidScroll:(id)scrollView {
  %orig(scrollView);
  [self toggleCarbon];
}
%end

%hook BrowserRootViewController
- (void)viewDidLayoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  BrowserToolbar *toolbar = [self valueForKey:@"_bottomToolbar"];
  BrowserController *controller = [self valueForKey:@"_browserController"];
  if(![controller isPrivateBrowsingEnabled]) {
    toolbar.tintColor = [UIColor colorWithRed:0 green:0.39 blue:1 alpha:1.0];
    [toolbar setTintStyle:enabled ? 1 : 0];
  } else {
    toolbar.tintColor = [UIColor whiteColor];
    [toolbar setTintStyle:1];
  }
}
%end

%hook NavigationBar
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setTintStyle:enabled ? 1 : 0];
}
%end

%hook TabThumbnailHeaderView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor clearColor];
}
%end

%hook TiltedTabThumbnailView
- (void)layoutSubviews {
  %orig;
  self.layer.cornerRadius = 8;
  self.clipsToBounds = TRUE;
}
%end

%hook NotesTextureBackgroundView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.textureView.hidden = enabled;
  self.textureView.alpha = enabled ? 0 : 1;
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor clearColor];
}
%end

%hook ICTextView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
-(void)setBackgroundColor:(UIColor *)color {
  return;
}
-(UIColor *)backgroundColor {
  return nil;
}
%end

%hook ICNotesListTableViewCellWithImageView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor colorWithWhite:oledMode ? 0.0 : 0.1 alpha:1] : [UIColor clearColor];
}
-(void)setBackgroundColor:(UIColor *)color {
  %orig(enabled ? [UIColor colorWithWhite:oledMode ? 0.0 : 0.1 alpha:1] : color);
}
%end

%hook ICSearchResultsHeaderView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundView.backgroundColor = [UIColor clearColor];
}
%end

%hook RemindersCreationFooterView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook RemindersListHeaderView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook RemindersCardBackgroundView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  ((CALayer *)[self valueForKey:@"_cardBottomLayer"]).hidden = enabled;
  ((CALayer *)[self valueForKey:@"_cardMiddleLayer"]).hidden = enabled;
  ((CALayer *)[self valueForKey:@"_cardTopLayer"]).hidden = enabled;
  self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook _UIDimmingKnockoutBackdropView
-(void)layoutSubviews {
  %orig;
  ((UIVisualEffectView *)[self valueForKey:@"backdropView"]).effect = [UIBlurEffect effectWithStyle:enabled ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
}
%end

%hook UIActionSheetiOSDismissActionView
-(void)layoutSubviews {
  %orig;
  self.dismissButton.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook RemindersTableHeaderView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
   self.backgroundColor = enabled ? [UIColor blackColor] : [UIColor whiteColor];
}
%end

%hook PRXBubbleBackgroundView
- (void)layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
%new
- (void)toggleCarbon {
  [self setCarbonBackgroundColor:[UIColor colorWithWhite:oledMode ? 0.0 : 0.1 alpha:1.0]];
  [self setCarbonEnabled:enabled];
}
%end

%hook _CellStaticView
-(void)layoutSubviews {
  %orig;
  self.layer.filters = enabled ? [NSArray arrayWithObjects:filter, nil] : nil;
}
%end
%end

%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
  %orig(enabled && keyboard ? NO : light);
}
%end

%group NotNotes
%hook UITextView
%property (nonatomic, retain) UIColor *carbonTextColor;
%property (nonatomic, retain) UIColor *normalTextColor;
-(void) layoutSubviews {
  %orig;
  if(!self.hasToggleNotifier) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCarbon) name:@"com.oxidelabs.carbon.update" object:nil];
    self.hasToggleNotifier = YES;
  }
  [self toggleCarbon];
}
- (void)setTextColor:(UIColor *)color {
  if(!self.normalTextColor)
    self.normalTextColor = color;

  color = enabled ? [UIColor whiteColor] : color;
  %orig;
}
-(void)toggleCarbon {
  self.textColor = enabled ? [UIColor whiteColor] : self.normalTextColor;
}
-(void)setBackgroundColor:(id)color {
  %orig(enabled ? [UIColor whiteColor] : color);
}
-(id)backgroundColor {
  return enabled ? [UIColor clearColor] : %orig;
}
%end
%end

%hook UIApplication
-(id)init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDarkMode) name:UIApplicationDidBecomeActiveNotification object:nil];
    return %orig;
}
%new
-(void)checkDarkMode {
  NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH]?:[NSDictionary dictionary] copy];
  enabled = (BOOL)[[settings objectForKey:@"enabled"]?:@TRUE boolValue];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"com.oxidelabs.carbon.update" object:nil];
}
%end

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

// Credits to iPhoneDevWiki PreferenceBundles -> Loading Preferences
static void updatePrefs() {
  CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.oxidelabs.carbon"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if(keyList) {
    prefs = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.oxidelabs.carbon"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
    if(!prefs) prefs = [NSMutableDictionary new];
      CFRelease(keyList);
  }
  if(!prefs) {
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
  }

  enabled = [([prefs objectForKey:@"enabled"] ?: @(YES)) boolValue];
  
  enableCSS = [([prefs objectForKey:@"enableCSS"] ?: @(YES)) boolValue];
  keyboard = [([prefs objectForKey:@"keyboard"] ?: @(YES)) boolValue];
  oledMode = [([prefs objectForKey:@"oledMode"] ?: @(NO)) boolValue];
  separators = [([prefs objectForKey:@"separators"] ?: @(NO)) boolValue];

  filter = [NSClassFromString(@"CAFilter") filterWithType:@"colorInvert"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"com.oxidelabs.carbon.update" object:nil];
}

%ctor {
  updatePrefs();

  prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
  colorflow = [[NSFileManager defaultManager] fileExistsAtPath:colorFlowFile];

  BOOL shouldLoadApplicationHooks = NO;
  BOOL shouldLoadNotNotesHooks = NO;
    
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) updatePrefs, CFSTR("com.oxidelabs.carbon.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setCarbonEnabled, CFSTR("com.oxidelabs.carbon.enabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setCarbonDisabled, CFSTR("com.oxidelabs.carbon.disabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
     
  if(![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
    if([SparkAppList doesIdentifier:@"com.oxidelabs.carbon.applications" andKey:@"Enabled Apps" containBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]]) {
      shouldLoadApplicationHooks = YES;
      shouldLoadNotNotesHooks = YES;
    }
  }
  if([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobilenotes"]) {
    shouldLoadNotNotesHooks = NO;
  }
  if(shouldLoadApplicationHooks) {
    if([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobilecal"]) {
      %init(Calendar);
    }
    %init(Applications, MusicReusableControlsView = objc_getClass("Music.PlayIntentControlsReusableView"), MusicPlayerViewController = objc_getClass("Music.NowPlayingViewController"), MiniPlayerViewController = objc_getClass("Music.MiniPlayerViewController"), AppStoreSearchCell = objc_getClass("AppStore.SearchActionButton"), AppStoreExpand = objc_getClass("AppStore.ExpandableTextView"), AppStoreDetail = objc_getClass("AppStore.DetailCollectionViewCell"), AppStoreSearch = objc_getClass("AppStore.SearchBar"), AppProductReview = objc_getClass("AppStore.ProductReviewCollectionViewCell"), AppStoreGradient = objc_getClass("AppStore.FadeInDynamicTypeButton"), AppStoreOfferButton = objc_getClass("AppStore.OfferButton"), MusicTransportButton = objc_getClass("Music.NowPlayingTransportButton"), MusicArtworkView = objc_getClass("Music.ArtworkComponentImageView"));
  }
  if(shouldLoadNotNotesHooks) {
    %init(NotNotes);
  }
  %init;
}
