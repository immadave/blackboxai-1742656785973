import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    static let shared = Logger()
    private init() {}
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let fileName = (file as NSString).lastPathComponent
        print("[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(message)")
    }
    
    func error(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .error, file: file, line: line)
    }
    
    func warning(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .warning, file: file, line: line)
    }
    
    func debug(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        log(message, level: .debug, file: file, line: line)
        #endif
    }
}