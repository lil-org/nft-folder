// ∅ 2025 lil org

import SwiftUI

struct Images {
    
    static let close = Image(systemName: "xmark")
    static let preferences = Image(systemName: "gearshape")
    static let pip = Image(systemName: "pip")
    static let play = Image(systemName: "play")
    
}

extension Notification.Name {
    
    static let togglePip = Notification.Name("togglePip")
    static let restoreMinimizedPip = Notification.Name("restoreMinimizedPip")
    
}
