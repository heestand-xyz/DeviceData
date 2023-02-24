import Combine

public protocol DDObject {
    
    associatedtype T
    associatedtype E: DDEngine
    
    var available: Bool { get }
    
    var authorization: CurrentValueSubject<DDAuthorization, Never> { get }
    
    var active: CurrentValueSubject<Bool, Never> { get set }
    
    init(engine: E)
    
    var data: CurrentValueSubject<T?, Never> { get }
}
