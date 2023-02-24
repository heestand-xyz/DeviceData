import Foundation

public protocol DDObject: ObservableObject {
    
    associatedtype T
    associatedtype E: DDEngine
   
    var authorization: DDAuthorization { get }
    var available: Bool { get }
    var active: Bool { get set }
    
    init(engine: E)
    
    var value: T? { get }
    var valuePublisher: Published<T?>.Publisher { get }
}
