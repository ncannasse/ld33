enum Action {
	Buldozer;
}

class Game extends hxd.App {

	public static inline var W = 400;
	public static inline var H = 300;

	var talk : Talk;
	var level : Level;
	var curAction : Action;
	var cursor : h2d.Bitmap;
	var cunder : h2d.Bitmap;
	var icons : Array<h2d.Tile>;
	var actions : Array<{ b : h2d.Bitmap, act : Action }>;
	var onUI = false;
	var goldText : h2d.Text;
	public var state : State;
	public var event : hxd.WaitEvent;
	public var font : h2d.Font;

	override function init() {
		inst = this;
		event = new hxd.WaitEvent();
		font = hxd.Res._8bit.toFont();
		s2d.setFixedSize(W, H);
		talk = new Talk();
		level = new Level();
		actions = [];
		icons = hxd.Res.icons.toTile().gridFlatten(16);
		cunder = new h2d.Bitmap(icons[16]);
		cursor = new h2d.Bitmap(null);
		cursor.filters = [new h2d.filter.Glow(0, 10000)];
		level.root.add(cunder, 0);
		s2d.add(cursor, 2);
		s2d.addEventListener(onEvent);
		state = try hxd.Save.load(new State()) catch( e : Dynamic ) null;
		if( state == null ) state = new State();
		state.init();
		if( !state.intro ) {
			talk.intro(function() {
				state.intro = true;
				addAction(Buldozer);
				setAction(Buldozer);
				updateGold();
				save();
			});
		} else {
			updateGold();
			for( a in state.actions )
				addAction(a);
			setAction(actions[0].act);
		}
	}

	function updateGold() {
		if( goldText == null ) {
			goldText = new h2d.Text(font, s2d);
			goldText.y = 5;
			goldText.x = 5;
//			new h2d.Bitmap(icons[17], goldText);
		}
		goldText.text = "$" + state.gold;
	}

	function save() {
		hxd.Save.save(state);
	}

	function addAction( act : Action ) {
		var cont = new h2d.Sprite(s2d);
		var a = new h2d.Bitmap(icons[act.getIndex()], cont);
		cont.x = Game.W - (actions.length + 1) * 18 - 5;
		cont.y = 5;
		a.filters = [new h2d.filter.Glow(0, 100000)];
		var i = new h2d.Interactive(16, 16, cont);
		i.onOver = function(_) {
			onUI = true;
			a.filters = [new h2d.filter.Glow(0xFFFF00, 100000)];
		};
		i.onOut = function(_) {
			onUI = false;
			a.filters = [new h2d.filter.Glow(act == curAction ? 0xFFFFFF : 0, 100000)];
		};
		i.onClick = function(_) {
			hxd.Res.sfx.confirm.play();
			setAction(act);
		};
		actions.push( { b:a, act : act } );
		if( state.actions.indexOf(act) < 0 ) state.actions.push(act);
	}

	function onEvent( e : hxd.Event ) {
		switch( e.kind ) {
		case EMove:
			cursor.x = e.relX;
			cursor.y = e.relY;
			cunder.x = Std.int(cursor.x / (16 * level.root.scaleX)) * 16;
			cunder.y = Std.int(cursor.y / (16 * level.root.scaleY)) * 16;
		case EPush:
			if( !cursor.visible ) return;
			execAction(curAction, Std.int(cunder.x/16), Std.int(cunder.y/16));
		default:
		}
	}

	function execAction( act : Action, x : Int, y : Int ) {

		var cost = switch( act ) {
		case Buldozer: 10;
		default: 0;
		}
		if( state.gold < cost ) {
			hxd.Res.sfx.cancel.play();
			return;
		}

		switch( act ) {
		case Buldozer:
			var ok = false;
			var pp = x + y * level.width;
			if( level.bgData[pp] <= 4 ) {
				ok = true;
				level.bgData[pp] += 4;
			}
			for( t in level.treesData )
				if( t.x == x && t.y == y ) {
					ok = true;
					level.treesData.remove(t);
				}
			if( !ok ) {
				hxd.Res.sfx.cancel.play();
				return;
			}
			level.init();
			hxd.Res.sfx.buldoze.play();
			state.buldozeCount++;
			if( state.buldozeCount == 3 )
				talk.startPlant();
		default:
		}

		state.gold -= cost;
		updateGold();
	}

	function setAction( act : Action ) {
		curAction = act;
		cursor.tile = icons[act.getIndex()];
		for( a in actions )
			a.b.filters = [new h2d.filter.Glow(a.act == act ? 0xFFFFFF : 0, 10000)];
	}

	override function update(dt:Float) {
		event.update(dt);
		cunder.visible = cursor.visible = !talk.isLocked() && !onUI;

		#if debug
		if( hxd.Key.isPressed(hxd.Key.BACKSPACE) ) {
			s2d.dispose();
			hxd.Save.save(null);
			new Game(engine);
		}
		#end
	}

	public static var inst : Game;

	static function main() {
		hxd.Res.initEmbed({ compressSounds:true });
		Data.load(hxd.Res.data.entry.getBytes().toString());
		new Game();
	}

}