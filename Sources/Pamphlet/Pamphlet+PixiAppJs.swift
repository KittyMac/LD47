import Foundation

// swiftlint:disable all

public extension Pamphlet {
    static func PixiAppJs() -> String {
#if DEBUG
let filePath = "/Volumes/Development/Development/chimerasw2/LD47/Resources/pixi.app.js"
if let contents = try? String(contentsOfFile:filePath) {
    if contents.hasPrefix("#define PAMPHLET_PREPROCESSOR") {
        do {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/pamphlet")
            task.arguments = ["preprocess", filePath]
            let outputPipe = Pipe()
            task.standardOutput = outputPipe
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outputData, as: UTF8.self)
            return output
        } catch {
            return "Failed to use /usr/local/bin/pamphlet to preprocess the requested file"
        }
    }
    return contents
}
return "file not found"
#else
return ###"""
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
"""###
#endif
}
}


public extension Pamphlet {
    static func PixiAppJsGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA61UTW8aMRA9s79iyiWLSh1StT0EESkfrZRDU5RwqFT1YHZnWQuvjWxvgET57x3bS2CBSD2EA9odv5l58+ati1plTmgFQgk3FiuR9uA5STqnp5AZ5A7BlQh8sZAi4wHIVQ7cOZ6VIBw4HQC5zuoKlUs6Ep2HwwgULmF8+/uWXW6z0+ek05nybD4zulb5tZbanMNgNQi/PtApV05wKbg9h4JLi32KLQxaNI94Y/hSqNlVXRRomvOk89IbEia2XtAI1HvDh83QfZfoH6/Wt3na9efdXtIRBaQB+2EERAQLoTD3o1MzCjMaAYlfKWSe0jN7FLgMbfwLsRFPONHUyIOJASAxCdmvnac6X/93ma1+L1H8mYailtLSElAlAV4YXuFEVEj4wV7ousRsHuMhvdAGhLZ98JrQgip40roKu6OSWsqkYUCjGzRsIeuZUJYJ5dDw4AjGa6fHBh+J1g0WvJaOGgTJhwnQr1XAD8asW0tkTtdZeRldNYITX+ZkGKe6DxP/moZlGpoarTpxgCthHRC80lMhESwvuBFxSW69QF3sZ9LWuq9r68a9ZVpRFdMGRhu2s1OayAi0MLoIiTtSpGSNxk/tQkzHh9YW/a4MutooL8Ywofdi8z1lXGa1pA+Iej/QS8gMRP1ULe2WInclXLQFLVHMShcn2/bYTzqFs8HnL2zguRyFxTJbXIsiCUbCkxo/vI/uiawn1ofKjtGEGOl39q3Fet9y5LlI8qgfz/YP4OMoEHQimxO9HKXjPx8C/YMOJMmWyZEm8Gm0A9jq5EyNoeJbn0iDi9fHriIVn+PDwoiNEA5XhMS7Tf/wNcUYVQqXW+2EtGwSg9d0K+Kfnay/5JLoSxvK7l6LTaMG7f0UMYyrrNSGWXTpgH3tA/314jDW8Rmd582NEvE+s5koBg5GmghJt+Ybg/UhWKkPO47zq4gGGx1cj038iBtft9iY7jB3c3DMoyH7XQUmlOGUujt9k7o/9HuK/w/v47QZUwcAAA==")