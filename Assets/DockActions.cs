using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DockActions : MonoBehaviour
{
    public GameObject employeeListViewContent;
    public GameObject employeeListItemPrefab;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnHireClick()
    {
        var employee = new Employee();
        EnvironmentManager.Instance.Actors.Add(employee);
        var newHire = Instantiate(employeeListItemPrefab, employeeListViewContent.transform);
        newHire.GetComponentInChildren<Text>().text = employee.Name;
    }
}
