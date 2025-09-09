public protocol DDEngine: Sendable {
    init()
    var isAuthorized: Bool { get }
    func authorizeIfNeeded() async -> Bool
    @MainActor
    func startAll()
    @MainActor
    func stopAll()
}
