import Foundation
import os.log

struct NetworkLogger {

    private let logger = Logger(subsystem: "io.esimplified.sdk", category: "Network")
    let isEnabled: Bool

    func logRequest(method: String, url: String, headers: [String: String]?, body: Data?) {
        guard isEnabled else { return }
        logger.info("➡️ \(method) \(url)")
        if let headers {
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                let safeValue = key.lowercased() == "authorization" ? "\(value.prefix(20))..." : value
                logger.info("   📋 \(key): \(safeValue)")
            }
        }
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            logger.info("   📦 Body: \(bodyString)")
        }
    }

    func logResponse(method: String, url: String, statusCode: Int, duration: TimeInterval, body: Data?) {
        guard isEnabled else { return }
        let emoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        logger.info("\(emoji) \(method) \(url) — \(statusCode) (\(String(format: "%.0f", duration * 1000))ms)")
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            let truncated = bodyString.count > 500 ? String(bodyString.prefix(500)) + "..." : bodyString
            logger.info("   📥 Response: \(truncated)")
        }
    }

    func logError(method: String, url: String, error: Error) {
        guard isEnabled else { return }
        logger.error("❌ \(method) \(url) — \(error.localizedDescription)")
    }
}
