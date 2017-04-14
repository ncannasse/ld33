class Level {

	var ldata : Data.LevelData;
	var content : h2d.Sprite;
	public var root : h2d.Layers;
	public var width : Int;
	public var height : Int;
	var game : Game;
	var bg : h2d.TileGroup;
	var trees : Array<h2d.TileGroup>;
	public var bgData : Array<Int>;
	public var treesData : Array<{ x : Int, y : Int, t : Int }>;

	public function new() {
		game = Game.inst;
		content = new h2d.Sprite(game.s2d);
		root = new h2d.Layers(content);

		root.scale(1.5);
		root.filters = [new h2d.filter.Bloom()];

		var grid = new h2d.Bitmap(hxd.Res.pixelGrid.toTile(), content);
		grid.tile.setSize(Game.W*2, Game.H*2);
		grid.tileWrap = true;
		grid.alpha = 0.5;
		grid.scale(0.5);


		ldata = Data.levelData.all[0];
		width = ldata.width;
		height = ldata.height;
		for( l in ldata.layers ) {
			switch( l.name ) {
			case "bg":
				bgData = l.data.data.decode();
			case "trees":
				var d = l.data.data.decode();
				treesData = [];
				var i = 1;
				while( i < d.length ) {
					var x = d[i++];
					var y = d[i++] + 1;
					var t = d[i++];
					if( t > 32 ) continue;
					treesData.push( { x:x >> 4, y:y >> 4, t: t - 16 } );
				}
			default:
				trace(l.name);
			}
		}
		init();
	}

	function dispose() {
		if( bg != null )
			bg.remove();
		if( trees != null )
			for( t in trees )
				t.remove();
	}

	public function init() {
		dispose();
		var tiles = hxd.Res.tiles.toTile();
		var tall = tiles.gridFlatten(16);
		bg = new h2d.TileGroup(tiles);
		root.add(bg, 0);
		root.under(bg);
		for( y in 0...height )
			for( x in 0...width ) {
				var t = bgData[x + y * width] - 1;
				if( t < 0 ) continue;
				bg.add(x * 16, y * 16, tall[t]);
			}

		var props = ldata.props.getTileset(Data.levelData, ldata.layers[0].data.file);
		var grounds = new cdb.TileBuilder(props, 16, 256).buildGrounds(bgData, width);
		var i = 0;
		while( i < grounds.length ) {
			var x = grounds[i++];
			var y = grounds[i++];
			var t = grounds[i++];
			bg.add(x * 16, y * 16, tall[t]);
		}


		trees = [];
		var curT = null, curY = -1;
		var trees = [for( i in 0...16 ) tiles.sub(i * 16, 16, 16, 32, 0, -32)];
		for( t in treesData ) {
			if( curY != t.y ) {
				curT = new h2d.TileGroup(tiles);
				root.add(curT, 1);
				this.trees.push(curT);
				curT.y = (t.y + 1) * 16;
				curY = t.y;
			}
			if( t.t < 0 || t.t > 16 ) {
				continue;
			}
			curT.add(t.x * 16, 0,trees[t.t]);
		}
	}

}
