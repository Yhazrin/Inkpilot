import SwiftUI

/// Where a floating panel is anchored on the canvas.
///
/// 8 anchor points cover all 4 edges × center: top/bottom horizontal
/// positions (left, center, right) and left/right vertical positions
/// (center only — there's no "middle-center" because the canvas is the
/// drawing surface).
enum FloatingPanelPosition: String, Codable, CaseIterable {
    case topCenter
    case topLeft
    case topRight
    case middleLeft
    case middleRight
    case bottomCenter
    case bottomLeft
    case bottomRight

    /// SwiftUI alignment for laying out the panel content.
    var alignment: Alignment {
        switch self {
        case .topCenter:    return .top
        case .topLeft:      return .topLeading
        case .topRight:     return .topTrailing
        case .middleLeft:   return .leading
        case .middleRight:  return .trailing
        case .bottomCenter: return .bottom
        case .bottomLeft:   return .bottomLeading
        case .bottomRight:  return .bottomTrailing
        }
    }
}
