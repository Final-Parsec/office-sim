using System;
using UnityEngine;
using UnityEngine.UI;

public class Employee : IActor
{
    private const int WORK_START_TIME = 8;
    private const int WORK_QUIT_TIME = 17;

    private GameObject guiListItem;
    private GameObject avatar;
    private GameObject workInProgressWidget;

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
        var avatarColor = UnityEngine.Random.ColorHSV(0f, 1f, 1f, 1f, 0.5f, 1f);
        Name = NameGenerator.Generate();
        avatar = new GameObject(Name);

        Id = Guid.NewGuid();
        this.guiListItem = guiListItem;
        guiListItem.transform.Find("Name").GetComponent<Text>().text = Name;
        guiListItem.transform.Find("AvatarColor").GetComponent<Image>().color = avatarColor;
        SetStatus(EmployeeStatus.OffWork);

        var spawnLocation = GameObject.Find("EmployeeSpawn").transform.position;
        avatar.transform.position = new Vector2(spawnLocation.x, spawnLocation.y);
        avatar.transform.localScale = new Vector3(.2f, .2f, 1f);
        avatar.AddComponent<SpriteRenderer>();
        var avatarSpriteRenderer = avatar.GetComponent<SpriteRenderer>();
        avatarSpriteRenderer.sprite = Resources.Load<Sprite>("Circle");
        avatarSpriteRenderer.color = avatarColor;
        avatar.AddComponent<CircleCollider2D>();
        var collider = avatar.GetComponent<CircleCollider2D>();
        collider.radius = 1f;
        avatar.AddComponent<Rigidbody2D>();
    }

    public void Act(DateTime currentTime)
    {
        switch (Status)
        {
            case EmployeeStatus.WorkingPlanning:
                WorkingActivity(currentTime);
                WorkPlanningActivity();
                break;
            case EmployeeStatus.OffWork:
                OffWorkActivity(currentTime);
                break;
            case EmployeeStatus.WorkingBuilding:
                WorkingActivity(currentTime);
                WorkBuildingActivity();
                break;
            default:
                throw new NotImplementedException("Employee status invalid.");
        }
    }

    public bool Active()
    {
        return Status == EmployeeStatus.WorkingPlanning ||
        Status == EmployeeStatus.WorkingBuilding;
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
            if (currentTime.Hour >= WORK_START_TIME && currentTime.Hour < WORK_QUIT_TIME)
            {
                SetStatus(EmployeeStatus.WorkingPlanning);
            }
        }
    }

    private void WorkingActivity(DateTime currentTime)
    {
        if (currentTime.Hour >= WORK_QUIT_TIME)
        {
            SetStatus(EmployeeStatus.OffWork);
            return;
        }
    }

    private void WorkPlanningActivity()
    {
        if (workInProgressWidget == null)
        {
            workInProgressWidget = new GameObject($"Widget WIP");
            workInProgressWidget.transform.position = (Vector2)avatar.transform.position + (Vector2)UnityEngine.Random.insideUnitCircle * 5;
            workInProgressWidget.transform.localScale = new Vector3(.2f, .2f, 1f);
            workInProgressWidget.AddComponent<CircleCollider2D>();
            var collider = workInProgressWidget.GetComponent<CircleCollider2D>();
            collider.radius = 1f;
            workInProgressWidget.AddComponent<Rigidbody2D>();
            workInProgressWidget.AddComponent<SpriteRenderer>();
            var wipWidgetSpriteRenderer = workInProgressWidget.GetComponent<SpriteRenderer>();
            wipWidgetSpriteRenderer.sprite = Resources.Load<Sprite>("Circle");
        }
        else
        {
            SetStatus(EmployeeStatus.WorkingBuilding);
        }
    }

    private void WorkBuildingActivity()
    {
        // am I close enough to build?
        var myPosition = (Vector2)avatar.transform.position;
        var widgetPosition = (Vector2)workInProgressWidget.transform.position;
        var distanceToWidget = Vector2.Distance(myPosition, widgetPosition);
        Debug.Log(distanceToWidget);
    }

    private void SetStatus(EmployeeStatus status)
    {
        avatar.SetActive(Active());

        this.Status = status;
        var statusText = status.ToString();
        if (status == EmployeeStatus.WorkingPlanning)
        {
            statusText = "Working - Planning";
        } else if (status == EmployeeStatus.OffWork)
        {
            statusText = "Off Work";
        }
        else if (status == EmployeeStatus.WorkingBuilding)
        {
            statusText = "Working - Building";
        }
        
        guiListItem.transform.Find("Status").GetComponent<Text>().text = Status.ToString();
    }
}
