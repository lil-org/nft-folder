// ∅ 2025 lil org

import Foundation

enum MetadataKind: String, CaseIterable {
    case description
    case keywords
    case name
    case subtitle
    case promotionalText = "promotional_text"
    case releaseNotes = "release_notes"
    case marketingURL = "marketing_url"
    case privacyURL = "privacy_url"
    case supportURL = "support_url"
    case appleTvPrivacyPolicy = "apple_tv_privacy_policy"
    
    var fileName: String {
        return rawValue
    }
    
    var toTranslate: Bool {
        switch self {
        case .description, .keywords, .name, .subtitle, .promotionalText, .releaseNotes:
            return true
        case .marketingURL, .privacyURL, .supportURL, .appleTvPrivacyPolicy:
            return false
        }
    }
    
    var isCommonForAllPlatforms: Bool {
        switch self {
        case .description, .releaseNotes, .keywords, .promotionalText:
            return false
        case .marketingURL, .privacyURL, .supportURL, .appleTvPrivacyPolicy, .name, .subtitle:
            return true
        }
    }
    
}
