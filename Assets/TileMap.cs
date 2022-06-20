using System.Collections;
using System.Collections.Generic;
using Assets;
using UnityEngine;

public class TileMap : MonoBehaviour
{
    Vector2Int currentPosition = new Vector2Int(0,0);
    Dictionary<int, Dictionary<int, TileInfo>> tileLookup = new Dictionary<int, Dictionary<int, TileInfo>>();

    private TileInfo GetTileInfo(int x, int y)
    {
        return new TileInfo
        {
            TileType = TileType.Grass
        };
    }

    void Start()
    {
        // TODO: pull current camera/player location to initialize currentPosition...
    }

    void Update()
    {
        
    }
}
