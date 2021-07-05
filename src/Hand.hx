class Hand extends h2d.Object {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	var open : h2d.Bitmap;
	var hold : h2d.Bitmap;
	public var holding (default, set) : Ingredient;
	public inline function set_holding(h) {
		holding = h;
		open.visible = holding == null;
		hold.visible = !open.visible;
		return holding;
	}
	
	public function new() {
		super();

		open = Assets.game.getBitmap('HandOpen', this);
		hold = Assets.game.getBitmap('HandHold', this);

		hold.visible = false;
	}
	
	public inline function canMove() {
		return true;
	}
}