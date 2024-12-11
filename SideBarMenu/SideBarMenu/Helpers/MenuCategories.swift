
import Foundation
import UIKit

enum MenuCategories: String, CaseIterable {
    case first = "Images"
    case second
    case third
    case forth
    
    var imageCase: UIImage? {
        switch self {
        case .first: return UIImage(systemName: "photo.artframe")!
        case .second: return nil
        case .third: return nil
        case .forth: return nil
        }
    }
}
