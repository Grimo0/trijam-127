import hxd.snd.Channel;
import en.Entity;
import dn.Process;

class Game extends Process {
	public static var ME : Game;

	public static var sav : GameSave = new GameSave();

	public static function getRecipeData(id : String) {
		return Data.recipes.get(cast(id, Data.RecipesKind));
	}

	/** Game controller (pad or keyboard) **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	/** Particles **/
	public var fx : Fx;

	/** Basic viewport control **/
	public var camera : Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller : h2d.Layers;

	/** Level data **/
	public var level : Level;

	/** UI **/
	public var hud : ui.Hud;

	public var locked(default, set) = false;
	public function set_locked(l) {
		if (l)
			ca.lock();
		else
			ca.unlock();
		return locked = l;
	}
	public var started(default, null) = false;
	
	public var pxWid(get, never) : Int;
	function get_pxWid() return M.ceil(w() / Const.SCALE);

	public var pxHei(get, never) : Int;
	function get_pxHei() return M.ceil(h() / Const.SCALE);

	public var curGameSpeed(default, null) = 1.0;
	var slowMos : Map<String, {id : String, t : Float, f : Float}> = new Map();

	var flags : Map<String, Int> = new Map();

	var difficulty = 1;
	public var id(default, null) : String;

	public var timerLen(default, set) : Float;
	public function set_timerLen(t) {
		timerLen = t;
		timer = timerLen;
		return timerLen;
	}
	public var timer(default, set) : Float;
	public function set_timer(t) {
		timer = t;
		hud.updateTimer();
		return timer;
	}

	public var hand : Hand;

	public var musicChannel : Channel;

	public function new() {
		super(Main.ME);
		ME = this;

		flags = sav.flags.copy();
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);

		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_GAME);

		scroller = new h2d.Layers();
		root.add(scroller, Const.GAME_SCROLLER);

		camera = new Camera();
		camera.frict = 0.1;
		camera.targetS = 0.1;
		level = new Level();
		fx = new Fx();
		hud = new ui.Hud();
		
		hand = new Hand();
		root.addChildAt(hand, Const.GAME_CURSOR);

		function onCursorMove(event : hxd.Event) {
			if (isPaused()) return;
			if (event.kind != EMove || !hand.canMove()) return;

			var cursorSize = hand.getSize();
			hand.x = event.relX - M.sign(hand.scaleX) * cursorSize.width / 6;
			hand.y = event.relY - cursorSize.height / 3;
			if (hand.scaleX < 0 && hand.x <  1.5 * cursorSize.width)
				hand.scaleX = -hand.scaleX;
			else if (hand.scaleX > 0 && hand.x > pxWid -  1.5 * cursorSize.width)
				hand.scaleX = -hand.scaleX;
		}
		hxd.Window.getInstance().addEventTarget(onCursorMove);

		// Hide Cursor
		hxd.System.setCursor = (c) -> {
			if (!hand.visible || ui.Modal.hasAny()) {
				hxd.System.setNativeCursor(Default);
			} else {
				hxd.System.setNativeCursor(Hide);
			}
		};

		root.alpha = 0;
		startLevel();
		tw.createS(root.alpha, 1, #if debug 0 #else 1 #end);
	}

	public static function load() {
		sav = hxd.Save.load(sav, 'save/game');
	}

	public function save() {
		sav.flags = flags.copy();

		hxd.Save.save(sav, 'save/game');
	}

	public inline function setFlag(k : String, ?v = 1) flags.set(k, v);

	public inline function unsetFlag(k : String) flags.remove(k);

	public inline function hasFlag(k : String) return getFlag(k) != 0;

	public inline function getFlag(k : String) {
		var f = flags.get(k);
		return f != null ? f : 0;
	}

	function startLevel(?id = 'recipe1') {
		locked = false;
		started = false;

		scroller.removeChildren();

		this.id = id;

		level.init();

		var recipe = getRecipeData(this.id);
		timerLen = recipe.timer;
		tw.createS(timer, 0, TType.TLinear, timerLen).end(() -> gameOver());

		// Music
		if (recipe.weird)
			musicChannel = Assets.musicWeird.play(true);
		else
			musicChannel = Assets.musicNormal.play(true);
		musicChannel.volume = 0;

		resume();
		Process.resizeAll();
	}

	public function transition(id : String, event : String = null, ?onDone : Void->Void) {
		locked = true;
		var time = #if debug 0 #else .3 #end;
		if (musicChannel != null) {
			var ch = musicChannel;
			musicChannel.fadeTo(0, time, () -> {
				ch.stop();
			});
		}

		Main.ME.tw.createS(root.alpha, 0, time).onEnd = function() {
			if (onDone != null)
				onDone();

			startLevel(id);

			musicChannel.fadeTo(1, time);
			Main.ME.tw.createS(root.alpha, 1, time);
		}
	}
	
	public function gameOver() {
		locked = true;
		// new ui.EndGameMenu(true);
		delayer.addF(()-> transition('recipe${difficulty}'), 1);
	}

	public function success() {
		locked = true;
		pause();
		Assets.musicWin.play().onEnd = () -> resume();
		if (difficulty == 4) {
			// new ui.EndGameMenu(true);
		} else
			delayer.addF(()-> transition('recipe${++difficulty}'), 1);
	}

	/** CDB file changed on disk**/
	public function onCdbReload() {
		startLevel();
	}

	/** Window/app resize event **/
	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for (e in Entity.ALL)
			e.destroy();
		gc();
	}

	/** Garbage collect any Entity marked for destruction **/
	function gc() {
		if (Entity.GC == null || Entity.GC.length == 0)
			return;

		for (e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	public function addSlowMo(id : String, sec : Float, speedFactor = 0.3) {
		if (slowMos.exists(id)) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		} else
			slowMos.set(id, {id: id, t: sec, f: speedFactor});
	}

	function updateSlowMos() {
		// Timeout active slow-mos
		for (s in slowMos) {
			s.t -= utmod * 1 / Const.FPS;
			if (s.t <= 0)
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for (s in slowMos)
			targetGameSpeed *= s.f;
		curGameSpeed += (targetGameSpeed - curGameSpeed) * (targetGameSpeed > curGameSpeed ? 0.2 : 0.6);

		if (M.fabs(curGameSpeed - targetGameSpeed) <= 0.001)
			curGameSpeed = targetGameSpeed;
	}

	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}

	override function preUpdate() {
		super.preUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.preUpdate();
	}

	/** Main loop but limited to 30fps (so it might not be called during some frames) **/
	override function fixedUpdate() {
		super.fixedUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.fixedUpdate();
	}

	/** Main loop **/
	override function update() {
		super.update();

		if (!started) {
			if (ca.startPressed()) {
				started = true;
			}
		}

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.update();

		#if debug
		if (Main.ME.debug) {
			updateImGui();
		}
		#end

		if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
			#if hl
			// Exit
			if (ca.isPressed(START)) {
				if (cd.hasSetS("exitWarn", 3))
					return Main.ME.startMainMenu();
			}
			#end

			// Restart
			if (ca.selectPressed())
				Main.ME.startGame();
		}
	}

	#if debug
	function updateImGui() {
		var natArray = new hl.NativeArray<Single>(1);

		natArray[0] = Const.MAX_CELLS_PER_WIDTH;
		if (ImGui.sliderFloat('Const.MAX_CELLS_PER_WIDTH', natArray, -1, 100, '%.0f')) {
			Const.MAX_CELLS_PER_WIDTH = Std.int(natArray[0]);
			scroller.setScale(Const.SCALE);
		}

		ImGui.alignTextToFramePadding();
		ImGui.text('Scroller');
		ImGui.sameLine(0, 5);
		ImGui.pushItemWidth(ImGui.getColumnWidth() / 4);
		natArray[0] = scroller.x;
		if (ImGui.sliderFloat('##x', natArray, 0, pxWid, 'x %.0f'))
			scroller.x = natArray[0];
		ImGui.sameLine(0, 2);
		natArray[0] = scroller.y;
		if (ImGui.sliderFloat('##y', natArray, 0, pxHei, 'y %.0f'))
			scroller.y = natArray[0];
		ImGui.sameLine(0, 2);
		natArray[0] = scroller.scaleX;
		if (ImGui.sliderFloat('##scalex', natArray, 0, 2, 'sX %.2f'))
			scroller.scaleX = natArray[0];
		ImGui.sameLine(0, 2);
		natArray[0] = scroller.scaleY;
		if (ImGui.sliderFloat('##scaley', natArray, 0, 2, 'sY %.2f'))
			scroller.scaleY = natArray[0];
		ImGui.popItemWidth();
	}
	#end

	override function postUpdate() {
		super.postUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.postUpdate();
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.finalUpdate();
		gc();

		// Update slow-motions
		updateSlowMos();
		setTimeMultiplier((0.2 + 0.8 * curGameSpeed) * (ucd.has("stopFrame") ? 0.3 : 1));
	}
}
