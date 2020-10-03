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
        var playerCanMove = false;
        
        const gameContainer = new PIXI.Container();
        app.stage.addChild(gameContainer);
        
        const boardGfx = new PIXI.Graphics();
        gameContainer.addChild(boardGfx);
        
        const nodeText = new PIXI.Text('0000', {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
        nodeText.anchor.set(0.5, 0.5);
        gameContainer.addChild(nodeText);
        
        const playersContainer = new PIXI.Container();
        gameContainer.addChild(playersContainer);
                
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
                
                playerGfx.x += (playerGfx.targetX - playerGfx.x) * 0.06135;
                playerGfx.y += (playerGfx.targetY - playerGfx.y) * 0.06135;
                
                if (Math.abs(playerGfx.targetX - playerGfx.x) < kNodeSize &&
                    Math.abs(playerGfx.targetY - playerGfx.y) < kNodeSize) {
                    playerCanMove = true;
                } else {
                    playerCanMove = false;
                }
                
                if (playerGfx.isPlayer) {
                    gameContainer.x = -(playerGfx.x - app.renderer.width / 2)
                    gameContainer.y = -(playerGfx.y - app.renderer.height / 2)
                }
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
        
        function getNodePos(node) {
            return [node.x * kBoardToScreen, node.y * kBoardToScreen]
        }
        
        function updateBoard(board) {
            lastBoardUpdate = board;
            lastBoardUpdateCX = app.renderer.width;
            lastBoardUpdateCY = app.renderer.height;
            
            // -1. we want to center the board around the player's nodeidx
            let nodes = board.nodes;
            let players = board.players;
            
            boardGfx.clear()
            
            // 0. draw all of the lines connecting the nodes
            boardGfx.lineStyle(5, 0x373737, 1);
            for (i in nodes) {
                let node = nodes[i];
                let posA = getNodePos(node);
                
                for (j in node.c) {
                    let nextNode = getNextNode(nodes, node, j);
                    if (nextNode != undefined) {
                        let posB = getNodePos(nextNode);
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
                let pos = getNodePos(node);
                boardGfx.drawCircle(pos[0], pos[1], kNodeSize);
                boardGfx.endFill();
            }
            
            let thisPlayer = board.player;
            
            // 2. add the players
            for (i in players) {
                let player = players[i];
                let node = getNodeByIdx(nodes, player.nodeIdx);
                if (node != undefined) {
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
                        
                        let pos = getNodePos(node);
                        playerGfx.x = pos[0];
                        playerGfx.y = pos[1];
                    }
                
                    let pos = getNodePos(node);
                    playerGfx.targetX = pos[0];
                    playerGfx.targetY = pos[1];
                    
                    playerGfx.isPlayer = (thisPlayer.id == player.id);
                }
            }
            
            // 3. special stuff for THE player
            if (thisPlayer != undefined) {
                let playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
                let pos = getNodePos(playerNode);
                nodeText.x = pos[0];
                nodeText.y = pos[1] + kNodeSize * 2.5;
                nodeText.text = playerNode.d;
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
        
        // TODO: let the player name themselves and choose when to join the game
        registerPlayer("George", function (info) {
            print(info)
        })
        
        function onPointerDown(event) {
            if (playerCanMove == false) {
                return;
            }
            
            let mousePos = event.data.getLocalPosition(gameContainer)
            
            // find the node nearest the click
            var clickNode = undefined
            var clickNodeDistance = (kNodeSize * 6) * (kNodeSize * 6)
            let nodes = lastBoardUpdate.nodes;
            for (i in nodes) {
                let node = nodes[i];
                let pos = getNodePos(node);
                let dx = (mousePos.x - pos[0])
                let dy = (mousePos.y - pos[1])
                let d = dx * dx + dy * dy;
                
                if (d < clickNodeDistance) {
                    clickNode = node;
                    clickNodeDistance = d;
                }
            }
            
            if (clickNode != undefined) {
                movePlayer(clickNode.id, function (info) {
                    if (info.tag == "BoardUpdate") {
                        updateBoard(info)
                    }
                })
            }
        }
        app.renderer.plugins.interaction.on('pointerdown', onPointerDown);
        
        
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA7Uaa3PauPY7v0Llw2K2xEDStDsFurNJbruZyXYzm9yZdjL5oNgClBiLkUXAt8t/33Mkg1+ycdO9tJPE0nnpvHVMqzV+5QtPxUtG5moRfGiNd78Y9T+0CHzGC6Yo8eZURkxN2is1PfqlnWwprgL24erizbtx3/xt1gMePhHJgkk7UnHAojljqk3mkk2TFdeLIiAy7hs+48iTfKlIJL1JO6AP1H2E7XHfLBf2PbFY1O0v+Ya7Cx4ehKHLZR3MLHAXVEm+sRBrjR+EHyen9fkz4b4hikDwbHbMdkITlTxpK7ZR/Uf6TM1qosg9MH5ALDIhPOTqGgg63TJEv08emEdXESOc0GBN44gs6BMjas7hLx4peHi1B19KHiog6YkwEqD7QMysNG/nDGGemYy4CMlUigV5EFT6ZAXCREQJAlIzFprnPSrSVeTpDEFvxY0BmZDTQRHis/DZDf8fg83j0uZ1QGMmk+2TU5uEFYyGgzJMhtWb8m6O17syq2cqSUAjpTn9d+lThYDftnUA518AZFAL8TUHkQOlIQdnA7Wfi5U21mCU219qic9p+Id4RlmmNIjYqEzLHHBGF+xchIrykEmADtmaXF9+uXT3i053lHU4F1xmxlzq++dzHvhOjkC3ko/2jk/TTZbFJ0mXc+5FWQ45cimXHXo1gxDMeAshk2WAz05nAJ9Oj3ybAtmPdMGDmLwnnd9Z8MwU9yhs4Q6a+D0Z/gJPPAgAYrCZ6k8P4obPQsTxWKiY7GwzUuzYujT05kK6kPmcgXvaI/Dj8LF22NXHMtaMmpuoglORTgajxHm6Cj10sNTVjFc6XfIth1Vwxdfgi+4wTzj3AJlj4JIL7kP6YbsMAfUinMEThljEQ4/pTQwIoviCkTUjvoQj46p2g18Jn5JI9GCnSD2ai1XgQz3xJV0TDulZAB5V+k+Fyc+YkPk5zIAp4qFron9LFvoAId0199Wc9MlxGTYuws4Zn81VCTj3AFI75UzwaoKs//7bkgJwKy7qHD8rDaGBixQLdt3WGmPoEikUpiwKLp+4SA5oKiRxHqHElBzR9dCvQAE2AVFJBsGEfCXy3eN92RH3mK6WDj1xUvS1n8uuVjphntYG/dNJnxWVM6a+kKMsTFcTHrwdnpzWyRVbaX3N0YpraZUW0Dv+oGru0ofosJTjTN366acSMfxUEiuJmSFmM2Z69LSoKLli5UNtCYNa05BEoS7ZPbZSVekBeGRqdJXo+YSI3njkZL3iqCLquw2oxQVqcZFamhe6B06aPm3LtaCcmsGOaLOz+NLf6DIS9aCz3BSVAEG+Zh3Qt0fDjiKPK8iq2AyGUHQAExs1DqJudHalUtJ43y+ucQEghSpSnPFnyNu/XV0RMdWImn85b3DMG3qvKkfgJlY0hLnj91ZL46YLJWMysR1w95FMraThNmqs6QziCrQwBZv6ozo75NQPKkQT7LTvrSSYXVnNoM+aqHyyg3S9OwAt5D994gQS8v9eLNu5E9FtrpCQqK0GLz858LgWkeZVlCsheqettoEMmO/Be9pCECfFjftGzLOFT/cCJUWXWnENNqoD0u14OQfU43y1dwD1zc8RFFwIqzWFAgaRZ3qRtLGBeIPaZpojk1M6kdYXuEnLFjrR7nyufhq17DU4BUuea6TcNdquFzAqne6hZk43Wtg9JKkA7vMgFvSuIQOThbOK/LBng/A3eM93sGfenLzDfz0yLHjuy/LJyN6YiOg3ACo6coManXZD2ou9qmS0C/fPRhxLssBfPfJoYZpNAhr/UBYoHO2scLSETAWnnC0WUJhvhYP6uRvc97Si7ob3TVDRjAb1bId6Vo26/a4Mbelai17XyMEG/yef2rN6YDMefoTbozPYPPj4r+zIGUs18sE9cTzyOZcQlqjlnZJBx71M91aDD3lKi9b8goBi4pjItFeFHFKf6I5dAjfPTCKr6g6S3fo7RHqBqIzpMI20Yik0qDpDlititsloFGlwOF9AhqNklkwvwA8lo35M2IZDd4Vn08M1EbJfrSTSIY25HFkK8L9wBctqR4Ah5PWL72NZReVJJc5weYHdWaJoXpulcvcokCRPb1SL9wB6fqoG2TbMNZUpNyNXw5ybPUntWMuOGFUOavKjroPS52+nqVFSm7yYWDapTac4S7MntTImZqwbuHI6gAH/3/Sy09RGFCpyVqMTfE+StQ0LJsSk2SbQcQI9vB/9iA9+r8jlKUG90OVBQL3YB4hkKoOT1onkqpYmg9EPFfsTl0RL5nEakEitplOdDm9//0/CoHR3yhSsQ+k8LTCfq6tH5mDVFcRquJS0BWM/Nq5ztD1Q6l/kdWbw8zPU2dMaNGXG4akgrj9qPnPASYe57FyJcHYtIA739zCHh1NR1CmqH9fBu2boAu3Mfal9aIypCdb4RYm4McolLFlp6zdZtVS39tdlt39e/Pk+6X123QsJQRf4vIjwrQGUfLileXMhcEwyZyFe5h4FVGhEQb210uvwDJqCXYVz2p+YgMhr90i9Km3S2+TdUxHhNfAHRhdiHTrsGW6WNvMUZnDJEK56tvBdveJCrCL0fHA5LYAL1qUuRMSV8GgAGxxFLbwwqg1+CF1/399DgaWSRcYuXsC9p1axq9KrSTDvQ78a6gJff+ILB0hg2ah6i5Pbwkrl/bswGLDdxP/ly2uj+oCwetjk7MyiR50m1XTt4HEOPE7Ah1XgAO3jhAd+vEZk+CtuOOj2ybhshqpGK2tV+3wvB5Wxqv8DtQfFTDkfqiV4dU5ifI8Exe9QnL84dTZLoTX37e7BQpCbbi2DFbSBkatzDNUnciGWO0uTdXzIOp1ePgvZ3mnmiAeC+pkK3u9jE+y0oyX1MEO2xQoyB3Dt6xX3cTlrd0vQet6Ug9YrBWjNy3EMxx4kt0ispIehOPlQmphrdjeQgvX8EL8tYR4cEBoYGfkKIdc3bHNYtxzWZjncnbTH706G0EYPjt90ay7Spdev+V1QoQJXM5cHx7GcBT9ruFUwB18mYyEK1UcJ+fcvuhNp+LZb5V/17C3BVHWWbdVsLf2WjF4a981XZcZ989WifwAlYNefdCQAAA==")