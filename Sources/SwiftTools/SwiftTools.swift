import Foundation

/*
 终端色值显示
 */
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

/*
 执行shell命令 并获取结果
 *  shellPath:  命令行启动路径
 *  arguments:  命令行参数
 *  returns:    命令行执行结果，积压在一起返回

 *  使用示例
    let (res, rev) = CommandRunner.sync(shellPath: "/usr/sbin/system_profiler", arguments: ["SPHardwareDataType"])
    print(rev)
    
    let rev = shell("ls -a")
 */
public func shell(_ command: String) -> String {
    let utf8Command = "export LANG=en_US.UTF-8\n" + command
    let (_, rev) = shell(shellPath: "/bin/bash", arguments: ["-c", utf8Command])
    return rev
}

public func shell(shellPath: String, arguments: [String]? = nil) -> (Int, String) {
#if os(macOS)
    let task = Process()
    let pipe = Pipe()
    
    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    task.environment = environment
    
    if arguments != nil {
        task.arguments = arguments!
    }
    
    task.launchPath = shellPath
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: String.Encoding.utf8)!
    
    task.waitUntilExit()
    pipe.fileHandleForReading.closeFile()
    return (Int(task.terminationStatus), output)
#else
    return (-1, "当前设备不支持")
#endif
}

/*
 * 发送钉钉功能: https://ding-doc.dingtalk.com/doc#/serverapi2/qf2nxq
 * token: 标识发送到哪个群
 * content: 发送内容
 */
public func sendDingDingMsg(token: String, content: [String:Any]) -> Bool {
    if token.count == 0 {
        print("token 不能为空")
        return false
    }
    // dd207283de26beea832e4a936fe31bdf7fdcaa0f87d039d66db70f91b9bf0c47
    let dingUrl = "https://oapi.dingtalk.com/robot/send?access_token=\(token)"
   
    var request = URLRequest.init(url: URL(string: dingUrl)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let httpBody = try JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)
        request.httpBody = httpBody
    } catch {
        print("content 不能为空")
        return false
    }
    let semaphore = DispatchSemaphore(value: 0)
    var sendSuccess = false
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let resData = data else {
            semaphore.signal()
            return
        }
        do {
            let result: [String:Any] = try JSONSerialization.jsonObject(with: resData, options: .allowFragments) as! [String : Any]
            // result: { "errcode":310000, "errmsg":"keywords not in content" }
            let success = result["errcode"] as! Int == 0
            sendSuccess = success
            if !sendSuccess {
                print(result["errmsg"] ?? "")
            }
        } catch {
            print("发送失败, 请重试")
        }
        semaphore.signal()
    }.resume()
    semaphore.wait()
    return sendSuccess
}
