public struct SwiftTools {
    var text = "Hello, World!"
}

public enum ANSIColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"     // error
    case green = "\u{001B}[0;32m"   // success
    case yellow = "\u{001B}[0;33m"  // warning
    case blue = "\u{001B}[0;34m"    // info
    case magenta = "\u{001B}[0;35m" // important
    case cyan = "\u{001B}[0;36m"    // tips
    case white = "\u{001B}[0;37m"   // unimportant
    case `default` = "\u{001B}[0;0m"
    
    public func name() -> String {
        switch self {
        case .black: return "Black"
        case .red: return "Red"
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        case .magenta: return "Magenta"
        case .cyan: return "Cyan"
        case .white: return "White"
        case .default: return "Default"
        }
    }
    
    public static func all() -> [ANSIColors] {
        return [.black, .red, .green, .yellow, .blue, .magenta, .cyan, .white, .default]
    }
    
    public static func + (_ left: ANSIColors, _ right: String) -> String {
        return left.rawValue + right
    }
}



