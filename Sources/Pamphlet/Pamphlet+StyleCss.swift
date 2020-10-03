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
"""###
#endif
}
}


public extension Pamphlet {
    static func StyleCssGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACAz3HQQqAIBAF0HWeQoiWgm3tNMKYfigdaiApunsupN17I6NCP2q4DTKF6sy8qGELqzjLtVEKd+3+iMg97ImQY98FkuT0bO3UlgJikr9cTghKdnpFDbSo9wNHXQ61dQAAAA==")