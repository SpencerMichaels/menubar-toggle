@import Foundation;

int main()
{
    @autoreleasepool {
        NSArray *args = [[NSProcessInfo processInfo] arguments];
        NSString *mode = CFBridgingRelease(CFPreferencesCopyValue(
            (CFStringRef) @"_HIHideMenuBar", kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser, kCFPreferencesCurrentHost));

        if (args.count > 1) {
            if ([args[1] isEqualToString:@"--version"]) {
                puts("1.0");
                return 0;
            }

            else if ([args[1] isEqualToString:@"--help"]) {
                puts("Usage:\n"
                     "  menubar-toggle [--show | --hide | --current]\n\n"
                     "Options:\n"
                     "  --show     Set the menu bar to show always.\n"
                     "  --hide     Set the menu bar to auto-hide.\n"
                     "  --current  Print the current menu bar mode.\n\n"
                     "  If no arguments are provided, the mode will be toggled.");
                return 0;
            }

            else if ([args[1] isEqualToString:@"--show"]) {
                mode = @"0";
            }

            else if ([args[1] isEqualToString:@"--hide"]) {
                mode = @"1";
            }

            else if ([args[1] isEqualToString:@"--current"]) {
              printf("%s", [mode UTF8String]);
            }
        } else {
            // Default to toggling mode
            mode = [mode isEqualToString: @"0"] ? @"1" : @"0";
        }

        CFPreferencesSetValue(
            (CFStringRef) @"_HIHideMenuBar", (__bridge CFPropertyListRef)(mode),
            kCFPreferencesAnyApplication, kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost);

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDistributedCenter(),
            (CFStringRef) @"AppleInterfaceMenuBarHidingChangedNotification",
            NULL, NULL, YES);
    }

    return 0;
}
