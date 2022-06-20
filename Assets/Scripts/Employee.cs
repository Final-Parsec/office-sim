using System;
using UnityEngine;

public class Employee : IActor
{
    public Guid Id
    {
        get;
        private set;
    }

    public string Name
    {
        get;
        private set;
    }

    public Employee()
    {
        Id = Guid.NewGuid();
        Name = Id.ToString();
    }

    public void Act(int turn)
    {
        Debug.Log($"{turn}: {this.Name} ({this.Id})");
    }
}
