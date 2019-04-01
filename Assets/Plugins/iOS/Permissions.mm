// Same as build setting ->
// Objc generated interface header name
#include "SwiftInObjcBridge.h"

extern "C" {

    void RequestLocationWhenInUsePermission() {
        [[PermissionsPlugin I] requestPermission];
    }

}
