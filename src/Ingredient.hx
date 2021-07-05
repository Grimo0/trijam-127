import hxd.Event;

class Ingredient extends Interactive {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	public var id(default, null) : String;
	public var content(default, null) : HSprite;
	public var quantityMax(default, null) : Int;
	public var quantity(default, set) : Int;
	public function set_quantity(q : Int) {
		if (q >= 0 && q <= quantityMax) {
			quantity = q;
			if (quantity == 0)
				content.visible = false;
			else {
				content.visible = true;
				content.setFrame(quantityMax - quantity);
			}
		}
		return quantity;
	}

	public function new(id : String) {
		super(0, 0);
		
		this.id = id;
		
		var bowlBack = Assets.game.getBitmap('BowlBack', this);
		content = new HSprite(Assets.game, 'Ingredient${id}', this);
		var bowlFront = Assets.game.getBitmap('BowlFront', this);
		
		bowlBack.y = content.tile.height / 2;
		bowlFront.y = bowlBack.y;

		var size = getSize();
		width = size.width;
		height = size.height;

		quantity = quantityMax = content.totalFrames();

		filter = new h2d.filter.DropShadow(0, 0.785, 0x333333, 1., 4, 1, 1, true);
		filter.enable = false;
	}

	override function onOver(e:Event) {
		if (game.hand.holding != null && game.hand.holding != this) 
			return;
		filter.enable = true;
	}

	override function onOut(e:Event) {
		filter.enable = false;
	}

	override function onClick(e:Event) {
		if (game.hand.holding == this) {
			game.hand.holding = null;
			quantity++;
			Assets.SLIB.drop(1.);
			return;
		}
		if (game.hand.holding != null) 
			return;
		game.hand.holding = this;
		quantity--;

		Assets.SLIB.pick(1.);
	}
}