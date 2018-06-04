using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class test_01 : MonoBehaviour
{
    string[] a = new string[] { "1", "2", "2", "3", "4", "5" };
    string[] b = new string[] { "2", "4", "1", "3", "4" };

	// Use this for initialization
	void Start ()
    {
        HashSet<string> aa = new HashSet<string> ( a );

        
        var listA = new List<string> ( aa );
        var listB = new List<string> ( b );

        var target = listA.FindAll ( p => listB.Contains ( p ));
        if( target.Count > 0)
        for (int i = 0; i < target.Count; i++)
        {
                Debug.Log ( target[i] );
        }

        foreach (var item in listB) 
        {
            if (item == "4")
                //listB.Remove(item);
                RemoveItem(item, listB);
        }
        Debug.Log("————————");

        for (int i = 0; i < listB.Count; i++)
        {
            Debug.Log(listB[i]);
        }
        //NetworkTransform
		//TestAlgorithm ();
	}
	

    IEnumerator RemoveItem(string item , List<string> _list)
    {
        _list.Remove(item);
        yield return null;
    }
	// Update is called once per frame
	void Update () {
		
	}

//	void TestAlgorithm()
//	{
//		char killer;
//		for (killer = 'A'; killer <= 'D'; killer++) 
//		{
//			if ((killer != 'A') + (killer == 'C') + (killer == 'D') + (killer != 'D') == 3)
//				Debug.Log (killer);
//		}
//
//	}

}
