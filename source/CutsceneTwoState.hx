package;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import openfl.Lib;

class CutsceneTwoState extends MusicBeatState
{
	var _goodEnding:Bool = false;

	var zoom:Float = -1;

	#if desktop
	var video:MP4Handler = new MP4Handler();
	#end

	public function new(goodEnding:Bool = true) 
	{
		super();
		_goodEnding = goodEnding;
		
	}
	
	override public function create():Void 
	{
		trace(PlayState.storyWeek);
		super.create();	
		//hi im bebepanzon
		if (PlayState.storyWeek == 0)
			endIt();
		else
			FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
			if (PlayState.storyWeek == 1)
				#if desktop
				video.playMP4(Paths.video('endurancecutscene'), new PlayState());
				#elseif mobile
				LoadingState.loadAndSwitchState(new VideoStateLegal('assets/videos/' + 'endurancecutscene', new PlayState()));
				#end
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
	public function endIt(e:FlxTimer=null){
		trace("ENDING");
		FlxG.switchState(new PlayState());
	}
	
}