using System;
using UnityEngine;
using UnityEngine.UI;

public class Employee : IActor
{
    private GameObject guiListItem;

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

    public EmployeeStatus Status
    {
        get;
        private set;
    }

    public Employee(GameObject guiListItem)
    {
        Id = Guid.NewGuid();
        Name = NameGenerator.Generate();
        this.guiListItem = guiListItem;
        guiListItem.transform.Find("Name").GetComponent<Text>().text = Name;
        SetStatus(EmployeeStatus.OffWork);
    }

    public void Act(DateTime currentTime)
    {
        Debug.Log($"{currentTime:yyyy-MM-dd HH:mm}: {this.Name} ({this.Id})");

        switch (Status)
        {
            case EmployeeStatus.AtWork:
                AtWorkActivity(currentTime);
                break;
            case EmployeeStatus.OffWork:
                OffWorkActivity(currentTime);
                break;
            default:
                throw new NotImplementedException("Employee status invalid.");
        }
    }

    public bool Active()
    {
        return Status == EmployeeStatus.AtWork;
    }

    private void OffWorkActivity(DateTime currentTime)
    {
        if (currentTime.DayOfWeek == DayOfWeek.Saturday ||
            currentTime.DayOfWeek == DayOfWeek.Sunday)
        {
            // It's the weekend.
        }
        else
        {
            // It's a weekday.
            // Go to work at 8 AM.
            if (currentTime.Hour >= 8 && currentTime.Hour < 17)
            {
                SetStatus(EmployeeStatus.AtWork);
            }
        }
    }

    private void AtWorkActivity(DateTime currentTime)
    {
        // 5 PM is quittin' time.
        if (currentTime.Hour >= 17)
        {
            SetStatus(EmployeeStatus.OffWork);
        }
    }

    private void SetStatus(EmployeeStatus status)
    {
        this.Status = status;
        guiListItem.transform.Find("Status").GetComponent<Text>().text = Status.ToString();
    }
}
