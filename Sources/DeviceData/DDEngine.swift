public protocol DDEngine {
    init()
    var isAuthorized: Bool { get }
    func authorizeIfNeeded() async -> Bool
}
