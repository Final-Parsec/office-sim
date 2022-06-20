using System;

public interface IActor
{
    void Act(DateTime currentTime);

    bool Active();
}
