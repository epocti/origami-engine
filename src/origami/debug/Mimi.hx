package origami.debug;

import sys.io.Process;

class Mimi {
    public static function loadCommands(console:Console):Void {
        console.addCommand("info", function(arg:Array<String>){
            console.writeLine('Program name: UNIMPLEMENTED');
			console.writeLine('Origami version: ${Engine.VERSION}');
			console.writeLine('OS: ${Sys.systemName()}');
			console.writeLine('Launch args: ${Sys.args()}');
			console.writeLine('Launch dir: ${Sys.getCwd()}');
			console.writeLine('CPU time: ${Sys.cpuTime()}');
			console.writeLine('Environment vars: ${Sys.environment()}');
        }, "Prints information about the engine and system.", "No arguments.");

		console.addCommand("alias", function(arg:Array<String>){
			if(arg.length == 2){
				console.aliasCommand(arg[1], arg[0]);
			}
			else if(arg.length > 2) Tail.log("Too many arguments.");
			else Tail.log("Too little arguments.");
		}, "Map a command name to another.", "alias [exisingCommand] [newName]");

		console.addCommand("exec", function(arg:Array<String>){
			if(arg.length >= 1){
				var entry:String = "";
				for(i in 0...arg.length){
					if(i == arg.length - 1) entry += arg[i];
					else entry += arg[i] + " ";
				}
				var proc:Process = new Process(entry);
				trace(proc.stdout.readAll());
			}
			else if(arg.length == 1){
				var proc:Process = new Process(arg[0]);
				trace(proc.stdout.readUntil(-1));
			}
			else Tail.log("Too little arguments.");
		}, "Launch another executable, interrupting this program.", "execute [path] (arg1 arg2 ...)\nPlease be careful.");

		console.addCommand("ls", function(arg:Array<String>){
			if(arg.length == 0){
				Tail.log("global");
			}
			else if(arg.length == 1){
				switch(arg[0]){
					case "global" | "globals" | "gvar" | "var":
						for(gvar in Globals.vars.keys()){
							Tail.log('$gvar (${Std.string(Type.typeof(Globals.get(gvar)))}): ${Globals.get(gvar)}');
						}
					default: Tail.log('Unknown resource listing \'${arg[0]}\'');
				}
			}
			else Tail.log("Too many arguments.");
		}, "List various resources of the engine, such as variables, available gameobjects, etc.", "ls (resourceType)");

		console.addCommand("set", function(arg:Array<String>){
			if(arg.length == 3){
				switch(arg[0]){
					case "int":
						Globals.set(arg[1], Std.parseInt(arg[2]));
					case "float":
						Globals.set(arg[1], Std.parseFloat(arg[2]));
					case "str":
					case "string":
						Globals.set(arg[1], arg[2]);
					default: Tail.log('Unsupported data type ${arg[0]}');
				}
			}
			// todo: if the args specified is greater than 3 and is supposed to be a string, then concat the extra arguments
			else if(arg.length > 3) Tail.log("Too many arguments.");
			else Tail.log("Too little arguments.");
		}, "Sets the specified global variable.", "set [datatype] [varName] [value]");

		console.addCommand("get", function(arg:Array<String>){
			if(arg.length == 1){
				Tail.log(Globals.get(arg[0]));
			}
			else if(arg.length > 1) Tail.log("Too many arguments.");
			else Tail.log("Too little arguments.");
		}, "Returns the specified global variable.", "get [varName]");

		console.addCommand("typeof", function(arg:Array<String>){
			if(arg.length == 1){
				Tail.log(Std.string(Type.typeof(Globals.get(arg[0]))));
			}
			else if(arg.length > 1) Tail.log("Too many arguments.");
			else Tail.log("Too little arguments.");
		}, "Returns the typename of the specified global variable.", "get [varName]");

		console.addCommand("quit", function(arg:Array<String>){
			if(arg.length == 0) Sys.exit(0);
			else if(arg.length == 1) Sys.exit(Std.parseInt(arg[0]));
			else Tail.log("Too many arguments.", 4);
		}, "Quits the application.", "quit (exitCode)");
		console.aliasCommand("exit", "quit");
    }
}