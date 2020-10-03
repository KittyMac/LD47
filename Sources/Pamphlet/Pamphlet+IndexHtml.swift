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
        const kNodeSize = 20
        const kPlayerSize = 35
        
        //const kBoardToScreen = 10
        //const kNodeSize = 4
        //const kPlayerSize = 7
        
        var lastBoardUpdate = {}
        var lastBoardUpdateCX = 0
        var lastBoardUpdateCY = 0
        
        var animationCount = 0;
        
        const boardGfx = new PIXI.Graphics();
        app.stage.addChild(boardGfx);
        
        const nodeText = new PIXI.Text('0000', {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
        nodeText.anchor.set(0.5, 0.5);
        app.stage.addChild(nodeText);
        
        const playersContainer = new PIXI.Container();
        app.stage.addChild(playersContainer);
                
        function animationUpdate() {
            animationCount += 0.1;
            
            // 0. Did the screen change size since the last time we drew the board? if so, we
            // should redraw it so that it stays centered
            let cx = app.renderer.width / 2
            let cy = app.renderer.height / 2
            
            if (lastBoardUpdateCX != cx || lastBoardUpdateCY != cy) {
                updateBoard(lastBoardUpdate);
            }
            
            // 1. rotate all players
            for (j in playersContainer.children) {
                let playerGfx = playersContainer.children[j];
                playerGfx.rotation = animationCount * 0.1;
            }
        }
        
        
        function getNodeByIdx(nodes, idx) {
            // we've can't just use nextIdx to index the array because we are not
            // given ALL of the nodes
            for (i in nodes) {
                let node = nodes[i]
                if (node.id == idx) {
                    return node;
                }
            }
            return undefined;
        }
        
        function getNextNode(nodes, current, idx) {
            let nextIdx = current.c[idx];
            if (nextIdx != undefined) {
                return getNodeByIdx(nodes, nextIdx);
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
            let players = board.players;
            
            let player = board.player;
            if (player != undefined) {
                let playerNode = getNodeByIdx(nodes, player.nodeIdx);
                if (playerNode != undefined) {
                    cx -= playerNode.x * kBoardToScreen;
                    cy -= playerNode.y * kBoardToScreen;
                                        
                    nodeText.x = cx + 0;
                    nodeText.y = cy + kNodeSize * 2;
                    nodeText.text = playerNode.d;
                }
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
            
            // 2. add the players
            for (i in players) {
                let player = players[i];
                let node = getNodeByIdx(nodes, player.nodeIdx);
                
                // does a graphics already exist for this one?
                var playerGfx = undefined;
                for (j in playersContainer.children) {
                    let otherPlayerGfx = playersContainer.children[j];
                    if (otherPlayerGfx.playerID == player.id) {
                        playerGfx = otherPlayerGfx;
                        break;
                    }
                }
                
                if (playerGfx == undefined) {
                    playerGfx = new PIXI.Graphics();
                    playersContainer.addChild(playerGfx);
                    
                    playerGfx.playerID = player.id;
                    
                    playerGfx.beginFill(0xff0000, 1);
                    playerGfx.drawStar(0, 0, 4, kPlayerSize);
                    playerGfx.endFill();
                }
                
                let pos = getNodePos(node, cx, cy);
                playerGfx.x = pos[0];
                playerGfx.y = pos[1];
                
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
            print(info)
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

private let gzip_data = Data(base64Encoded:"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")