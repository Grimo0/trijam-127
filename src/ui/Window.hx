package ui;

class Window extends dn.Process {

	public function new() {
		super(Main.ME);

		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_UI);

		dn.Process.resizeAll();
	}

	override function onResize() {
		super.onResize();

		root.scale(Const.UI_SCALE);
	}

	function onClose() {}

	public function close() {
		if (!destroyed) {
			destroy();
			onClose();
		}
	}
}
