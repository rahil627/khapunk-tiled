package com.khapunk.tmx;
import com.khapunk.Entity;
import com.khapunk.graphics.PunkImage;
import com.khapunk.graphics.Tilemap;
import com.khapunk.graphics.tilemap.TileAnimationManager;
import com.khapunk.masks.Grid;
import com.khapunk.masks.Masklist;
import com.khapunk.masks.SlopedGrid;
import com.khapunk.tmx.TmxMap.MapData;
import kha.Blob;
import kha.Loader;

/**
 * ...
 * @author Sidar Talei
 */

private abstract Map(TmxMap)
{
	private inline function new(map:TmxMap) this = map;
	@:to public inline function toMap():TmxMap return this;

	@:from public static inline function fromString(s:String) {
		var blob:Blob = Loader.the.getBlob(s);
		return new Map(new TmxMap(blob.toString()));
	}
	@:from public static inline function fromTmxMap(map:TmxMap)
		return new Map(map);

	@:from public static inline function fromMapData(mapData:MapData)
		return new Map(new TmxMap(mapData));
}
 
class TmxEntity extends Entity
{

	public var map:TmxMap;
	public var debugObjectMask:Bool;
	
public function new(mapData:Map)
	{
		super();

		map = mapData;
/*#if debug
		debugObjectMask = true;
#end*/
	}

	public function loadImageLayer(name:String)
	{
		if (map.imageLayers.exists(name) == false)
		{
#if debug
			trace("Image layer '" + name + "' doesn't exist");
#end
			return;
		}
		
		addGraphic(new PunkImage(map.imageLayers.get(name)));
	}
	
	public function loadGraphic(tileset:String, layerNames:Array<String>, skip:Array<Int> = null)
	{
		
		var gid:Int, layer:TmxLayer;
		for (name in layerNames)
		{
			if (map.layers.exists(name) == false)
			{
#if debug
				trace("Layer '" + name + "' doesn't exist");
#end
				continue;
			}
			
			layer = map.layers.get(name);
			var spacing = map.getTileMapSpacing(name);
			
			var tilemap = new Tilemap(tileset, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight, spacing, spacing);
			tilemap.alpha = layer.opacity;
			
			var local = layer.properties.resolve("local") == "true" ? true:false;
			
			checkAnimations(tilemap, tileset,local);
			
			// Loop through tile layer ids
			for (row in 0...layer.height)
			{
				for (col in 0...layer.width)
				{
					gid = layer.tileGIDs[row][col] - 1;
					if (TileAnimationManager.getLayer(tileset) != null && TileAnimationManager.getLayer(tileset).exists(gid)) {
						tilemap.hasAnimations = true;
					}
					else if (TileAnimationManager.getParentLayer(tileset) != null && TileAnimationManager.getParentLayer(tileset).exists(gid)) {
						tilemap.hasAnimations = true;
					}
					if (skip == null || Lambda.has(skip, gid) == false){
						tilemap.setTile(col, row, gid);
					}
				}
			}
		
			addGraphic(tilemap);
			
		}
	}
	
	function checkAnimations(tilemap:Tilemap,name:String,local:Bool) : Void
	{
		var tileset:TmxTileSet;
		
		for (i in 0...map.tilesets.length) {
			tileset = map.tilesets[i];
			
			if(name != tileset.name) continue;
			if (TileAnimationManager.layerExists(name) && !local) {
				tilemap.initAnims(name, false);
				continue;
			};
			tilemap.initAnims(name, local);
			var numTiles = tilemap.tileRows() * tilemap.tileColumn();
			
			for (id in 0...numTiles)
			{
					if (tileset.getProperties(id) != null && tileset.getProperties(id).resolve("animlength") != null) {
					
					var length:Int = Std.parseInt(tileset.getProperties(id).resolve("animlength"));
					var speed:Int =  Std.parseInt(tileset.getProperties(id).resolve("speed"));
					var reverse:Bool = tileset.getProperties(id).resolve("reverse") == "true";
					var vertical:Bool =  tileset.getProperties(id).resolve("vertical") == "true";
					tilemap.addAnimatedTile(id, length, speed, reverse, vertical, name);
					
					if (tileset.getProperties(id).resolve("animchildren") == "true")
					{
						for (k in 0...length)
						{
							var child:Int;
							if (vertical) {
								child = id + k * tilemap.tileRows();
							}
							else child = id + k;
							
							tilemap.addChildTile(child,id,name);
						}
					}
				}
			}
		}
	}
	
	
	public function loadMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		var tileCoords:Array<TmxVec4> = new Array<TmxVec4>();
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return tileCoords;
		}

		var gid:Int;
		var layer:TmxLayer = map.layers.get(collideLayer);
		var grid = new Grid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);

		// Loop through tile layer ids
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					grid.setTile(col, row, true);
					tileCoords.push(new TmxVec4(col*map.tileWidth, row*map.tileHeight, map.tileWidth, map.tileHeight));
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
		return tileCoords;
	}
	
		
	public function loadSlopedMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return;
		}
		
		var gid:Int;
		var layer:TmxLayer = map.layers.get(collideLayer);
		var grid = new SlopedGrid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
		var types = Type.getEnumConstructs(TileType);
		
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					var type = map.getGidProperty(gid + 1, "tileType");
					// collideType is null, load as solid tile
					if (type == null)
						grid.setTile(col, row, Solid);
					// load as custom collide type tile
					else
					{
						for(i in 0...types.length)
						{
							if(type == types[i])
							{
								grid.setTile(col, row,
									Type.createEnum(TileType, type),
									Std.parseFloat(map.getGidProperty(gid + 1, "slope")),
									Std.parseFloat(map.getGidProperty(gid + 1, "yOffset"))
									);
								break;
							}
						}
					}
				}
			}
		}
		
		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
	}
	
	/*
		debugging shapes of object mask is only availble in -flash
		currently only supports ellipse object (circles only), and rectangle objects
			no polygons yet
	*/
	public function loadObjectMask(collideLayer:String = "objects", typeName:String = "solidObject")
	{
		if (map.getObjectGroup(collideLayer) == null)
		{
#if debug
				trace("ObjectGroup '" + collideLayer + "' doesn't exist");
#end
			return;
		}

		var objectGroup:TmxObjectGroup = map.getObjectGroup(collideLayer);

		var masks_ar = new Array<Dynamic>();

		// Loop through objects
		for(object in objectGroup.objects){ // :TmxObject
			masks_ar.push(object.shapeMask);
		}

		var maskList = new Masklist(masks_ar);
		this.mask = maskList;
		this.type = typeName;

	}
	
}