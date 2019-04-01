using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeScene : MonoBehaviour {
    
    void Start() {
		SceneManager.LoadScene("Main");
    }

    void Update() {
    	if (Time.time > 3f) SceneManager.SetActiveScene(SceneManager.GetSceneByName("Main"));
    }

}
