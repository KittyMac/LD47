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
    margin-bottom: 20px;
    font-family: 'Ubuntu', sans-serif;
}

#playButton { 
    width: 50%;
	
	font-family: zekton;
    
    margin-top: 20px;

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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7VVW0/bMBR+pr/CEpqgqAlJb0B5GgI2JATTpkm8uomTejh25Tg0Be2/7xzbaRKK9jBpvaTxuX7+vhOXkrcBgVdBdc5lIFhmFiQKp6y47No1z1et4/dgcLjmNYfcg9eAy5TViyC+HBzY9Ghdw61Ra3/nSvjFmqYpl7lfbXhqVgsSR9EnWK2Y6+KXa1Vyw5VckIzXLLVtT0/I/eOXuwdyffcZbsjJKUDZMJGogl1zKlSOmPYyLRoSNQjxDje3pMlzrlUl0yBRQukFOby1rxbaeeSQNtimc7f2JWeIFEu5urtlj85g6op0HDY5GE98MQtG6ZTpQNOUVyWQEM4aDZaqDsoVTdUGkK9rEsdwmczgMoavzpf0OBoR/wnj6RBKqjVNuNmiZH6za8WlgQbshUkDDaSSrBXEIbJwrLqCbpl+oAXz8+HpOJv7DXq+oPnx5HwEG4fvfOh8mZIm2HjCzqKoYy35K4O9TRs6BDOIqUS0MBUkbhytNAu3w3gyH5F43FxgW1PfrhkpmBukZEe1I7TZ6AcUt6GqMoJL1o+tEa0t7PPA1K+M9JdK8HRPhGg87Om9VMaootvS0pHRggsQ6ejnspKmOhqRksoyKJnmWSvEVQXJkryRrhJ21GAMe3Ve2TNEugZ74+Z6t4q74RzjlO1s/jnvGxvwkRvJdyPjjV15wwhMZHDQFRH5pTrIkXwYwGOjCOSPyOFFvJxNlnBDs3Qyu8DhNaw2QcoSpal7jK0sWLArKaybpzbLsta909cBSypdYpCff4zryw0Go4F2f2RE4bgkVAiw9wVY0MTwF4Y6uIRMaWClTKhgx1F4cT7EFDKwp9Tt/c3T1eMT+Xpz/+3m+w97UIUJcEShscZD6r+flWHGhcBOf8vEuJfSgFAYmfIS9wtVBMOe+AOR8KaVUd4QpFyzxHUDAapCujKrfy+j1cbXYDR19DQwx3aYrDNhKOBHDX5VpeHZNkCCIQhw2VDwUMFzGXDDirK1YjGYyw2Weo8NfVL1vRG8W69vgm43f5sV1L/sj/v7AwEPK0zWLMXE/X8e3aiWa8bkxzHW5aK2TAgHcT/M+SDuD2XamVndBwAA")