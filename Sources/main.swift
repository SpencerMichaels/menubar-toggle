import Foundation

let kAppVersion = "2.0.1"

let kPreferenceKey = "_HIHideMenuBar" as CFString
let kApplicationID = kCFPreferencesAnyApplication
let kUserName = kCFPreferencesCurrentUser
let kHostName = kCFPreferencesAnyHost

let kNotificationName = CFNotificationName("AppleInterfaceMenuBarHidingChangedNotification" as CFString)

let kHelpMessage =
    "Usage:\n" +
        "  menubar-toggle [--show | --auto | --current]\n\n" +
        "Options:\n" +
        "  -s, --show     Set the menu bar to show always.\n" +
        "  -a, --auto     Set the menu bar to auto-hide.\n" +
        "  -c, --current  Print the current menu bar mode.\n" +
        "  -h, --help     Print usage information.\n" +
        "  -v, --version  Print version number.\n\n" +
        "  If no arguments are provided, the mode will be toggled."

enum MenubarToggleError: Error {
    case couldNotReadPreference
}

// Get the current mode. Will throw MenubarToggleError.couldNotReadPreference
// if the preference does not exist.
func getAutoHideMode() throws -> Bool {
    CFPreferencesSynchronize(kApplicationID, kUserName, kHostName)
    
    let prefValue = CFPreferencesCopyValue(
        kPreferenceKey, kApplicationID,
        kUserName, kHostName)
    
    guard let autoHideMode = prefValue as? String else {
        throw MenubarToggleError.couldNotReadPreference
    }
    
    return (autoHideMode == "1")
}

// Set the current mode.
func setAutoHideMode(autoHide: Bool) {
    CFPreferencesSynchronize(kApplicationID, kUserName, kHostName)
    
    let prefValue = autoHide ? "1" : "0"
    CFPreferencesSetValue(kPreferenceKey, prefValue as CFPropertyList?,
                          kApplicationID, kUserName, kHostName)
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(),
                                         kNotificationName, nil, nil, true)
}

// Get the current mode. Will attempt to create the preference if it does not
// exist, setting it to "always show" by default.
func getAutoHideModeAndAutoCreate() throws -> Bool {
    do {
        return try getAutoHideMode()
    } catch MenubarToggleError.couldNotReadPreference {
        // Default to "always show"
        print("Could not read existing preference; will attempt to create it.")
        setAutoHideMode(autoHide: false)
    }
    
    return try getAutoHideMode()
}

// Attempt to get the preference, creating it with a default value if it does not already exist
guard let autoHide = try? getAutoHideModeAndAutoCreate() else {
    print("Fatal error: Preference does not exist, and a default value could not be written.")
    exit(1);
}

// Toggle if no arguments are given
if CommandLine.arguments.count <= 1 {
    setAutoHideMode(autoHide: !autoHide)
}
    // Show the version
else if (["--version", "-v"].contains(CommandLine.arguments[1])) {
    print(kAppVersion)
}
    // Always show the menu bar
else if (["-s", "--show"].contains(CommandLine.arguments[1])) {
    setAutoHideMode(autoHide: false)
}
    // Automatically hide the menu bar
else if (["-a", "--auto"].contains(CommandLine.arguments[1])) {
    setAutoHideMode(autoHide: true)
}
    // Show current mode
else if (["-c", "--current"].contains(CommandLine.arguments[1])) {
    print(autoHide ? "Auto-hide" : "Always show")
}
    // Show usage information
else {
    print(kHelpMessage)
}
