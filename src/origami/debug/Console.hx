package origami.debug;

import openfl.events.FocusEvent;
import haxe.PosInfos;
import haxe.Log;
import lime.ui.KeyCode;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import origami.Engine;
import openfl.events.KeyboardEvent;
import openfl.events.Event;

class Console extends Sprite {
    public var consoleOpen:Bool = true;
    var bg:Bitmap;
    var imgBg:Bitmap;
    var entryField:TextField;
    var entryFieldPrompt:Bitmap;
    var log:TextField;
    var logHtml:String;
    var commands:Map<String, Array<String>->Void>;     // Stores the function callbacks that correspond to each command name.
    var descriptions:Map<String, String>;       // Stores the descriptions that correspond to each command name.
    var usages:Map<String, String>;             // Stores the command usages that correspond to each command name.

    public function new(engine:Engine){
        super();

        // Initialize background
        bg = new Bitmap(new BitmapData(engine.getScreenWidth(), engine.getScreenHeight(), true, 0xCC000000));
        addChild(bg);

        imgBg = new Bitmap(Assets.getBitmapData("assets/engine/consoleBg_vixeyText.png"));
        imgBg.x = engine.getScreenWidth() - imgBg.width;
        imgBg.alpha = .33;
        addChild(imgBg);

        // Initialize logging field
        log = new TextField();
        log.width = engine.getScreenWidth();
        log.height = engine.getScreenHeight() - 18;
        log.defaultTextFormat = new TextFormat("ProggyCleanTT", 16);
        log.selectable = true;
        log.multiline = true;
        log.wordWrap = true;
        addChild(log);
        logHtml = "";

        // Initialize text entry field
        entryField = new TextField();
        entryField.width = engine.getScreenWidth() - 18;
        entryField.height = 18;
        entryField.x = 18;
        entryField.y = engine.getScreenHeight() - 18;
        entryField.defaultTextFormat = new TextFormat("ProggyCleanTT", 16, 0x000000);
        entryField.background = true;
        entryField.type = TextFieldType.INPUT;
        entryField.selectable = true;
        entryField.multiline = false;
        addChild(entryField);

        entryFieldPrompt = new Bitmap(Assets.getBitmapData("assets/engine/consolePrompt.png"));
        entryFieldPrompt.y = engine.getScreenHeight() - 18;
        addChild(entryFieldPrompt);

        commands = new Map<String, Array<String>->Void>();
        descriptions = new Map<String, String>();
        usages = new Map<String, String>();

        Log.trace = traceHandler;

        addBaseCommands();
        writeLine("Welcome to the Origami Console", 0x00CCCC);
        addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
        entryField.addEventListener(FocusEvent.FOCUS_IN, onEntryFieldActive);
        entryField.addEventListener(FocusEvent.FOCUS_OUT, onEntryFieldInactive);
    }

    function onEntryFieldActive(evt:Event){
        entryFieldPrompt.bitmapData = Assets.getBitmapData("assets/engine/consolePrompt_active.png");
    }
    function onEntryFieldInactive(evt:Event){
        entryFieldPrompt.bitmapData = Assets.getBitmapData("assets/engine/consolePrompt.png");
    }

    // Add a command to the console.
    public function addCommand(name:String, callback:Array<String>->Void, description:String, usage:String):Void {
        if(!commands.exists(name.toLowerCase())){
            commands.set(name.toLowerCase(), callback);
            descriptions.set(name.toLowerCase(), description);
            usages.set(name.toLowerCase(), usage);
        }
        else Tail.log('Failed to add command $name - Command already exists');
    }

    // Alias a command to another.
    public function aliasCommand(aliasName:String, actualName:String){
        if(actualName.toLowerCase != aliasName.toLowerCase){
            if(!commands.exists(aliasName.toLowerCase())){
                if(commands.exists(actualName.toLowerCase())){
                    commands.set(aliasName.toLowerCase(), commands.get(actualName));
                    descriptions.set(aliasName.toLowerCase(), "!ALIAS!");
                    usages.set(aliasName.toLowerCase(), '$aliasName is an alias to $actualName. Please see the usage for $actualName instead.');
                }
                else Tail.log('Failed to alias command \'$actualName\' as \'$aliasName\' - Command does not exist');
            }
            else Tail.log('Failed to alias command \'$actualName\' as \'$aliasName\' - Alias already exists');
        }
        else Tail.log('Failed to alias command \'$actualName\' as \'$aliasName\' - Duplicate commands');
    }

    function traceHandler(text:Dynamic, ?position:PosInfos):Void {
        writeLine(Std.string(text));
    }

    public function writeLine(text:String, color:Int = 0xFFFFFF):Void {
        logHtml += "<font color='#" + StringTools.hex(color) +"'>" + text + "</font><br>";
        log.htmlText = logHtml;
        log.scrollV = log.maxScrollV;
    }

    public function write(text:String, color:Int = 0xFFFFFF):Void {
        logHtml += "<font color='#" + StringTools.hex(color) +"'>" + text + "</font>";
        log.htmlText = logHtml;
        log.scrollV = log.maxScrollV;
    }

    function addBaseCommands():Void {
        addCommand("setconsolebg", function(arg:Array<String>){
            if(arg.length == 1){
                try {
                    imgBg.bitmapData = Assets.getBitmapData("assets/engine/consoleBg_" + arg[0] + ".png");
                } catch(e:Dynamic) {
                    Tail.log("Background does not exist.", 3);
                }
            }
            else if(arg.length == 0) Tail.log("Not enough arguments.");
            else Tail.log("Too many arguments.");
        }, "Sets the console background image.", "setConsoleBg <bgName>");

        addCommand("clear", function(arg:Array<String>){
            logHtml = "";
            log.htmlText = "";
        }, "Clears the console text.", "No arguments.");

        addCommand("help", function(arg:Array<String>){
            if(arg.length == 0){
                for(command in descriptions.keys()){
                    // We do not print aliases to the console, skip them by checking the command description.
                    if(descriptions.get(command) != "!ALIAS!"){
                        writeLine(command + ": " + descriptions.get(command), 0x00CC00);
                    }
                }
            }
            else if(arg.length == 1){
                if(commands.exists(arg[0])){
                    writeLine(arg[0] + ": " + usages.get(arg[0]));
                }
                else Tail.log("Command does not exist.");
            }
            else Tail.log("Too many arguments.");
        }, "Prints helpful information.", "help (commandName)");
    }

    public function showConsole():Void {
        this.alpha = 1;
        addChild(entryField);
        consoleOpen = true;
    }

    public function hideConsole():Void {
        this.alpha = 0;
        removeChild(entryField);
        consoleOpen = false;
    }

    // Input
    function onKeyPress(evt:KeyboardEvent):Void {
        if(consoleOpen){
            if(evt.keyCode == KeyCode.RETURN || evt.keyCode == KeyCode.NUMPAD_ENTER){
                writeLine(entryField.text);
                var commandData:Array<String> = entryField.text.split(" ");
                // Check if the command exists
                if(commands.exists(commandData[0])){
                    // If the command is not given arguments, call it with a blank argument array
                    if(commandData.length == 0){
                        commands.get(commandData[0])(new Array<String>());
                    }
                    // If the command is given arguments, we need to pull the argument data away from the command data.
                    else {
                        var argumentData:Array<String> = new Array<String>();
                        // Copy the command data
                        argumentData = commandData.copy();
                        // Remove the command itself from the argument array
                        argumentData.remove(argumentData[0]);
                        // Then call the command, passing the argument array
                        commands.get(commandData[0])(argumentData);
                    }
                }
                else Tail.log("Command does not exist.");
                entryField.text = "";
            }
        }
    }
}