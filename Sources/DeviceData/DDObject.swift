import Combine

public protocol DDObject: ObservableObject {
    
    associatedtype T
    associatedtype E: DDEngine
    
    var available: Bool { get }
    
    var authorization: DDAuthorization { get }
    var authorizationPublisher: Published<DDAuthorization>.Publisher { get }
    
    var active: Bool { get set }
    var activePublisher: Published<Bool>.Publisher { get }
    
    init(engine: E)
    
    var value: T? { get }
    var valuePublisher: Published<T?>.Publisher { get }
}
