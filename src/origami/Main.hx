package origami;

import openfl.display.Sprite;

class Main extends Sprite {
    public function new(){
        super();
        var engine:Engine = new Engine();
        addChild(engine);
    }
}