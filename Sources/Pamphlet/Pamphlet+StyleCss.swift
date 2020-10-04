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
a {
    margin-left: 0.4em;
    margin-right: 0.4em;
}

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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7VVW0/bMBR+pr/CEpqgqAlJb0B5GgI2JATTpkm8uomTejh25Dg0Be2/7xzbaRqK9jBpvaTxuX7+vhOXkrcBgVdBdc5lIFhmFiQKp6y43LVrnq86x+/B4LDkDYfcg9eAy5Q1iyC+HBzY9Khs4Nao0t+5En5R0jTlMverNU/NakHiKPoEqxVzXfyyVBU3XMkFyXjDUtv29ITcP365eyDXd5/hhpycApQ1E4kq2DWnQuWIaS/ToiFRixDvcHNLmjznWtUyDRIllF6Qw1v76qCdRw5pi206d2tfcoZIsZSru1326AymrsiOwyYH44kvZsEonTIdaJryugISwlmrwVI1QbWiqVoD8rIhcQyXyQwuY/jqfEmPoxHxnzCeDqGkKmnCzQYl85stFZcGGrAXJg00kEqyThCHyMKx6gq6YfqBFszPh6fjbO436PmC5seT8xFsHL7zofNlSppg7Qk7i6Ida8VfGext2tIhmEFMFaKFqSBx6+ikWbgdxpP5iMTj9gLbmvp27UjB3CAlW6odoe1GP6C4C1W1EVyyfmyDaG1hnwemfmWkv1KCp3siRONhT++lMkYVOCBtS0tHRgsuQKSjn8tamvpoRCoqq6BimmedEFc1JEvyRnaVsKMGY9ir88qeIdI12Bs317tT3A3nGKdsa/PPed/Ygo/cSL4bGW/clTeMwEQGB7siIr9UBzmSDwN4bBSB/BE5vIiXs8kSbmiWTmYXOLyGNSZIWaI0dY+xlQUL7koK6/apzbKsc2/1dcCSWlcY5Ocf4/pyg8FooN0fGVE4rggVAux9ARY0MfyFoQ4uIVMaWKkSKthxFF6cDzGFDOwpdXt/83T1+ES+3tx/u/n+wx5UYQIcUWis8ZD672dlmHEhsNPfMjHupTIgFEamvML9QhXBsCf+QCS8aW2UNwQp1yxx3UCAupCuzOrfy2i19jUYTR09LcyxHSbrTBgK+FGDX3VleLYJkGAIAlw2FDxU8FwG3LCi6qxYDOZyjaXeY0OfVH1vBO/O65ug283fegX1L/vj/v5AwMMKkzVLMXH/n0e3quWaMflxjHW5qA0TwkHcD3M+iPsD9zDyd90HAAA=")