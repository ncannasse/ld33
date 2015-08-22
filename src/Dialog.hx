
class TextDeform extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		function vertex() {
			spritePosition.y += sin(spritePosition.x * 0.5 + time * 30);
		}
	}
}

class Dialog extends h2d.Sprite {

	public static var lastTalk = null;
	public static var lastTalkTime = 0.;

	var game : Game;
	var bg : h2d.ScaleGrid;
	var tf : h2d.Text;
	var timer : haxe.Timer;
	var int : h2d.Interactive;
	public var width(default, set) : Int;
	public var height(default, set) : Int;
	public var text(default, set) : String;

	public var index : Int;

	var textPos : Int;
	var sfx : hxd.snd.Channel;
	var talk : h2d.Anim;

	public function new( who : Talk.Char, text : String, isSelect = false ) {
		super();
		if( text == null ) text = "NULL";
		game = Game.inst;
		game.s2d.add(this, 1);

		var t = hxd.Res.chars.toTile().grid(16);
		talk = new h2d.Anim([t[who.getIndex() * 16], t[who.getIndex() * 16 + 1]], 0, this);
		talk.y = Game.H - 64;
		talk.x = who == Hero ? 5 : Game.W - (64 + 5);
		talk.scale(4);

		bg = new h2d.ScaleGrid(hxd.Res.dialog.toTile(), 5, 5, this);
		bg.colorKey = 0xFF00FF;
		tf = new h2d.Text(game.font, bg);

		if( text.charAt(0) == "~" ) {
			text = text.substr(1);
			tf.addShader(new TextDeform());
		}

		tf.y = 5;
		tf.x = 7;
		tf.text = text;
		tf.dropShadow = { dx : 0, dy : 1, color : 0, alpha : 0.3 };

		var width = Math.ceil(tf.textWidth * 0.5) + 20;
		if( width < 120 ) width = 120;

		if( width > tf.textWidth + 20 || isSelect ) width = tf.textWidth + 20;

		if( width > Game.W * 2 / 3 && !isSelect ) width = Std.int(Game.W * 2 / 3);

		this.width = width;
		tf.text = text;

		this.height = tf.textHeight + 5;

		if( !isSelect ) {
			tf.text = "";

			var words = text.split(" ");
			var out = words.shift();
			tf.text = out;
			for( w in words ) {
				tf.text += " " + w;
				if( tf.textHeight > 14 ) {
					tf.text = w;
					out += "\n" + w;
				} else
					out += " " + w;
			}
			text = out;
		}

		bg.y = Game.H - height - 50;
		bg.x = who == Hero ? 70 : Game.W - 70 - width;

		var ico = new h2d.Bitmap(hxd.Res.talkIco.toTile(), bg);
		ico.colorKey = 0xFFFF00FF;
		if( who == Hero ) ico.tile.flipX();
		ico.x = who == Hero ? 15 : width - 15;
		ico.y = height - 2;

		if( isSelect ) {
			tf.text = text;
			var choices = text.split("\n").length;
			var prev = null;
			for( idx in 0...choices ) {
				var c = new h2d.Bitmap(h2d.Tile.fromColor(0x0D64E3, tf.textWidth + 8, 14), bg);
				c.x = 4;
				c.y = idx * 14 + 2;
				c.alpha = 0;
				var i = new h2d.Interactive(c.tile.width, c.tile.height, c);
				i.onOver = function(_) {
					c.alpha = 1;
					hxd.Res.sfx.cursor.play();
				};
				i.onOut = function(_) {
					c.alpha = 0;
				};
				i.onClick = function(_) {
					index = idx;
					onClick();
				};
			}
			bg.addChild(tf);
			return;
		}


		if( lastTalk == who && haxe.Timer.stamp() - lastTalkTime < 0.1 ) {
			start(who,text);
		} else {
			bg.visible = false;
			talk.alpha = 0;
			game.event.waitUntil(function(dt) {
				talk.alpha += dt * 0.1;
				if( talk.alpha > 1 ) {
					talk.alpha = 1;
					start(who,text);
					return true;
				}
				return false;
			});

		}

	}

	function start(who, text) {
		lastTalk = who;
		bg.visible = true;
		var sfx = hxd.Res.sfx.voice;
		this.sfx = sfx.play(true);
		int = new h2d.Interactive(Game.W,Game.H,this);
		int.onClick = function(_) click();
		this.text = text;
		timer = new haxe.Timer(30);
		timer.run = updateText;
	}

	override function onDelete() {
		super.onDelete();
		if( sfx != null )
			sfx.stop();
		if( timer != null )
			timer.stop();
	}

	function updateText() {
		if( textPos == text.length ) {
			timer.stop();
			onReady();
			if( sfx != null ) sfx.stop();
			talk.currentFrame = 0;
			talk.speed = 0;
			return;
		}
		if( sfx != null ) {
			switch( text.charCodeAt(textPos) ) {
			case " ".code, "\n".code: sfx.volume = 0; talk.speed = 0;
			default: talk.speed = 10; if( sfx.volume == 0 ) sfx.volume = 1 else sfx.volume *= 0.9;
			}
		}
		textPos++;
		tf.text = text.substr(0, textPos);
	}

	public function click() {
		if( textPos == text.length ) {
			lastTalkTime = haxe.Timer.stamp();
			onClick();
		} else if( textPos < text.length ) {
			textPos = text.length;
			tf.text = text;
			updateText();
		}
	}

	public dynamic function onClick() {
	}

	public dynamic function onReady() {
	}

	function set_text(t) {
		text = t;
		tf.text = "";
		textPos = 0;
		return t;
	}

	function set_width(w) {
		bg.width = w;
		tf.maxWidth = w - 14;
		tf.text = text;
		return width = w;
	}

	function set_height(h) {
		bg.height = h;
		return height = h;
	}

}