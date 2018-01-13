import Foundation

extension String {
    func lets<T>(_ block: ((T) -> Void)) {
        block(self as! T)
    }
}