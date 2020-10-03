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
        
        // because i always make this mistake!
        print = console.log
        
        // The conversion from board units to screen units
        const kBoardToScreen = 50
        const kNodeSize = 25
        
        var lastBoardUpdate = {}
        var lastBoardUpdateCX = 0
        var lastBoardUpdateCY = 0
        
        const boardGfx = new PIXI.Graphics();
        app.stage.addChild(boardGfx);
                
        function animationUpdate() {
            // 0. Did the screen change size since the last time we drew the board? if so, we
            // should redraw it so that it stays centered
            let cx = app.renderer.width / 2
            let cy = app.renderer.height / 2
            
            if (lastBoardUpdateCX != cx || lastBoardUpdateCY != cy) {
                updateBoard(lastBoardUpdate);
            }
        }
        
        function getNextNode(nodes, current, idx) {
            let nextIdx = current.c[idx];
            if (nextIdx != undefined) {
                return nodes[nextIdx];
            }
            return undefined;
        }
        
        function getNodePos(node, cx, cy) {
            return [node.x * kBoardToScreen + cx, node.y * kBoardToScreen + cy]
        }
        
        function updateBoard(board) {
            let cx = app.renderer.width / 2
            let cy = app.renderer.height / 2
            
            lastBoardUpdate = board;
            lastBoardUpdateCX = cx;
            lastBoardUpdateCY = cy;
            
            // -1. we want to center the board around the player's nodeidx
            let nodes = board.nodes;
            
            let player = board.player;
            if (player != undefined) {
                let node = nodes[player.nodeIdx];
                cx -= node.x * kBoardToScreen;
                cy -= node.y * kBoardToScreen;
            }
            
            boardGfx.clear()
            
            // 0. draw all of the lines connecting the nodes
            boardGfx.lineStyle(5, 0x373737, 1);
            for (i in nodes) {
                let node = nodes[i];
                let posA = getNodePos(node, cx, cy);
                
                for (j in node.c) {
                    let nextNode = getNextNode(nodes, node, j);
                    if (nextNode != undefined) {
                        let posB = getNodePos(nextNode, cx, cy);
                        boardGfx.moveTo(posA[0], posA[1]);
                        boardGfx.lineTo(posB[0], posB[1]);
                    }
                }
            }
            
            // 1. draw all of the nodes
            boardGfx.lineStyle(0);
            for (i in nodes) {
                let node = nodes[i];
                boardGfx.beginFill(0xbdbdbd, 1);
                let pos = getNodePos(node, cx, cy);
                boardGfx.drawCircle(pos[0], pos[1], kNodeSize);
                boardGfx.endFill();
            }
        }
        
        gameUpdateLongPoll(function (info) {
            if (info.tag == "BoardUpdate") {
                updateBoard(info)
            }
            if (info.tag == "PlayerInfo") {
                print(info)
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
            
            animationUpdate()
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7VY30/jOBB+718xm5dL70pa2OU4iZbTwWoREkLo4KQ9IR7cxE0MqV3ZLm1ut//7zdhNaZM0sA8bJEjsb359Mx7bdDrDD4mKbTHjkNlpftYZln84S846gM9wyi2DOGPacDsK5nZy8EewnrLC5vzs+vOnk2Hfv/vxXMhn0DwfBcYWOTcZ5zaATPPJeiSKjUElw763MzSxFjMLRsejIGdjFj3h9LDvhyvzsZpO2+ZnYimiqZBvYths1oZJ82jKrBbLBmWd4VglxTraRLyASLxSAuG3n/HTa51E8iiwfGn7T+yF+dE1kRswPegWjEBIYW9RYditI/p9GPOYzQ0HASxfsMLAlD1zsJnAN2EsfnzYwGdaSIsqYyWNQu5zlTbqvM84YV64NkJJmGg1hbFiOoE5OmPAKkCvOZf+eyNKei08nxP0Xt15yAiOB1XEjUr4nfiP4+TRcd2FF6YhZ8Y6Rf/MEmYJ+W3VBrj4ipBBK+LfHUTFJxff5WSJGMkXcHv19Sq61GyWidiE3dPtpERIa8ojliQXmciTsBTdQtWMTOYytkQmkwKLCd+8U2EXvu1IIf2DCD6LBHPIS5px0ckUv4gyI2TM3STFB1ZMOSw4JBq9plHnzZ8gJmBUD2eq2k2m5nmCizLRbAECa1yhHLPu1VIFxVxajvM7kjm3EBM7RIDmMkGEjhYisRn04aiOLarYjIs0szXwzgd6HdYT+2FEpr9/b8goTRVVDumZO4QDVzVW8vRaVqvO/ryl3N7gkqXKDSX+Mj2I5xqDsz1c88uqC0SBRPxVQpytkVH8gNDH01rIJRKjmSNbEyF50hSU5nauJTj7D2uhx33RbAlslJ6+O1Y0cauMCxUjXfYaaF4rfyBMtIRfqyv/NyfnZovG2eLxXe5sp9JVdxPZP7826x3JOXPaBnJdKV62Y6gvxcXpfsu4ag8OI1rlC4YNHNuvX6Kv6x2YVphkNzDLWcH1L8Yxj/VWr0sqn9L9yH21GCcJr3Ij4j/rZbyGvVXFpQ/Ual0leznnSb2gXYtewoEHN9RZA7zYwIs34Kv9gZdtPYpzzvTW9tuUH+zZrp+yPAc18e0Z4ze0u0iOdSxTN+gCbjZD+Ds6E4XHPRgsP57QTw8OK+1qojSEAo8FXte7CBYNnLq8KvMXgvat95b9bMebp9KbKG5yZ7sf3ni3Grqpt/zUYHS7Szr5twqsEuJ5JcS1mpYwa7mZqhd+r0Li62Hw2HPEPRw+vkeU0upFz0vR8/2iq077yKq1Cg/rVfiughv8pBrbmBrzVMgvIs/DwXKc0E+9sLcy9kM1uTFCoV8IjcuV2C7JRq57ryfONnncDJyLP3I+SNmU+zZ+rWR6q1B8s2+FQk5UlTsqZBqP8AwJoxEEWztB8NZBxilsqYea8lvXWa9wqFG3uxC0al013Do6rweAFK8YXHsrYXDJlU550IN2CrauHxXbrdZow84Vww17665Cp/AwMDMWk91Aze21wlLru5HoaZYG3RraNeYdtBupoJ2tMPQWexirUXMd02IYndXO7M7cHdLpzgV0BfMfITqNhrx/lbrqe7M7UvcCx9Id2dLbo5OPh7hoBkefui27de16sTuLFFoRP+NmS0yEDbHQs8BrDQ8pTZReab9orPK/WenS4e/dfV233XxDO9sXy2rf5vN69XZDw76/fw/7/v8V/wNsN6PsyRAAAA==")