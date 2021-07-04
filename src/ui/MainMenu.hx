package ui;

import hxd.Event;
import hxd.Event.EventKind;
import dn.Process;

class MainMenu extends Process {
	public static var ME : MainMenu;

	public var ca(default, null) : dn.heaps.Controller.ControllerAccess;

	public function new() {
		super(Main.ME);
		ME = this;

		ca = Main.ME.controller.createAccess("mainMenu");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);

		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_UI);

		var bg = Assets.ui.getBitmap('menuBackground');
		bg.setScale(1.04);
		root.addChild(bg);

		// Background moving with mouse
		var bgSize = bg.getSize();
		root.getScene().addEventListener(e -> {
			if (e.kind != EventKind.EMove) return;
			bg.x = -e.relX / w() * (bgSize.width - bg.tile.width);
			bg.y = -e.relY / h() * (bgSize.height - bg.tile.height);
		});

		Process.resizeAll();

		delayer.addF(() -> {
			hxd.Window.getInstance().event(new hxd.Event(hxd.Event.EventKind.EMove, root.getScene().mouseX, root.getScene().mouseY));
		}, 1);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	override function update() {
		super.update();

		#if debug
		// Exit
		if (ca.bPressed()) {
			#if hl
			if (!cd.hasSetS("exitWarn", 3))
				trace(Lang.t._("Press ESCAPE again to exit."));
			else
				hxd.System.exit();
			#end

			return;
		}
		#end
	}
}
