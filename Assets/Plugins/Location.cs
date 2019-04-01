#if UNITY_IOS
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class Location : MonoBehaviour {
    [DllImport("__Internal")]
	private static extern void RequestLocationWhenInUsePermission();

    [DllImport("__Internal")]
    private static extern void StartTracking(float minDistance);

    [DllImport("__Internal")]
    private static extern void StopTracking();

    [DllImport("__Internal")]
    private static extern void SetUnityCallback_LT(string gob, string statusCallback, string dataCallback);
    
    // clicking the button calls this method
    public void RequestWhenInUsePermission() {
        Debug.Log("RequestWhenInUsePermission");
		RequestLocationWhenInUsePermission();
    }

    // Start is called before the first frame update
    public void StartTrackingLocation() {
        SetUnityCallback_LT(this.name, "LocationTrackerCallback", "LocationTrackerCallback");
        StartTracking(1f);
    }

    public void StopTrackingLocation() {
        SetUnityCallback_LT(this.name, "LocationTrackerCallback", "LocationTrackerCallback");
        StartTracking(1f);
    }

    public void LocationTrackerCallback(string data) {
        Debug.Log(data);
    }
}
#endif