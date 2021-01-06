package origami;

class Globals {
    public static var vars:Map<String, Dynamic> = new Map<String, Dynamic>();
    
    public static function get(varName:String):Dynamic {
        if(vars.exists(varName)){
            return vars.get(varName);
        }
        else return null;
    }

    public static function set(varName:String, value:Dynamic){
        vars.set(varName, value);
    }
}