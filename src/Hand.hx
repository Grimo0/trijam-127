class Hand extends h2d.Object {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	var open : h2d.Bitmap;
	var hold : h2d.Bitmap;
	public var holding (default, set) : Ingredient;
	public inline function set_holding(h : Ingredient) {
		holding = h;
		open.visible = holding == null;
		hold.visible = !open.visible;
		if (holding != null) {
			ingredient = Assets.game.getBitmap(holding.content.groupName, holding.quantityMax - 1);
			ingredient.x = -3 * ingredient.getSize().width / 2;
			addChildAt(ingredient, 0);
		} else if (ingredient != null) {
			ingredient.remove();
			ingredient = null;
		}
		return holding;
	}

	var ingredient : h2d.Bitmap;
	
	public function new() {
		super();

		open = Assets.game.getBitmap('HandOpen', this);
		hold = Assets.game.getBitmap('HandHold', this);

		var handSize = getSize();
		hold.x = open.x = -handSize.width / 6;
		hold.y = open.y = -handSize.height / 3;

		hold.visible = false;
	}
	
	public inline function canMove() {
		return true;
	}
}