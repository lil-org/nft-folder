// ∅ 2025 lil org

import SwiftUI

struct Images {
    
    static let close = Image(systemName: "xmark")
    static let preferences = Image(systemName: "gearshape")
    static let pip = Image(systemName: "pip")
    
}

extension Notification.Name {
    
    static let togglePip = Notification.Name("togglePip")
    static let restoreMinimizedPip = Notification.Name("restoreMinimizedPip")
    
}
