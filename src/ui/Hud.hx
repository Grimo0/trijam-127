package ui;

class Hud extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;

	public var timer : Bar;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.GAME_UI);

		timer = new Bar(game.pxWid, 15, 0xffffff, root);
		timer.y = game.pxHei - timer.outerHeight;
	}

	public function updateTimer() {
		timer.set(game.timer, game.timerLen);
		timer.color = switch game.timer {
			case t if (t < game.timerLen * 0.1): 0xad0000;
			case t if (t < game.timerLen * 0.3): 0xd36c00;
			case _ : 0x256c00;
		};
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		
		timer.y = game.pxHei - timer.outerHeight;
	}
}
