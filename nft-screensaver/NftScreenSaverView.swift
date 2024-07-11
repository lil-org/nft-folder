// ∅ nft-folder 2024

import ScreenSaver
import WebKit

class NftScreenSaverView: ScreenSaverView {

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        layer?.backgroundColor = CGColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
