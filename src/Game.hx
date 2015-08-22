class Game extends hxd.App {

	override function init() {
		inst = this;
	}

	public static var inst : Game;

	static function main() {
		new Game();
	}

}