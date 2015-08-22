enum Char {
	Scientific;
	Hero;
}

class Talk {

	var game : Game;
	var curDialog : Dialog;

	public function new() {
		game = Game.inst;
	}


	public function intro() {
		dialog(Scientific, "Look $name !#We have discovered a beautiful forest!#What a wonderful place, so peaceful and full of beauty and happyness!!!",
		function() {
			select(Hero, "Tear it the f*ck down!|Let's annihilate it!|It will be ground zero soon!", function(r) {
				dialog(Scientific, "WAIT?#~BUT WHY???", function() {
					dialog(Hero, "I need some place to plant my new GMO.#There's a lot of money to make there.", function() {
						dialog(Scientific, "But... but $name, you're already a billionaire!#Why doing this for even more money that you DON'T EVEN NEED?", function() {
							dialog(Hero, "How do you think I became billionaire in the first place?#Because I always want MORE!#Call the bulldozers!", function() {
								dialog(Scientific, "But...#Think about the poor squirrels !#You're...#~YOU'RE A MONSTER !!!", function() {
									dialog(Hero, "Please call me capitalism unleashed!");
								});
							});
						});
					});
				});
			});
		});
	}

	function formatText( t : String ) {
		t = t.split(" !").join("!").split(" ?").join("?");
		t = t.split("$name").join("Mr McDuff");
		return t;
	}

	function select( who : Char, text : String, onEnd : Int -> Void ) {
		var d = new Dialog(who, [for( t in text.split("|") ) String.fromCharCode(8594)+t].join("\n"), true);
		d.onClick = function() {
			d.remove();
			curDialog = null;
			onEnd(d.index);
		};
		curDialog = d;
	}

	function dialog( who : Char, text : String, ?onEnd : Void -> Void ) {
		var lines = [for( l in text.split("#") ) StringTools.trim(l)];
		function next() {
			var l = lines.shift();
			if( l == null ) {
				if( onEnd != null ) onEnd();
				return;
			}

			l = formatText(l);

			var d = new Dialog(who, l);
			d.onClick = function() {
				d.remove();
				curDialog = null;
				next();
			};
			curDialog = d;
		}
		next();
	}

}