package origami;

import openfl.display.Stage;
import haxe.Timer;
import motion.easing.Elastic;
import openfl.geom.Matrix;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Expo;
import openfl.events.KeyboardEvent;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.events.Event;
import openfl.display.StageDisplayState;
import openfl.display.StageScaleMode;
import sys.io.File;
import haxe.Json;
import origami.debug.*;
import origami.display.*;

class Engine extends Sprite {
	public static inline var VERSION:String = "v0.0.1";

	var updateEvents:Array<Dynamic>;

	var timerQueue:Array<Timer>;

	var config:Dynamic;
	public static inline var FORCE_PIXEL_ROUND:Bool = false;
	public static inline var FORCE_BITMAP_SMOOTH:Bool = true;

	public var console:Console;

	public function new(){
		super();

		// Load the engine configuration from engine.json. If the config fails to load, loadConfig() will return false.
		if(!loadConfig()){
			Sys.exit(1);
		}

		// Create event arrays
		updateEvents = new Array<Dynamic>();

		// render stack should get added here VVV
		var test:OSprite = new OSprite(Assets.getBitmapData("assets/test.png"));
		addChild(test);
		test.setOrigin(CENTER);
		test.x = stage.stageWidth / 2;
        test.y = stage.stageHeight / 2;
		test.setScale(.5);
		
		addUpdateEvent(function(){
			test.x = mouseX;
			test.y = mouseY;
		});
		/*
		TimerQueue.runLoop(1, function(){
			test.scaleTo(.4, .5, .5, Quad.easeInOut);
			TimerQueue.runAfter(.5, function(){ test.scaleTo(.5, .4, .5, Quad.easeInOut); });
		}); */
		
		// Apply the config from engine.json
		applyConfig();
		// Create the debug console after the render stack, so it shows in front
		console = new Console(this);
		console.hideConsole();
		addChild(console);
		// Load the console commandset
		Mimi.loadCommands(console);

		Globals.set("coolVar", "cool value whee");
		trace(Globals.get("coolVar"));

		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
	}

	public function addUpdateEvent(evt:Void->Void):Void {
		updateEvents.push(evt);
	}

	// Main update loop
	function onUpdate(evt:Event):Void {
		for(event in updateEvents){
			event();
		}
	}

	// Input
    function onKeyPress(evt:KeyboardEvent):Void {
        if(console.consoleOpen){
            // Hides the console if the console is open.
            if(evt.keyCode == 192){
                console.hideConsole();
                Tail.log("Closed the console.");
            }
        }
        else {
            // Shows the console if the console is closed.
            if(evt.keyCode == 192){
                console.showConsole();
                Tail.log("Opened the console.");
            }
        }
    }

	function loadConfig():Bool {
		try {
			config = Json.parse(File.getContent("assets/engine.json"));
			return true;
		} catch (e:Dynamic){
			trace("Failed to load engine config: " + e);
		}
		return false;
	}

	function applyConfig():Void {
		// -- DISPLAY --
		// Apply framerate
		stage.frameRate = config.display.framerate;
		Tail.log("Framerate: \n" + stage.frameRate, 2);

		// Apply window size: resolution * scale
		stage.window.width = Std.int(config.display.windowWidth * config.display.scaleX);
		stage.window.height = Std.int(config.display.windowHeight * config.display.scaleY);			
		// Apply scaling
		this.scaleX = config.display.scaleX;
		this.scaleY = config.display.scaleY;
		// TODO: move window to center of the screen
		Tail.log("Stage width: " + stage.stageWidth, 2);
		Tail.log("Stage height: " + stage.stageHeight, 2);
		Tail.log("Stage scale (H): " + this.scaleX, 2);
		Tail.log("Stage scale (V): " + this.scaleY, 2);

		// Apply scale mode
		switch(config.display.scaleMode){
			case "none":
				stage.scaleMode = StageScaleMode.NO_SCALE;
				//break;
			case "letterbox":
				stage.scaleMode = StageScaleMode.SHOW_ALL;
				//break;
			case "stretch":
				stage.scaleMode = StageScaleMode.EXACT_FIT;
			case "fill":
				stage.scaleMode = StageScaleMode.NO_BORDER;
			default:
				stage.scaleMode = StageScaleMode.SHOW_ALL;
				//break;
		}
		Tail.log("Stage scale mode: " + stage.scaleMode);

		// Apply resize rule
		if(config.display.enableResize) stage.window.resizable = true;
		else stage.window.resizable = false;

		// Apply init fullscreen setting
		if(config.display.startInFullscreen) stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
	
		// -- INFORMATION --
		// Apply window title
		stage.window.title = config.information.windowTitle;
	
	}

	public function getScreenWidth():Int {
		return stage.stageWidth;
	}
	public function getScreenHeight():Int {
		return stage.stageHeight;
	}
}
