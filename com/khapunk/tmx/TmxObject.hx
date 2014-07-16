package com.khapunk.tmx;
import com.khapunk.masks.Circle;
import com.khapunk.masks.Hitbox;
import com.khapunk.tmx.TmxObjectGroup;
import com.khapunk.masks.Hitbox;
import haxe.xml.Fast;



/**
 * ...
 * @author Sidar Talei
 */
class TmxObject
{
	public var group:TmxObjectGroup;
	public var name:String;
	public var type:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var gid:Int;
	public var custom:TmxPropertySet;
	public var shared:TmxPropertySet;
	public var shapeMask:Hitbox;


public function new(source:Fast, parent:TmxObjectGroup)
	{
		group = parent;
		name = (source.has.name) ? source.att.name : "[object]";
		type = (source.has.type) ? source.att.type : "";
		x = Std.parseInt(source.att.x);
		y = Std.parseInt(source.att.y);
		width = (source.has.width) ? Std.parseInt(source.att.width) : 0;
		height = (source.has.height) ? Std.parseInt(source.att.height) : 0;
		//resolve inheritence
		shared = null;
		gid = -1;
		if(source.has.gid && source.att.gid.length != 0) //object with tile association?
		{
			gid = Std.parseInt(source.att.gid);
			var set:TmxTileSet;
			for (set in group.map.tilesets)
			{
				shared = set.getPropertiesByGid(gid);
				if(shared != null)
					break;
			}
		}
		
		//load properties
		var node:Xml;
		custom = new TmxPropertySet();
		for (node in source.nodes.properties)
			custom.extend(node);

		// create shape, cannot do ellipses, only circles
		if(source.hasNode.ellipse){
			var radius = Std.int(((width < height)? width : height)/2);
			shapeMask = new com.khapunk.masks.Circle(radius, x, y);
		}else{ // rect
			shapeMask = new com.khapunk.masks.Hitbox(width, height, x, y);
		}
	}
}