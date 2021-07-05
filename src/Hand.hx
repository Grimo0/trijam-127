class Hand extends h2d.Object {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	var open : h2d.Bitmap;
	var hold : h2d.Bitmap;
	
	public function new() {
		super();

		open = Assets.game.getBitmap('HandOpen', this);
		hold = Assets.game.getBitmap('HandHold', this);
	}
}