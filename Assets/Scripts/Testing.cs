using UnityEngine;
using System.Collections.Generic;  

public class Testing : MonoBehaviour {

    public static string OS_APP_ID = "b5abbc64-855f-458f-a62b-06de0148b325";

    void Start () {
        // Enable line below to enable logging if you are having issues setting up OneSignal. (logLevel, visualLogLevel)
        // OneSignal.SetLogLevel(OneSignal.LOG_LEVEL.INFO, OneSignal.LOG_LEVEL.INFO);

        OneSignal.StartInit(OS_APP_ID)
            .HandleNotificationOpened(HandleNotificationOpened)
            .EndInit();

        OneSignal.inFocusDisplayType = OneSignal.OSInFocusDisplayOption.Notification;
    }

    // Gets called when the player opens the notification.
    private static void HandleNotificationOpened(OSNotificationOpenedResult result) {
        Debug.Log("HandleNotificationOpened!");
    }

}
