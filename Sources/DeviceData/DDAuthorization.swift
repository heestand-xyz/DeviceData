public enum DDAuthorization {
    case notNeeded
    case notDetermined
    case restricted
    case denied
    case authorizedWhenInUse
    case authorizedAlways
    case unknown
}

extension DDAuthorization {
    public var authorized: Bool {
        [.authorizedAlways, .authorizedWhenInUse].contains(self)
    }
}
