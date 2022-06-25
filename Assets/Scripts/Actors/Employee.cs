using System;
using UnityEngine;
using UnityEngine.UI;

public class Employee : IActor
{
    private GameObject guiListItem;
    private GameObject avatar;

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

        Id = Guid.NewGuid();
        Name = NameGenerator.Generate();
        this.guiListItem = guiListItem;
        guiListItem.transform.Find("Name").GetComponent<Text>().text = Name;
        guiListItem.transform.Find("AvatarColor").GetComponent<Image>().color = avatarColor;
        SetStatus(EmployeeStatus.OffWork);

        avatar = new GameObject(Name);
        var spawnLocation = GameObject.Find("EmployeeSpawn").transform.position;
        avatar.transform.position = new Vector2(spawnLocation.x, spawnLocation.y);
        avatar.transform.localScale = new Vector3(.2f, .2f, 1f);
        avatar.AddComponent<SpriteRenderer>();
        var avatarSpriteRenderer = avatar.GetComponent<SpriteRenderer>();
        avatarSpriteRenderer.sprite = Resources.Load<Sprite>("Circle");
        avatarSpriteRenderer.color = avatarColor;
    }

    public void Act(DateTime currentTime)
    {
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
