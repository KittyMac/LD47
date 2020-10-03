function initPixi() {

	// create the application and attach it to the document
	let app = new PIXI.Application({
		backgroundColor: 0x000000, 
		antialias: false,
		preserveDrawingBuffer: false
	});
		
	let pixi = document.getElementById("pixi")
	if (pixi != undefined) {
		pixi.appendChild(app.view);
		app.resizeTo = pixi
	} else {
		document.body.appendChild(app.view);
		app.resizeTo = document
	}

	// go fullscreen
	app.frameTime = 0
	app.frameTimeCheck = 0
	
	// for ios, let them zoom and scroll
	app.renderer.plugins.interaction.autoPreventDefault = false;
    app.renderer.view.style.touchAction = 'auto';

	// ResizeObserver doesn't exist on mobile safari
	if (typeof ResizeObserver != "undefined") {
		const resizeObserver = new ResizeObserver(entries => {
			app.render()
		});
		resizeObserver.observe(app.view);
	}

	return app;
}

function calculateResScale(app) {
	if (app.renderer.width > app.renderer.height) {
		return app.renderer.width / 1024.0
	}
	return app.renderer.height / 1024.0
}

function consistentFrameRate(app, msPerFrame = 16) {
	if (app.frameTimeCheck == 0) {
		app.frameTimeCheck = 1
		app.frameTime += app.ticker.deltaMS
	}
	if (app.frameTime > msPerFrame) {
		app.frameTime -= msPerFrame
		return true
	}
	app.frameTimeCheck = 0
	return false
}

function makeSprite(app, textureName) {
	let texture = PIXI.utils.TextureCache[textureName];
	const sprite = new PIXI.Sprite(texture);
	sprite.anchor.set(0.5, 0.5)
	app.stage.addChild(sprite);
	return sprite
}

function makeTilingSprite(app, textureName, width, height) {
	if (width == undefined) {
		width = app.renderer.width
	}
	if (height == undefined) {
		height = app.renderer.height
	}
	let texture = PIXI.utils.TextureCache[textureName];
	const sprite = new PIXI.extras.TilingSprite(texture, width, height);
	sprite.anchor.set(0.5, 0.5)
	app.stage.addChild(sprite);
	return sprite
}