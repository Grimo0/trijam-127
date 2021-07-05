class Level extends dn.Process {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	public var gridSize(get, never) : Int;
	inline function get_gridSize() return Const.GRID;

	public var cWid(get, never) : Int; inline function get_cWid() return Std.int(pxWid / Const.GRID);
	public var cHei(get, never) : Int; inline function get_cHei() return Std.int(pxHei / Const.GRID);
	public var pxWid(get, never) : Int; inline function get_pxWid() return game.pxWid;
	public var pxHei(get, never) : Int; inline function get_pxHei() return game.pxHei;
	
	public var pot : Pot;

	public function new() {
		super(game);
		createRootInLayers(game.scroller, Const.GAME_SCROLLER_LEVEL);
	}

	public inline function isValid(cx, cy) return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

	public inline function coordId(cx, cy) return cx + cy * cWid;

	public inline function hasCollision(cx, cy) : Bool
		return false; // TODO: collision with entities and obstacles

	public inline function getFloor(cx, cy) : Int
		return 0;

	override function init() {
		super.init();

		if (root != null)
			initLevel();
	}

	public function initLevel() {
		game.scroller.add(root, Const.GAME_SCROLLER_LEVEL);
		root.removeChildren();

		var recipe = Game.getRecipeData(game.id);
		
		var bg = new HSprite(Assets.game, 'SceneBg', Std.int((game.difficulty - 1) * Assets.game.countFrames('SceneBg') / Data.recipes.all.length));
		root.addChildAt(bg, Const.GAME_LEVEL_BG);

		var textIngX = 110;
		var textIngY = 145;

		for (ingData in recipe.ingredients) {
			var txt = new h2d.Text(Assets.fontMedium);
			root.addChildAt(txt, Const.GAME_LEVEL_ENTITIES);
			txt.x = textIngX;
			txt.y = textIngY;
			txt.text = Std.string(ingData.quantity);
			txt.textColor = 0x000000;
			txt.alpha = .6;
			textIngX += 3;
			textIngY += 40;

			if (ingData.quantity <= 0) {
				continue;
			}

			var ing = new Ingredient(ingData.kind);
			root.addChildAt(ing, Const.GAME_LEVEL_ENTITIES);
			ing.x = ingData.x * game.pxWid;
			ing.y = ingData.y * game.pxHei;
		}

		pot = new Pot();
		root.addChildAt(pot, Const.GAME_LEVEL_ENTITIES);
		var potSize = pot.getSize();
		pot.x = 0.65 * game.pxWid - potSize.width / 2;
		pot.y = 0.75 * game.pxHei - potSize.height / 2;
	}
}
