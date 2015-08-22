
class Game extends hxd.App {

	public static inline var W = 400;
	public static inline var H = 300;

	var talk : Talk;
	public var event : hxd.WaitEvent;
	public var font : h2d.Font;

	override function init() {
		inst = this;
		event = new hxd.WaitEvent();
		font = hxd.Res._8bit.toFont();
		s2d.setFixedSize(W, H);
		talk = new Talk();
		talk.intro();
	}

	override function update(dt:Float) {
		event.update(dt);
	}

	public static var inst : Game;

	static function main() {
		hxd.Res.initEmbed( { compressSounds:true } );
		new Game();
	}

}