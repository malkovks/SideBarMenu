import Foundation

enum TransitionStyle: String, CaseIterable {
    case transition
    case push
    case addSuperview
    case gesture
    
    var title: String {
        switch self {
        case .transition: return "Transition"
        case .push: return "Push"
        case .addSuperview: return "Insert Superview"
        case .gesture: return "Gesture"
        }
    }
}
