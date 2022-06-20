using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EnvironmentManager : MonoBehaviour
{
    public Text HudClock;

    private float minToSecond = 1f;
    private int currentMin;
    private const int MinInDay = 60 * 24;
    private float timeSinceLastMin;
    private int dayOfWeek = 0;

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
    }

    void Update()
    {
        if (timeSinceLastMin >= minToSecond)
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
            actor.Act(currentMin);
        }

        ++currentMin;
        if (currentMin >= MinInDay)
        {
            currentMin = 0;
            dayOfWeek++;
            if (dayOfWeek > 6)
            {
                dayOfWeek = 0;
            }
        }

        int min = currentMin % 60;
        int hrs = currentMin / 60;
        HudClock.text = $"{Enum.GetName(typeof(DayOfWeek), dayOfWeek)} {hrs:D2}:{min:D2}";
    }
}
