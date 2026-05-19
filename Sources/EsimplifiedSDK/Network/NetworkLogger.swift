import Foundation
import os.log

struct NetworkLogger {

    private let logger = Logger(subsystem: "io.esimplified.sdk", category: "Network")
    let isEnabled: Bool

    func logRequest(method: String, url: String) {
        guard isEnabled else { return }
        logger.info("➡️ \(method) \(url)")
    }

    func logResponse(method: String, url: String, statusCode: Int, duration: TimeInterval) {
        guard isEnabled else { return }
        let emoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        logger.info("\(emoji) \(method) \(url) — \(statusCode) (\(String(format: "%.0f", duration * 1000))ms)")
    }

    func logError(method: String, url: String, error: Error) {
        guard isEnabled else { return }
        logger.error("❌ \(method) \(url) — \(error.localizedDescription)")
    }
}
