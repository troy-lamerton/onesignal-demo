using UnityEngine;
using System.Collections.Generic;  

public class InitOneSignal : MonoBehaviour {

    public static string OS_APP_ID = "163bcfd6-4058-4a49-9101-67abe4ea3fe6";

    void Start () {
        Debug.Log("InitOneSignal mono behaviour Start() -->");

        OneSignal.SetLogLevel(OneSignal.LOG_LEVEL.VERBOSE, OneSignal.LOG_LEVEL.NONE);

        OneSignal.StartInit(OS_APP_ID)
            .HandleNotificationOpened(HandleNotificationOpened)
            .EndInit();

        OneSignal.SetLocationShared(false);

        OneSignal.inFocusDisplayType = OneSignal.OSInFocusDisplayOption.Notification;
        Debug.Log("<-- InitOneSignal mono behaviour Start() done.");
    }

    // Gets called when the player opens the notification.
    private static void HandleNotificationOpened(OSNotificationOpenedResult result) {
        Debug.Log("HandleNotificationOpened!");
    }

}
