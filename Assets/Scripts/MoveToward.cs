using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveToward : MonoBehaviour
{
    public BreadCrumb breadCrumb;

    void FixedUpdate()
    {
        if (breadCrumb == null)
        {
            return;
        }

        var desiredPosition = Pathfinding.GridToWorld(breadCrumb.position);
        var distanceToPosition = Vector2.Distance(transform.position, desiredPosition);
        if (distanceToPosition <= .25f)
        {
            breadCrumb = breadCrumb.next;
        }
        else
        {
            transform.position = Vector2.MoveTowards(transform.position, desiredPosition, 1f * Time.deltaTime);
        }
    }
}
