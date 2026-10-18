#import <UIKit/UIKit.h>

// Preferences file written by your settings UI (or edit manually on device).
static NSString *const kPrefsPath = @"/var/mobile/Library/Preferences/com.yourname.lockscreen.plist";

static BOOL enabled = YES;
static NSTimeInterval idleSeconds = 60;
static NSTimeInterval lastActivity = 0;

static void LSLoadPrefs(void) {
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    enabled = p[@"enabled"] ? [p[@"enabled"] boolValue] : YES;
    idleSeconds = p[@"idleSeconds"] ? [p[@"idleSeconds"] doubleValue] : 60;
    if (idleSeconds < 10) idleSeconds = 10;
}

static void LSResetActivity(void) {
    lastActivity = [[NSDate date] timeIntervalSince1970];
}

static void LSLockScreen(void) {
    Class mgrClass = NSClassFromString(@"SBLockScreenManager");
    if (!mgrClass) return;
    id mgr = [mgrClass respondsToSelector:@selector(sharedInstance)]
           ? [mgrClass performSelector:@selector(sharedInstance)] : nil;
    // Selector differs between iOS versions; try the known variants.
    SEL sels[] = {
        NSSelectorFromString(@"lockUIFromSource:withOptions:"),
        NSSelectorFromString(@"lockUIFromSource:")
    };
    for (int i = 0; i < 2; i++) {
        if (![mgr respondsToSelector:sels[i]]) continue;
        if (i == 0) {
            void (*fn)(id, SEL, int, id) = (void (*)(id, SEL, int, id))[mgr methodForSelector:sels[i]];
            fn(mgr, sels[i], 1, nil);
        } else {
            void (*fn)(id, SEL, int) = (void (*)(id, SEL, int))[mgr methodForSelector:sels[i]];
            fn(mgr, sels[i], 1);
        }
        return;
    }
}

%hook UIApplication
// Any touch on the device counts as activity.
- (void)sendEvent:(UIEvent *)event {
    LSResetActivity();
    %orig;
}
%end

%ctor {
    LSLoadPrefs();
    LSResetActivity();

    // Reload settings when the preferences file changes.
    [[NSNotificationCenter defaultCenter] addObserverForName:@"com.yourname.lockscreen/prefsChanged"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *n) {
        LSLoadPrefs();
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer *t) {
            if (!enabled) return;
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            if (now - lastActivity >= idleSeconds) {
                LSLockScreen();
                LSResetActivity();
            }
        }];
    });
}
