package origami.debug;

/* Severity List:
 * 0: Debug [D] (low-level information) - deep green
 * 1: Information [I] (general, but likely unneeded information - DEFAULT) - white
 * 2: Crucial Information {I} (information related to crucial engine actions) - epoctiblue
 * 3: Console return [R] (information given by entering console commands) - green
 * 4: Warning {W} (Information to keep in mind, but not entirely breaking) - yellow-orange
 * 5: Error {E} (Something has gone wrong and should be addressed) - red
 * 6: Critical Error <CE> (Something seriously bad has happened) - deep red
 * 
 * Misc:
 * {F} Failed severity switch, associated with warning color
 */

class Tail {
	// Logging configuration options. This only affects the console's window, and not saved logs (when implemented).
	public static var writeFullClassNames = false;		// When false, only writes the classes name, and not its package.
	public static var writeLineNumbers = true;			// When true, writes the line number after the class name.
	public static var writeTimestamps = true;			// When true, writes the epoch time when the event was logged.
	public static var writeExecTimestamps = false;		// When true, writes the time in ms since the program was started when the event was logged.
	public static var writeFunctionNames = true;		// When true, writes the name of the function called from the class.
	public static var writeSeverity = false;			// 

	public static function log(message:String, severity:Int = 1, ?pos:haxe.PosInfos){
		// Construct message to print based on configuration options set
		var finalMessage:String = "";
		if(writeTimestamps) finalMessage += "[" + Sys.time() + "] ";
		if(writeExecTimestamps) finalMessage += "[" + Sys.cpuTime() + "] ";
		if(writeFullClassNames) finalMessage += pos.className;
		else finalMessage += pos.className.substring(pos.className.lastIndexOf(".") + 1, pos.className.length);
		if(writeFunctionNames) finalMessage += ":" + pos.methodName;
		if(writeLineNumbers) finalMessage += ":" + pos.lineNumber;
		if(writeSeverity){
			switch(severity){
				case 0: finalMessage += " [D]: ";
				case 1: finalMessage += " [I]: ";
				case 2: finalMessage += " {I}: ";
				case 3: finalMessage += " [C]: ";
				case 4: finalMessage += " {W}: ";
				case 5: finalMessage += " {E}: ";
				case 6: finalMessage += " {CE}: ";
				default: finalMessage += "{F}: ";
			}
		}
		else finalMessage += ": ";
		finalMessage += message;
		
		// In the stencyl log viewer, we are given timestamps and sender information already. In the debug console, we are only given sender (with some extra fluff).
        switch(severity){
			/*
            case 0: Console.writeText(finalMessage, 0x008000);
            case 1: Console.writeText(finalMessage, 0xEEEEEE);
            case 2: Console.writeText(finalMessage, 0x00CCCC);
            case 3: Console.writeText(finalMessage, 0x00FF00);
            case 4: Console.writeText(finalMessage, 0xFFBB00);
            case 5: Console.writeText(finalMessage, 0xFF6040);
            case 6: Console.writeText(finalMessage, 0xEE0000); */
            default: trace(finalMessage); // Temporary until the replacement console is written
        }
	}
}