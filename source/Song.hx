package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Event
{
	public var name:String;
	public var position:Float;
	public var value:Dynamic;
	public var type:String;

	public function new(name:String,pos:Float,value:Dynamic,type:String)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}

typedef SwagSong =
{
	var chartVersion:String;
	var song:String;
	var notes:Array<SwagSection>;
	var eventObjects:Array<Event>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var chartVersion:String;
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var eventObjects:Array<Event>;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var stage:String = '';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJsonRAW(rawJson:String)
	{
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}
	
		return parseJSONshit(rawJson);
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = OpenFlAssets.getText(Paths.json('${folder.toLowerCase()}/${jsonInput.toLowerCase()}')).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		return cast Json.parse(rawJson).song;
	}
}
