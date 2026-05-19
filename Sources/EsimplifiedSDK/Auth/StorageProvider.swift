import Foundation

public protocol StorageProvider {
    func save(_ value: String, forKey key: String) throws
    func retrieve(forKey key: String) -> String?
    func delete(forKey key: String) throws
    func clear() throws
}
