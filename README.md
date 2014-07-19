### Khapunk Tiled ###

Port of [Haxepunk Tiled](https://github.com/HaxePunk/tiled)

Allows you to load TMX files in Khapunk with ease.

### How do I get started? ###

Add your tmx file as blob and your tile file as image. Add both files to your room.

Once Kha has loaded your data:


```
#!haxe
 
 var s:Scene = new Scene(); // our punk scene
 var tmxEntity:TmxEntity = new TmxEntity("myLevel"); //Kha strips extentions names
 tmxEntity.loadGraphic("myImage", ["layer","layer2"]); // layers to render
 tmxEntity.loadMask("collision", "solid"); // Collision to set

 s.add(tmxEntity);
		
```

In this case 2 layers are rendered for one entity. If you need maps simply create a new tmxEntity and pass the map property from your existing tmxEntity.:

### Access properties and objects ###


```
#!haxe

public function createMap()
{
    // create the map
    var map = TmxMap.loadFromFile("mylevel");

    // access map properties
    var prop = map.properties.resolve("myCustomProperties");

    // go through the list of objects in an object layer
    for(object in map.getObjectGroup("myObjectsLayer").objects)
    {
        // you can access:
        object.name; 
        object.type;

        object.x;
        object.y;

        object.width;
        object.height;

        // to read custom properties
        object.custom.resolve("myProp");
    }

    // create the map
    var e = new TmxEntity(map);

    // load layers named bottom, main, top with the appropriate tileset
    e.loadGraphic("tileset", ["bottom", "main", "top"]);

    // loads a grid layer named collision and sets the entity type to walls
    e.loadMask("collision", "walls");

    add(e);
}
```

### Animated tiles ###

If you want to animate certain tiles add the following properties to a tile:
	
~~~~
GiD properties:
animlength  -> the animation length ( type int)
speed	    -> the rate at which tiles should animate ( type int )
reverse     -> (optional)Whether the animation should play backwards ( type bool )
vertical    -> (optional)Whether the animation is set in vertical order on the tileset ( type bool )
animchildren-> (optional)Whether the tiles part of the sequence should animate too ( type bool )
~~~~  
  
~~~~
Layer properties:
local    -> Whether the tile animations should be managed by the entity update instead of 
			the global tile animation manager. The entity will not share its animation
			with global animation manager.
~~~~    
  
[A][B][C][D]  
Given the above tileset, the properties are applied to tile A. The length in this case is 4 ( A included ).  
Over time, depending on speed, A will change to B >  C > D and back to it's original graphic. B,C,and D do not animate unless animchildren is set.  
  
Note:  
The tiles must be placed in sequence on your tileset as the animation depends on the length and index position. I might consider a more dynamic approach.  
Currently it only works for Gridmaps and not Slopedmaps.

### Thanks to ###

[Matt Tuttle](https://github.com/MattTuttle) for writing the original