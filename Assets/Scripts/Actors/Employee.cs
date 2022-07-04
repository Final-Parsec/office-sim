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
        var collider = avatar.AddComponent<CircleCollider2D>();
        collider.radius = 1f;
        var rigidBody = avatar.AddComponent<Rigidbody2D>();
        rigidBody.bodyType = RigidbodyType2D.Kinematic;
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
                var spawnLocation = GameObject.Find("EmployeeSpawn").transform.position;
                avatar.transform.position = new Vector2(spawnLocation.x, spawnLocation.y);
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
        var myPosition = (Vector2)avatar.transform.position;
        var widgetPosition = (Vector2)workInProgressWidget.transform.position;
        var distanceToWidget = Vector2.Distance(myPosition, widgetPosition);
        if (distanceToWidget < .75f)
        {
            MoveToward moveToward;
            if (avatar.TryGetComponent<MoveToward>(out moveToward))
            {
                GameObject.Destroy(moveToward);
            }

            var wipWidgetSpriteRenderer = workInProgressWidget.GetComponent<SpriteRenderer>();
            var currentColor = wipWidgetSpriteRenderer.color;
            if (currentColor.r <= .01f && currentColor.g <= .01f && currentColor.b <= .01f)
            {
                workInProgressWidget = null;
                SetStatus(EmployeeStatus.WorkingPlanning);
            }
            else
            {
                currentColor.r -= .01f;
                currentColor.g -= .01f;
                currentColor.b -= .01f;
                wipWidgetSpriteRenderer.color = currentColor;
            }
        }
        else
        {
            var pathfinding = GameObject.Find("Pathfinding").GetComponent<Pathfinding>();
            var desiredPosition = workInProgressWidget.transform.position;
            var gridPosition = pathfinding.WorldToGrid(desiredPosition);
            if (gridPosition != null)
            {
                pathfinding.Nodes[gridPosition.X, gridPosition.Y].SetColor(Color.blue);

				if (gridPosition.X > 0 &&
                    gridPosition.Y > 0 &&
                    gridPosition.X < pathfinding.Width &&
                    gridPosition.Y < pathfinding.Height)
				{
					//Convert player point to grid coordinates
					var avatarPosition = pathfinding.WorldToGrid(avatar.transform.position);
                    if (avatarPosition == null)
                    {
                        Debug.Log($"No point for avatar {Name}.");
                    }
                    else
                    {
                        var nodeForAvatar = pathfinding.Nodes[avatarPosition.X, avatarPosition.Y];
                        if (nodeForAvatar == null)
                        {
                            Debug.Log($"No node for avatar {Name}.");
                        }
                        else
                        {
                            nodeForAvatar.SetColor(Color.blue);
                            //Find path from player to clicked position
                            BreadCrumb bc = PathFinder.FindPath(pathfinding, avatarPosition, gridPosition);

                            MoveToward moveToward;
                            if (!avatar.TryGetComponent<MoveToward>(out moveToward))
                            {
                                moveToward = avatar.AddComponent<MoveToward>();
                            }

                            moveToward.breadCrumb = bc;

                            int count = 0;
                            LineRenderer lr = GameObject.Find("EmployeeSpawn").GetComponent<LineRenderer>();
                            lr.SetVertexCount(100);  //Need a higher number than 2, or crashes out
                            lr.SetWidth(0.1f, 0.1f);
                            lr.SetColors(Color.yellow, Color.yellow);

                            //Draw out our path
                            while (bc != null)
                            {
                                lr.SetPosition(count, Pathfinding.GridToWorld(bc.position));
                                bc = bc.next;
                                count += 1;
                            }
                            lr.SetVertexCount(count);
                        }
                    }
                }
            }
            else
            {
                Debug.Log($"Widget is not accessible for {Name}. Recreating...");
                GameObject.Destroy(workInProgressWidget);
                workInProgressWidget = null;
                SetStatus(EmployeeStatus.WorkingPlanning);
            }
        }
    }

    private void SetStatus(EmployeeStatus status)
    {
        this.Status = status;
        avatar.SetActive(Active());
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
