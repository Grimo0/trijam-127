package ui;

class EndGameMenu extends Modal {
	public var game(get, never) : Game; inline function get_game() return Game.ME;

	var gameOver : Bool;

	public function new(gameOver : Bool, timer = false) {
		super();

		this.gameOver = gameOver;

		root.alpha = 0;
		tw.createMs(root.alpha, 1, TType.TEaseOut, 500);

		// mask.remove();

		var txt = new h2d.Text(Assets.fontLarge, root);
		txt.x = game.pxWid * 0.5;
		txt.y = game.pxHei * 0.25;
		txt.textAlign = Center;
		txt.filter = new h2d.filter.DropShadow(0, 0.785, 0x000000, .7, 5, 1.1, 1, true);

		if (gameOver) {
			if (timer)
				txt.text = Lang.t._('You were too slow !\n\nClick to try again.');
			else
				txt.text = Lang.t._('You have to follow the recipe !\n\nClick to try again.');
		} else {
			txt.text = Lang.t._('Well done, guests were ... delighted.\n\nClick to start again.');
		}

		var i = new h2d.Interactive(game.pxWid, game.pxHei, root);
		i.onClick = function(_) {
			close();
		};
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override public function close() {
		// tw.createMs(root.alpha, 0, TType.TEaseOut, 500).end(() -> {
			if (!destroyed) {
				destroy();
				onClose();
			}
		// });
	}

	override function onClose() {
		game.resume();
	}

	override function update() {
		// super.update();
		/* if (ca.bPressed() || )
			game.resume(); */
	}
}
