package;

import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	private var camFollow:FlxObject;
	var selector:FlxText;
	var curSelected:Int = 0;
	//var canSelect:Bool = true;
	//var thumblist:Array<String> = ['Random', 'Loid', 'Endurance', 'Voca', 'Endless', 'PoPiPo', 'Aishite', 'SIU', 'Disappearance'];
	var curDifficulty:Int = 1;
	var curThumb:Int = 0;
	var poop:String = "";
	var songFormat:String = "";
	var bpmarray = [];
	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';
	var songMenu:FreeplayObj;

	//Buttons stuff
	var difficultyBar:FlxSprite;
	var hard_button:FlxSprite;
	var easy_button:FlxSprite;
	var normal_button:FlxSprite;
	//End

	var recordSmall:FlxSprite;
	var thumbnail:FlxSprite;
	//var logolmao:FlxSprite;
	private var curPlaying:Bool = false;
	var loadIn:Transition;
	var loadOut:Transition;
	private var iconArray:Array<HealthIcon> = [];
	private var songArray:Array<FreeplayObj> = [];

	override function create()
	{
		
		getBPM();
		
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		loadIn = new Transition(0,0,'in');
		loadIn.scrollFactor.set(0,0);
		loadIn.animation.finishCallback = deleteLoadIn;
		loadOut = new Transition(0,0,'out');
		loadOut.alpha = 0;
		loadOut.scrollFactor.set(0,0);
		
		Conductor.changeBPM(110);
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(XY);
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		 #if windows
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

			addWeek(['Loid', 'Endurance', 'Voca', 'Endless'], 1, ['miku']);
			addWeek(['PoPiPo', 'Aishite', 'SIU', 'Disappearance'], 2, ['miku', 'miku', 'miku', 'miku-mad']);
			addWeek(['Rolling'], 3, ['miku']);
			addWeek(['Anamanaguchi', 'Dwelling'], 4, ['miku', 'miku']);
			addWeek(['Infinite'], 5, ['miku']);

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:MikuBG = new MikuBG(0,0);
		bg.scrollFactor.set(0,0);
		add(bg);

		var bars:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menuBG/freeplaybars'));
		bars.scrollFactor.set();
		bars.screenCenter(Y);
		bars.updateHitbox();
		bars.antialiasing = FlxG.save.data.antialiasing;
	

		var tex = Paths.getSparrowAtlas('menuBG/menus');
		
		for (i in 0...songs.length)
		{
			
			songMenu = new FreeplayObj(10 + (i * 40), 60 + (i * 120),songs[i].songName);
			songMenu.ID = i;
			songArray.push(songMenu);
			add(songMenu);
			camFollow.x = songArray[0].getX() + 250;
			camFollow.y = songArray[0].getY();

			songArray[i].alpha = 0;
			songArray[i].x -= 200;
			FlxTween.tween(songArray[i], {x: songArray[i].x, alpha: 1},0.5 ,{ease:FlxEase.smoothStepOut, startDelay: 0.3 * i});

		}
		add(bars);
	
		thumbnail = new FlxSprite();
		thumbnail.scrollFactor.set(0,0);
		thumbnail.frames = Paths.getSparrowAtlas('songs/Thumbnails');
		thumbnail.animation.addByPrefix('0','Random',1,true);
		thumbnail.animation.addByPrefix('1','Loid',1,true);
		thumbnail.animation.addByPrefix('2','Endurance',1,true);
		thumbnail.animation.addByPrefix('3','Voca',1,true);
		thumbnail.animation.addByPrefix('4','Endless',1,true);
		thumbnail.animation.addByPrefix('5','PoPiPo',1,true);
		thumbnail.animation.addByPrefix('6','Aishite',1,true);
		thumbnail.animation.addByPrefix('7','SIU',1,true);
		thumbnail.animation.addByPrefix('8','Disappearance',1,true);
		thumbnail.animation.addByPrefix('9','Rolling',1,true);
		thumbnail.animation.addByPrefix('10','Anamanaguchi',1,true); //Fiquei com preguiça de fazer uma capa de album custom pra isso. k
		thumbnail.animation.addByPrefix('11','Dwelling',1,true);
		thumbnail.animation.addByPrefix('12','Voca',1,true);
		thumbnail.setGraphicSize(Std.int(thumbnail.width * 0.9));
		thumbnail.y += 50;
		thumbnail.x += 200;
		thumbnail.updateHitbox();
		thumbnail.antialiasing = FlxG.save.data.antialiasing;


		recordSmall = new FlxSprite(thumbnail.x + 610, thumbnail.y + 150).loadGraphic(Paths.image('menuBG/recordsmall'));
		recordSmall.scrollFactor.set(0,0);
		recordSmall.antialiasing = FlxG.save.data.antialiasing;
		recordSmall.setGraphicSize(Std.int(recordSmall.width * 0.85));
		recordSmall.updateHitbox();

		add(recordSmall);
		add(thumbnail);

		thumbnail.animation.play('0');

	
		difficultyBar = new FlxSprite(FlxG.width * 0.7, 20);
		difficultyBar.scrollFactor.set(0,0);
		difficultyBar.loadGraphic(Paths.image('menuBG/diffs/diffbar_clean'));
		difficultyBar.antialiasing = FlxG.save.data.antialiasing;
		add(difficultyBar);
		difficultyBar.alpha = 0;
		difficultyBar.x += 200;
		difficultyBar.y += 25;

		hard_button = new FlxSprite(FlxG.width * 0.7, 20);
		hard_button.scrollFactor.set(0,0);
		hard_button.loadGraphic(Paths.image('menuBG/diffs/hard_button'));
		hard_button.antialiasing = FlxG.save.data.antialiasing;
		hard_button.updateHitbox();
		hard_button.x += 232;
		hard_button.y += 49;
		add(hard_button);

		easy_button = new FlxSprite(FlxG.width * 0.7, 20);
		easy_button.scrollFactor.set(0,0);
		easy_button.loadGraphic(Paths.image('menuBG/diffs/easy_button'));
		easy_button.antialiasing = FlxG.save.data.antialiasing;
		easy_button.updateHitbox();
		easy_button.x -= 47;
		easy_button.y += 49;
		add(easy_button);

		normal_button = new FlxSprite(FlxG.width * 0.7, 20);
		normal_button.scrollFactor.set(0,0);
		normal_button.loadGraphic(Paths.image('menuBG/diffs/normal_button'));
		normal_button.antialiasing = FlxG.save.data.antialiasing;
		normal_button.updateHitbox();
		normal_button.x += 82;
		normal_button.x +=300;
		normal_button.alpha = 0;
		normal_button.y += 49;
		add(normal_button);

		FlxTween.tween(difficultyBar, {alpha: 1, x: difficultyBar.x - 300}, 0.8,{startDelay: 0.3, ease: FlxEase.smoothStepInOut});
		FlxTween.tween(normal_button, {alpha: 1, x: normal_button.x - 300}, 0.8,{startDelay: 0.3, ease: FlxEase.smoothStepInOut});

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
	
		scoreText.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, RIGHT);
	
		add(scoreText);
		loadIn.animation.play('transition');
		add(loadIn);
		add(loadOut);

		changeSelection();
		changeDiff(1,true);

		#if mobileC
		addVirtualPad(UP_DOWN, A_B);
		#end


		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		//Touch stuff
		if (BSLTouchUtils.apertasimples(easy_button)){
			changeDiff(0, true);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}else if(BSLTouchUtils.apertasimples(normal_button)){
			changeDiff(1, true);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}else if(BSLTouchUtils.apertasimples(hard_button)){
			changeDiff(2, true);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		//using this instead of tweening it cause it bugged weirdly
		recordSmall.angle += 1;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.camera.focusOn(camFollow.getPosition());
		#if debug
		if (FlxG.keys.justPressed.END){
			for (i in 0...songArray.length){
				songArray[i].isSelected = true;
			}
			trace('shit');
		}
		#end


		for (i in 0...songArray.length){
			songArray[i].score = Highscore.getScore(songArray[i].getSong(),curDifficulty);
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

	

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		
		}
		if (downP)
		{
			changeSelection(1);
		
		}

		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

		if (controls.BACK)
		{
			
			for (i in 0...songArray.length)
			FlxTween.tween(songArray[i],{x:songArray[i].x-300,alpha:0},0.5,{ease:FlxEase.smoothStepIn,startDelay:0.1*i});
			loadOut.animation.play('transition');
			loadOut.alpha = 1;
			loadOut.animation.finishCallback = function(huh:String){FlxG.switchState(new MainMenuState());}
		}
	

		if (accepted)
		{
			// adjusting the song name to be compatible
			songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
			trace(songs[curSelected].songName);

			poop = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.limparCache = true;

			
			
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			for (i in 0...songArray.length){
				if(songArray[i].ID != curSelected)
				FlxTween.tween(songArray[i],{x:songArray[i].x - 300,alpha :0},0.4,{ease:FlxEase.smoothStepIn});
			}

			FlxFlicker.flicker(songArray[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker){
				loadOut.animation.play('transition');
				loadOut.alpha = 1;
				loadOut.animation.finishCallback = function(huh:String){
					LoadingState.loadAndSwitchState(new EstadoDeTroca());
				}
				
				
			});
		}
	}

	function changeDiff(change:Int = 0, directly:Bool = false)
	{
		if (!directly)
            curDifficulty += change;
        else
            curDifficulty = change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		trace(intendedScore);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		hard_button.visible = false;
		normal_button.visible = false;
		easy_button.visible = false;

		switch (curDifficulty)
		{
			case 0:
				easy_button.visible = true;
			case 1:
				normal_button.visible = true;
			case 2:
				hard_button.visible = true;
		}
	}

	

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end
		
		
	
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;


		
		Conductor.changeBPM(bpmarray[curSelected]);
		//trace(getBPM());
		tweenThumbnail();
		

		
		
		for (i in 0...songArray.length){
			songArray[i].isSelected = false;
		}
		songArray[curSelected].isSelected = true;
		FlxTween.tween(camFollow, {y: songArray[curSelected].getY()},0.2, {ease: FlxEase.smoothStepOut});
		FlxTween.tween(camFollow, {x: songArray[curSelected].getX() + 250},0.2, {ease: FlxEase.smoothStepOut});

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end
	}


	
	override function beatHit()
		{
			super.beatHit();
		}

			

	function getBPM():Void{
		for (i in 0...songs.length){
		var bpm = Song.loadFromJson(Highscore.formatSong(StringTools.replace(songs[i].songName, " ", "-"),curDifficulty),songs[curSelected].songName);
		bpmarray.push(bpm.bpm);
		}
	}


// function bopThumbnail():Void
// 	{
// 		FlxTween.tween(thumbnail.scale,{x: 1.1 ,y: 1.1},0.2,{ease:FlxEase.quintOut,type:PINGPONG,
// 			onComplete:function(twn:FlxTween)
// 			{
// 				FlxTween.cancelTweensOf(thumbnail.scale);
// 			}
// 		})
// 	}

function tweenThumbnail():Void
	{
		
		FlxTween.cancelTweensOf(recordSmall);
		FlxTween.cancelTweensOf(thumbnail);
		recordSmall.alpha = 0;
		recordSmall.x = 880;
		
		FlxTween.tween(thumbnail,{x : 400, alpha : 0},0.2,{ease:FlxEase.cubeIn,
			onComplete: function(twn:FlxTween)
			{
				thumbnail.animation.play(Std.string(curSelected));
				FlxTween.tween(thumbnail,{x : 200, alpha : 1},0.2,{ease:FlxEase.cubeOut,
					onComplete: function(twn:FlxTween)
					{
					FlxTween.tween(recordSmall,{x: 810, alpha:1},0.3,{ease:FlxEase.smoothStepOut,startDelay: 0.6});
					}
				});
			}
		});
	}


	
	
	

	function deleteLoadIn(huh:String){
		loadIn.kill();
		}
	
}





class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
