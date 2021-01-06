package origami.display;

import openfl.geom.Matrix;
import motion.easing.Linear;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import motion.Actuate;
import motion.easing.IEasing;

enum OriginPoint {
	CENTER;
	TOPLEFT;
	TOPCENTER;
	TOPRIGHT;
	MIDLEFT;
	MIDRIGHT;
	BOTTOMLEFT;
	BOTTOMCENTER;
	BOTTOMRIGHT;
}

class OSprite extends Sprite {
	var bitmap:Bitmap;

    public function new(sourceData:BitmapData){
        super();

		bitmap = new Bitmap(sourceData);

		if(Engine.FORCE_BITMAP_SMOOTH) bitmap.smoothing = true;
		else bitmap.smoothing = false;

		addChild(bitmap);
    }

	public function setX(pos:Int, round:Bool = Engine.FORCE_PIXEL_ROUND):Void {
		this.x = pos;
	}
	public function setY(pos:Int, round:Bool = Engine.FORCE_PIXEL_ROUND):Void {
		this.y = pos;
	}
	public function setXY(xpos:Int, ypos:Int, round:Bool = Engine.FORCE_PIXEL_ROUND):Void {
		this.x = round ? Std.int(xpos) : xpos;
		this.y = round ? Std.int(ypos) : ypos;
	}

	public function setScaleX(percent:Float){
		this.width = percent;
	}
	public function setScaleY(percent:Float){
		this.height = percent;
	}
	public function setScale(percent:Float){
		this.scaleX = percent;
		this.scaleY = percent;
	}

	public function getSkewX():Float {
		return this.transform.matrix.c;
	}
	public function getSkewY():Float {
		return this.transform.matrix.b;
	}
	public function setSkewX(amt:Float){
		var tempMatrix:Matrix = this.transform.matrix;
		tempMatrix.c = amt;
		this.transform.matrix = tempMatrix;
	}
	public function setSkewY(amt:Float){
		var tempMatrix:Matrix = this.transform.matrix;
		tempMatrix.b = amt;
		this.transform.matrix = tempMatrix;
	}

	public function setOrigin(origin:OriginPoint):Void {
		switch(origin){
			case CENTER:
				bitmap.x = -(bitmap.width / 2);
				bitmap.y = -(bitmap.height / 2);
			case TOPLEFT:
				bitmap.x = 0;
				bitmap.y = 0;
			case TOPCENTER:
				bitmap.x = -(bitmap.width / 2);
				bitmap.y = 0;
			case TOPRIGHT:
				bitmap.x = -(bitmap.width);
				bitmap.y = 0;
			case MIDLEFT:
				bitmap.x = 0;
				bitmap.y = -(bitmap.height / 2);
			case MIDRIGHT:
				bitmap.x = -(bitmap.width);
				bitmap.y = -(bitmap.height / 2);
			case BOTTOMLEFT:
				bitmap.x = 0;
				bitmap.y = -(bitmap.height);
			case BOTTOMCENTER:
				bitmap.x = -(bitmap.width / 2);
				bitmap.y = -(bitmap.height);
			case BOTTOMRIGHT:
				bitmap.x = -(bitmap.width);
				bitmap.y = -(bitmap.height);
		}
			
	}

	// Scaling tweens
	public function scaleTo(width:Float, height:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		Actuate.tween(this, time, {scaleX:width}).ease(easing);
		Actuate.tween(this, time, {scaleY:height}).ease(easing);
	}

	public function scaleBy(width:Float, height:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		var targetWidth:Float = this.scaleX + width;
		var targetHeight:Float = this.scaleY + height;
		Actuate.tween(this, time, {scaleX:targetWidth}).ease(easing);
		Actuate.tween(this, time, {scaleY:targetHeight}).ease(easing);
	}

	// Fading tweens
	public function fadeTo(opac:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		Actuate.tween(this, time, {alpha:opac}).ease(easing);
	}

	public function fadeBy(opac:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		var targetOpac:Float = this.alpha + opac;
		Actuate.tween(this, time, {alpha:targetOpac}).ease(easing);
	}

	// Rotating tweens
	public function spinBy(deg:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		var targetDeg:Float = this.rotation + deg;
		Actuate.tween(this, time, {rotation:targetDeg}).ease(easing);
	}

	public function spinTo(deg:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		var targetDeg:Float = (this.rotation + deg) % 360;
		Actuate.tween(this, time, {rotation:targetDeg}).ease(easing);
	}

	// Skewing tweens
	public function skewTo(x:Float, y:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		Actuate.update(setSkewX, time, [getSkewX()], [x]).ease(easing);
		Actuate.update(setSkewY, time, [getSkewY()], [y]).ease(easing);
	}

	public function skewBy(x:Float, y:Float, time:Float, easing:IEasing = null, callback:Dynamic->Dynamic = null):Void {
		if(easing == null) easing = Linear.easeNone;
		var targetX:Float = this.transform.matrix.c + x;
		var targetY:Float = this.transform.matrix.b + y;
		Actuate.update(setSkewX, time, [getSkewX()], [targetX]).ease(easing);
		Actuate.update(setSkewY, time, [getSkewY()], [targetY]).ease(easing);
	}
}