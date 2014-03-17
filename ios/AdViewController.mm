#import "AdViewController.h"
#import "AdTransparentView.h"

#define BANNER_REFRESH_RATE 30

extern UIViewController* UnityGetGLViewController();
extern UIView* UnityGetGLView();

@implementation AdViewController

@synthesize bannerView;
@synthesize position;


static AdViewController *instance = nil;

+ (GADAdSize) determineAdSize{
    UIInterfaceOrientation  orientation = [UnityGetGLViewController() interfaceOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)){
        return kGADAdSizeSmartBannerPortrait;
    }
    else {
        return kGADAdSizeSmartBannerLandscape;
    }
}

+ (void) installAdMob:(NSString *)adMobID position:(int)position{
    if(instance != nil) return;
    
    // Init
    AdViewController *adViewController = [[AdViewController alloc] init];
    instance = adViewController;
    [instance addTestDeviceID:GAD_SIMULATOR_ID];
    
    // Unity View
    UIViewController *rootViewController = UnityGetGLViewController();
    UIView *rootView = UnityGetGLView();
    
    // Add Ad Base View
    adViewController.view = [[[AdTransparentView alloc] init] autorelease];
    adViewController.position = position;
    adViewController.view.frame = rootView.bounds;
    adViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [rootView addSubview:adViewController.view];
    
    // Init Admob
    GADAdSize adSize = [AdViewController determineAdSize];
    CGPoint origin = CGPointMake(0, 0);
    switch (position) {
    case AdPositionBottom:
            origin = CGPointMake(0, adViewController.view.frame.size.height - CGSizeFromGADAdSize(adSize).height);
            break;
    }
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:adSize origin:origin];
    bannerView.adUnitID = adMobID;
    bannerView.rootViewController = rootViewController;
    bannerView.delegate = adViewController;
   
    // Add AdView
    adViewController.bannerView = bannerView;
    [adViewController.view addSubview:bannerView];
    
    NSLog(@"Install AdMob");
}

- (id)init {
	self = [super init];
	if (self != nil) {
        testDeviceIDs = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) addTestDeviceID:(NSString *) testDeviceID{
    [testDeviceIDs addObject:testDeviceID];
}

- (void) showAd{
    self.bannerView.hidden = NO;
    self.view.hidden = NO;
}

- (void) hideAd{
    self.bannerView.hidden = YES;
    self.view.hidden = YES;
}

- (void)refreshBanner {
    GADRequest *request = [GADRequest request];
    request.testDevices = testDeviceIDs;

    [self.bannerView loadRequest:request];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%@", error);
//    [NSTimer scheduledTimerWithTimeInterval:BANNER_REFRESH_RATE target:self selector:@selector(refreshBanner) userInfo:nil repeats:NO];
}

- (void)dealloc {
    self.view = nil;
    self.bannerView.delegate = nil;
    [self.bannerView release];
    [testDeviceIDs release];
    instance = nil;
    [super dealloc];
}

@end

extern "C" {
    void installAdMobIOS_(char *adMobID, int position);
    void addTestDeviceIDIOS_(char *deviceID);
    void hideAdIOS_();
    void showAdIOS_();
    void refreshAdIOS_();
    void releaseAdMobIOS_();
    bool isIpadAdMob_();
}

void installAdMobIOS_(char *adMobID, int position){
    [AdViewController installAdMob:
     [NSString stringWithCString:adMobID encoding:NSASCIIStringEncoding]
                          position: position];
}

void addTestDeviceIDIOS_(char *deviceID){
    if(instance != nil){
        [instance addTestDeviceID:[NSString stringWithCString:deviceID encoding:NSASCIIStringEncoding]];
    }
}

void hideAdIOS_(){
    if(instance != nil){
        [instance hideAd];
    }
}

void showAdIOS_(){
    if(instance != nil){
        [instance showAd];
    }
}

void refreshAdIOS_(){
    if(instance != nil){
        [instance refreshBanner];
    }
}

void releaseAdMobIOS_(){
    if(instance != nil){
        [instance release];
    }
}

bool isIpadAdMob_(){
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return false;
	}else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return true;
	}
    return false;
}
