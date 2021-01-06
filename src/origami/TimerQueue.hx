package origami;

import haxe.Timer;

class TimerQueue {
	static var queue:Array<Timer> = new Array<Timer>();

	public static function runAfter(time:Float, callback:Void->Void):Void {
		var timer:Timer = Timer.delay(callback, Std.int(time * 1000));
	}

	public static function runLoop(time:Float, callback:Void->Void):Void {
		queue.push(new Timer(Std.int(time * 1000)));
		queue[queue.length - 1].run = callback;
	}

	public static function stopAll():Void {
		for(timer in queue){
			timer.stop();
		}
	}
}