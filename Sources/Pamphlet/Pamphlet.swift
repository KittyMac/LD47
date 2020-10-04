import Foundation

// swiftlint:disable all

public enum Pamphlet {
    public static func get(string member: String) -> String? {
        switch member {
        case "/comm.js": return Pamphlet.CommJs()
        case "/gl.matrix.min.js": return Pamphlet.GlMatrixMinJs()
        case "/index.html": return Pamphlet.IndexHtml()
        case "/laba.js": return Pamphlet.LabaJs()
        case "/pixi.app.js": return Pamphlet.PixiAppJs()
        case "/pixi.min.js": return Pamphlet.PixiMinJs()
        case "/style.css": return Pamphlet.StyleCss()
        default: break
        }
        return nil
    }
    public static func get(gzip member: String) -> Data? {
        #if DEBUG
            return nil
        #else
            switch member {
            case "/comm.js": return Pamphlet.CommJsGzip()
            case "/gl.matrix.min.js": return Pamphlet.GlMatrixMinJsGzip()
            case "/index.html": return Pamphlet.IndexHtmlGzip()
            case "/laba.js": return Pamphlet.LabaJsGzip()
            case "/pixi.app.js": return Pamphlet.PixiAppJsGzip()
            case "/pixi.min.js": return Pamphlet.PixiMinJsGzip()
            case "/style.css": return Pamphlet.StyleCssGzip()
            default: break
            }
            return nil
        #endif
    }
    public static func get(data member: String) -> Data? {
        switch member {
        case "/logo_black.png": return Pamphlet.Logo_blackPng()
        case "/player0.png": return Pamphlet.Player0Png()
        case "/player1.png": return Pamphlet.Player1Png()
        case "/player2.png": return Pamphlet.Player2Png()
        case "/player3.png": return Pamphlet.Player3Png()
        case "/star.png": return Pamphlet.StarPng()
        default: break
        }
        return nil
    }
}
