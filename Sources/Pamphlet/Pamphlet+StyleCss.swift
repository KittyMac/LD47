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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7VVW0/bMBR+Jr/CUjVBUROSXriUpyFgQ0IwbZrEq5s4qYdrR7ZDU9D++86JnaahaA+T1tJgn+vn7zt1ByWvOXkLDl5DLjNWz8PkMjgQLLfzuKxhaVXpVyuqCy79pqRZxmXhd2ue2eWcJHH8CXZLxoul3W5LZbjlSs5JzmuWXQa/g+DkmNw/frl7INd3n2FBjk+CYLBmIlUrds2pUAVi2sts0JC4RYgrAq8FTZ8LrSqZhakSSs/J4LZ5ddDOY4e0xTb1e19yhkixlKu73bozh84a+qQdR5McjttiDRilM6ZDTTNeGSAhmrGVh6nq0CxpptaAvKxJksBjMoPHGD66WNCjeET8X5RMh1BSlTTldgMJkT9sqbi00IC9MGmhgVSSdYI4RA0coHlQCrph+oGuGPCJ2Z6Os1N/QM8XND+anI/g4PA5HTpfrqQN156wszjesRr+yuBs05YOwSxiMogWpoIkraOTZu5OmExORyQZtw841tS3a0cK5gYp2VLtCG0P+gHFXaiqrOCS9WNrRNsU9nlg6ldG+o0SPNsTIR4Pe3ovlLVqhQPStmzoyOmKCxDp8OeikrY6HBFDpQkN0zzvhLiqIFmSN7KrRDNqMIa9Oq/sGSJdg71xc707xd1wjnHKtjbtROsbW/CxG8l3I+ONu/JGMZhIcLArIvJLdVgg+TCAR1YRyB+RwUWymE0WsKB5Npld4PBaVtswY6nS1H2NG1mw4K6ksG+/tXmed+6tvg5YWmmDQX7+Ma4vNxisBtr9lRFHY0OoEGDvCzCnqeUvDHVwCbnSwIpJqWBHcXRxPsQUEjS31O39zdPV4xP5enP/7eb7j+aiilLgiEJjjZfUf78ro5wLgZ3+lolxL8aCUBiZcYPnhSqCYU/8B5HwppVV3hBmXLPUdQMBqpV0ZZb/Xkarta/BaOboaWGOm2FqnClDAT9q8KsyluebEAmGIMDVhIKHCl7IkFu2Mp0Vi8FcrrHUe2zok6rvjeHdeX0TdLv5Wy+h/mV/3N9fCHhZYbJmGSbu//LoVrVCMyY/jmlcLmrDhHAQ98OcD+L+ADJyp9qlBwAA")