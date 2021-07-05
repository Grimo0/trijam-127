import hxd.Event;

class Pot extends Interactive {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	var list = new Map<String, Int>();
	
	public function new() {
		super(0, 0);
		
		var panBack = Assets.game.getBitmap('PanBack', this);
		var panFront = Assets.game.getBitmap('PanFront', this);

		var size = getSize();
		width = size.width;
		height = size.height;

		filter = new h2d.filter.DropShadow(0, 0.785, 0x333333, 1., 4, 1, 1, true);
		filter.enable = false;
	}

	public function checkRecipe() {
		var recipe = Game.getRecipeData(game.id);
		var success = true;
		for (ingData in recipe.ingredients) {
			if (ingData.quantity < list.get(ingData.kind)) {
				game.gameOver(false);
				return;
			}
			if (ingData.quantity > list.get(ingData.kind)) {
				success = false;
			}
		}
		if (success)
			game.success();
	}

	override function onOver(e:Event) {
		if (game.hand.holding == null) 
			return;
		filter.enable = true;
	}

	override function onOut(e:Event) {
		filter.enable = false;
	}

	override function onClick(e:Event) {
		if (game.hand.holding == null) 
			return;
		var q = list.get(game.hand.holding.id);
		list.set(game.hand.holding.id, q == null ? 1 : q + 1);
		game.hand.holding = null;
		
		Assets.SLIB.drop(1.);

		checkRecipe();
	}
}