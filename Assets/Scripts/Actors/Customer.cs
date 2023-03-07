using System;
using UnityEngine;
using UnityEngine.UI;

public class Customer : IActor
{
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

    public Customer()
    {
        var avatarColor = UnityEngine.Random.ColorHSV(0f, 1f, 1f, 1f, 0.5f, 1f);
        Name = NameGenerator.Generate();
        avatar = new GameObject(Name);

        Id = Guid.NewGuid();

        var spawnLocation = GameObject.Find("CustomerSpawn").transform.position;
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
        
    }

    public bool Active()
    {
        return true;
    }
}
