#include "LocationTracker.h"

extern "C" {
    void SetUnityCallback_LT(const char* gameObject, const char* methodSetStatus, const char* methodLocationUpdate) {
        [[LocationTracker I] setUnityCallback:
         [NSString stringWithCString:gameObject encoding:NSUTF8StringEncoding]:
         [NSString stringWithCString:methodSetStatus encoding:NSUTF8StringEncoding]:
         [NSString stringWithCString:methodLocationUpdate encoding:NSUTF8StringEncoding]
         ];
    }
    
    void StartTracking(float minDistance) {
        [[LocationTracker I] startTracking: minDistance];
    }
    
    void StopTracking() {
        [[LocationTracker I] stopTracking];
    }
    
    // char* GetHistoryFilePath() {
    //     return [[LocationTracker I] getHistoryFilePath];
    // }
    
    // void ToggleBackgroundMode(bool inBackground) {
    //     [[LocationTracker I] setBackgroundUpdateMode: inBackground];
    // }
    
    //debugging
    // void ReqAlwaysPermission() {
    //     [[LocationTracker I] reqAlwaysPermission];
    // }
}
