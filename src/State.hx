class State {

	public var intro : Bool;
	public var gold : Int;
	public var buldozeCount : Int;
	public var actions : Array<Game.Action>;

	public function new() {
		gold = 100;
	}

	public function init() {
		gold = 100;
		if( actions == null ) actions = [];
	}

}