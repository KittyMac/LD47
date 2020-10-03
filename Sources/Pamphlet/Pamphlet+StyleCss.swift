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
	height: 400px;
	
	top: 50%;
    left: 50%;
    margin-left: -400px;
    margin-top: -200px;
	
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
    width: 76%;
	
	font-family: zekton;

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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7VVW2+bMBR+Lr/CUjQ1qQKFXHpJnla13SpV7bRpUl8dMMSrsZExDWm1/75zsAmhqfYwaSEQ+1y/852DMyh4zcmbd/Tqc5mweuFHS+9IsNQswqKGpVGFW+VUZ1y6TUGThMvM7TY8MesFicLwE+zWjGdrs9sWquSGK7kgKa9ZsvR+e97pCbl//HL3QK7vPsOCnJx63mDDRKxyds2pUBliOvBs0JCwRYgrAp8VjZ8zrSqZ+LESSi/I4Lb5dNAuQou0xTZzexdyjkgxlI2729qafSv1ndOeonH2J22wBozSCdO+pgmvSiAhmLPcwVS1X65pojaAvKhJFMFjOofHBG6dregwHBP3DaLZCEKqgsbcbMEhcMUWiksDCdgLkwYSSCVZ1xCLqIEDNA8KQbdMP9CcAZ/o7eg4P3MFOr4g+XB6MYbC4T4bWV2qpPE3jrDzMNyTlvyVQW2zlg7BDGIqES1MBYlaRdeaha0wmp6NSTRpH1DWzKVrRwrmBinZUW0JbQv9gOLOVFVGcMn6tjWibQI7PxD1IyP9pRI8OWhCOBn1+r1SxqgcB6RN2dCR0pwLaNLxz1UlTXU8JiWVpV8yzdOuEVcVOEvyRg46AWPYi/PKnsFy6XVttRM4wVHaybTtTF/YIgzt3L2bCyfc72EQgoh4R/udQhKp9jNkGKZsaBQB/zEZXEar+XQFC5om0/klTqhhtfETFitN7bvacI8B9/sG+/bVTNO0U++aaIHFlS7RyA052vV7CgKjgVt3LoTBpCRUCJD3WV7Q2PAXhmRbh1RpYKWMqWDDMLi8GKEL8Zqj6Pb+5unq8Yl8vbn/dvP9R3MaBTFwRCGxxpPovx+IQcqFwEx/80S7l9JAo9Ay4SXWC1EEw5z4A5Zw0cooJ/ATrllss0EDqlzaMOt/D6PVxsVgNLH0tDAnzTA1yphhAz9K8KsqDU+3PhIMRoCrMQUNFTyTPjcsLzspBoO53GCo99hQJ1VfG8LVaV0SVNv526wh/rI/7u/fejyR0FmzBB0P/15027VMMyY/tmlU1mrLhLAQD82sDuz+AFttPpiKBwAA")