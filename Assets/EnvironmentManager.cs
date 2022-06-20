using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class EnvironmentManager : MonoBehaviour
{
    public Text HudClock;

    private const float minToSecond = 1f;

    private float timeSinceLastMin;
    private DateTime currentTime;

    private static EnvironmentManager instance;
    public static EnvironmentManager Instance
    {
        get { return instance; }
    }

    private List<IActor> actors;
    public List<IActor> Actors
    {
        get { return actors; }
    }
    
    void Start()
    {
        instance = this;
        actors = new List<IActor>();
        currentTime = new DateTime(1999, 2, 19);
    }

    void Update()
    {
        if (Actors.All(a => !a.Active()) ||
            timeSinceLastMin >= minToSecond)
        {
            timeSinceLastMin = 0f;
            MinutePassed();
        }
        else
        {
            timeSinceLastMin += Time.deltaTime;
        }
    }

    private void MinutePassed()
    {
        foreach (var actor in Actors)
        {
            actor.Act(currentTime);
        }

        currentTime = currentTime.AddMinutes(1);
        HudClock.text = $"{currentTime:yyyy-MM-dd HH:mm}";
    }
}
