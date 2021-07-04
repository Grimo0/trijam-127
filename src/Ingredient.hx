import hxd.Event;

class Ingredient extends Interactive {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	var id : String;
	var content : h2d.Bitmap;

	public function new(id : String) {
		super(0, 0);
		
		this.id = id;
		
		var bowlBack = Assets.game.getBitmap('BowlBack', this);
		content = Assets.game.getBitmap('Ingredient${id}', this);
		var bowlFront = Assets.game.getBitmap('BowlFront', this);
		
		bowlBack.y = (content.tile.height/* - bowlBack.tile.height*/) / 2;
		bowlFront.y = bowlBack.y;

		var size = getSize();
		width = size.width;
		height = size.height;

		filter = new h2d.filter.DropShadow(0, 0.785, 0xCCCCFF, 1., 4, 1, 1, true);
		filter.enable = false;
	}

	override function onOver(e:Event) {
		filter.enable = true;
	}

	override function onOut(e:Event) {
		filter.enable = false;
	}

	override function onPush(e:Event) {
		
	}
}