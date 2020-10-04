import Foundation

// swiftlint:disable all

public extension Pamphlet {
    static func StyleCss() -> String {
#if DEBUG
let filePath = "/Volumes/Development/Development/chimerasw2/LD47/Resources/style.css"
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
#pixi {
	z-index:-1;
	left:0px;
	top:0px;
	margin:0px;
	padding:0px;
	width: 100%;
	height: 100%;
	position: fixed;
}

/* LOGIN DIALOG */

#welcomeDialog {
	position: fixed;
	top: 0;
	left: 0;
    background-color: #FFFFFF;
	width: 800px;
	height: 460px;
	
	top: 50%;
    left: 50%;
    margin-left: -400px;
    margin-top: -230px;
	
    border-radius: 1.5em;
    box-shadow: 0px 11px 35px 2px rgba(0, 0, 0, 0.14);
	opacity: 0.0;
    pointer-events: none;
	padding-top: 0px;
}

#playerName {
    width: 76%;
    color: rgb(38, 50, 56);
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 1px;
    background: rgba(136, 126, 126, 0.04);
    padding: 10px 20px;
    border: none;
    border-radius: 20px;
    outline: none;
    box-sizing: border-box;
    border: 2px solid rgba(0, 0, 0, 0.02);
    margin-bottom: 50px;
    font-family: 'Ubuntu', sans-serif;
}

#playButton { 
    width: 50%;
	
	font-family: zekton;
    
    margin-top: 50px;

	padding-left: 2em;
	padding-right: 2em;
	padding-bottom: 0.5em;
	padding-top: 0.5em;
	font-size: 1.0em; 
	background: linear-gradient(to top, #91b53b, #afd359);
	text-decoration: none; 
	border: none; 
	color: #fff; 
	border-radius: 5em;
	cursor: pointer; 
	outline: none; 
	transition: 0.2s all; 
}

#playButton:active { 
	transform: scale(0.98); 
} 


/* FLEXBOX HELPERS */

.container {
	left:0px;
	top:0px;
	margin:0px;
	padding:0px;
	width: 100%;
	height: 100%;
	position: fixed;
}

.fill {
	width: 100%;
	height: 100%;
}

.vstack {
	display: flex;
	flex: 1 1 auto;
	flex-direction: column;
}

.hstack {
	display: flex;
	flex: 1 1 auto;
	flex-direction: row;
}

.header {
	height: 2.0em;
}

.center {
	display: flex;
	justify-content: center;
	align-items: center;
}

.grow {
	flex: 1 1 auto;
}

.nogrow {
	flex: 0 0 auto;
}

.content {
	color:white;
	background: rgba(0, 0, 0, 0.4);
}

.red {
	background-color: red;
}

.green {
	background-color: green;
}

.yellow {
	background-color: yellow;
}
"""###
#endif
}
}


public extension Pamphlet {
    static func StyleCssGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7VVXU/bMBR9Jr/CUjXRoiYk/QLK0xCwISGYNk3i1U2c1MOxI8ehKWj/fffGTtNQtIdJa2mw7+fxObfuoOA1J2/e0avPZcLqpR9dekeCpWYZFjUsjSrcKqc649JtCpokXGZut+GJWS9JFIafYLdmPFub3bZQJTdcySVJec2SS++3552ekPvHL3cP5PruMyzIyannDTZMxCpn15wKlSGmg8wGDQlbhLgi8FrR+DnTqpKJHyuh9JIMbptXB+08tEhbbLOF3buSc0SKpWzd3dae2bdWf2aL7DmaZH8ydcUaMEonTPuaJrwqgYRgznIHU9V+uaaJ2gDyoiZRBI/pHB4T+OhsRYfhmLi/IJqNoKQqaMzNFhICd9hCcWmgAXth0kADqSTrBLGIGjhA86AQdMv0A80Z8InZjo6zhTug4wuaD6fnYzg4fBYj60uVNP7GEXYWhnvWkr8yONuspUMwg5hKRAtTQaLW0UmztCeMposxiSbtA441c+3akYK5QUp2VFtC24N+QHEXqiojuGT92BrRNoVdHpj6lZH+UgmeHIgQTkY9vVfKGJXjgLQtGzpSmnMBIh3/XFXSVMdjUlJZ+iXTPO2EuKogWZI3sq9EM2owhr06r+wZIm2Dg3GzvTvF7XBOcMp2Nm1F6xtb8KEdyXcj44z78gYhmIh3tC8i8ku1nyH5MIBDowjkj8ngIlrNpytY0DSZzi9weA2rjZ+wWGlqv8aNLFhwX1LYt9/aNE07905fCyyudIlBbv4xri83GIwG2t2VEQaTklAhwN4XYEljw18Y6mATUqWBlTKmgg3D4OJ8hCnEa26p2/ubp6vHJ/L15v7bzfcfzUUVxMARhcYaL6n/flcGKRcCO/0tE+NeSgNCYWTCSzwvVBEMe+I/iIQ3rYxyBj/hmsW2GwhQ5dKWWf97Ga02rgajiaWnhTlphqlxxgwF/KjBr6o0PN36SDAEAa4mFDxU8Ez63LC87KxYDOZyg6XeY0OfVH1vCO/O65qg287fZg31L/vj/v5CwMsKkzVLMPHwl0e3qmWaMflxTOOyUVsmhIV4GGZ9EPcHRGD/aqUHAAA=")