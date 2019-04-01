#if UNITY_IOS

using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

public static class XcodePostBuild {
    private const string DEFAULT_UNITY_IPHONE_PROJECT = "Unity-iPhone";
    private const string DEFAULT_UNITY_IPHONE_PROJECT_FILE = DEFAULT_UNITY_IPHONE_PROJECT + ".xcodeproj";

    private static string pathToBuiltProject;

    [PostProcessBuild]
    public static void OnPostBuild(BuildTarget target, string pathToBuiltProject) {

        if (target != BuildTarget.iOS) {
            return;
        }
        XcodePostBuild.pathToBuiltProject = pathToBuiltProject;

        ConfigureXcodeProject(GetPbx());
    }

    private static void ConfigureXcodeProject(PBXProject pbx) {
        try {

            var target = pbx.TargetGuidByName(DEFAULT_UNITY_IPHONE_PROJECT);

            // build settings for swift code
            pbx.SetBuildProperty(target, "SWIFT_VERSION", "4.2");
            pbx.SetBuildProperty(target, "SWIFT_OBJC_BRIDGING_HEADER", "$(SRCROOT)/Libraries/Plugins/iOS/Bridging-Header.h");
            pbx.SetBuildProperty(target, "SWIFT_OBJC_INTERFACE_HEADER_NAME", "SwiftInObjcBridge.h");
            pbx.AddBuildProperty(target, "LD_RUNPATH_SEARCH_PATHS", "@executable_path/Frameworks");

            UpdateInfoPList();

            pbx.WriteToFile(pbxPath);

        } catch (UnauthorizedAccessException e) {
            Debug.LogError("Failed to configure xcode project: " + e);
        }
    }

    private static void UpdateInfoPList() {
        // Get plist
        string plistPath = pathToBuiltProject + "/Info.plist";
        PlistDocument plist = new PlistDocument();
        plist.ReadFromString(File.ReadAllText(plistPath));
   
        // Get root
        PlistElementDict plistDict = plist.root;
   
        var dict = new Dictionary<string, string> {
            {"NSLocationWhenInUseUsageDescription", "when in use"},
            {"NSLocationAlwaysAndWhenInUseUsageDescription", "always and when in use"},
        };

        foreach (var elem in dict) {
            plistDict.SetString(elem.Key, elem.Value);
        }
   
        // Write to file
        File.WriteAllText(plistPath, plist.WriteToString());
    }

    private static PBXProject GetPbx() {
        var pbx = new PBXProject();
        pbx.ReadFromFile(pbxPath);

        return pbx;
    }
    private static string pbxPath {
        get {
            return Path.Combine(pathToBuiltProject, DEFAULT_UNITY_IPHONE_PROJECT_FILE, "project.pbxproj");
        }
    }
}

#endif
