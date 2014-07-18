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
animlength -> the animation length ( type int)
speed	   -> the rate at which tiles should animate ( type int)
reverse    -> Whether the animation should play backwards ( type bool > "true"/"false")
~~~~  
  
[A][B][C][D]  
Given the above tileset, the properties are applied to tile A. The length in this case is 4 ( A included ).  
Over time, depending on speed, A will change to B >  C > D and back to it's original graphic. B,C,and D do not animate.  
To do that read the following:  
  
[A][B][C]  
For the this given sequence we can do the following:  
A is the parent of the animation sequence. For this tile you set the 3 properties as described above.  
Tile B and C are child tiles to A. To animate these tiles with the right offset add a property **parent** to tile B and C.  
The value of this property must be the difference in offset to the parent. So for B the value is 1. For C the value is 2.  
 
Lastly add a property **animated** of value bool to your layer.  
  
Note:  
The tiles must be placed in sequence on your tileset as the animation depends on the length and index position. I might consider a more dynamic approach.  
Currently it only works for Gridmaps and not Slopedmaps.
  
Only Horizontal sequences supported for now.

### Thanks to ###

[Matt Tuttle](https://github.com/MattTuttle) for writing the original