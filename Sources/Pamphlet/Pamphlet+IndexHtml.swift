import Foundation

// swiftlint:disable all

public extension Pamphlet {
    static func IndexHtml() -> String {
#if DEBUG
let filePath = "/Volumes/Development/Development/chimerasw2/LD47/Resources/index.html"
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


<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>LD47</title>
    <link rel="stylesheet" href="style.css">
</head>
<script src="laba.js"></script>
<script src="comm.js"></script>
<script src="pixi.min.js"></script>
<script src="pixi.app.js"></script>
<script src="gl.matrix.min.js"></script>

<body>
    <div id="pixi"></div>
    
    <script type="text/javascript">
        app = initPixi()
        
        
        let animationUpdate = function() {
            // called 60 times per second
        }
        
        let loadBoard = function(board) {
            // called 60 times per second
        }
        
        gameUpdateLongPoll(function (info) {
            console.log(info)
            
            if (info.tag == "BoardUpdate") {
                
            }
            if (info.tag == "PlayerInfo") {
                
            }
        })
        
        
        registerPlayer("George", function (info) {
            console.log(info)
        })
        
        
        app.loader
        //.add("space", "outLogin/space.jpg")
        //.add("lines", "outLogin/lines.jpg")
        .load((loader, resources) => {
            //spaceSprite = makeSprite(app, "space");
            //linesSprite = makeTilingSprite(app, "lines", 2731, 1024);
            
            update()
            app.ticker.add(() => {
                while(consistentFrameRate(app, 16)) {
                    animationUpdate()
                }
            });
            
        });
                
    </script>
    
</body>
</html>

"""###
#endif
}
}


public extension Pamphlet {
    static func IndexHtmlGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA61Vy47TMBTd5yuMV440JNNhNINE0gVCIKQuKhg+wLVvU7eOHdnu0Ar13/Ej7ZC0FIHwpvG51+fcl90sq15xzdy+A7RyrZxm1fEHKJ9myK+qBUcRW1FjwdV465av3+Le5ISTMJ19uH+syvSdcCnUBhmQNbZuL8GuABxGKwPLHimYtZ6kKpNOZZkRnUPWsBpLuqDF2purMsEjO9Nte83eiZ0oWqH+6EO77ppPI4uWOiN2F8iyaqH5vs+Wi2ckeCINTn6fLMncc4Yi19jBzpVr+kwT2hcyLB8NqpFQws09D8lPhvMPCQ5RJXx0QqtvHacO/NHlVrEAkBz9OLmGVZaIUSmBo4db5EQLFnVgkAWmFT95Hi7rSE35e00N/1VhEYD/JtPQFlIWM62auZaSHJUQEWqpx0qe0Go/RFI3yT6wDjZimSgKRxtU1wjHXJIaHvOenT5c55pLugfz2UN/Q3W41loDjbAOTKIm+BNo0wC+Qf9akatq4QaEBoPJXrpYUM4Jth1lQRfrrZvpRqgyIsW6a3B+5u0vPNiBd0RG3lGLkKR443O1emsY2BzV07NhinJfOyPicLd002+ID9oLpfjyd6NTUXZw6kl4rBmcPUZ79/hmcoMmt3f3I57BZhuHhQyHLFTOCbYBEwtALqQQ1veVkEBCd0JXlfto/Kx/ocdIJg/5pcGJAsP7PZI/H87D71IYG14eptNrFqGqTE+af5PjX8BP0uZhmBwGAAA=")