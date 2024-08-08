//
//  Utils.swift
//
//
//  Created by John on 8/8/24.
//

import UIKit

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hex: Int = Int(hexString, radix: 16)!
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 8) & 0xff) / 255
        let blue = CGFloat((hex >> 0) & 0xff) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

final class ImageProvider {
    static func loadImage(named name: String) -> UIImage? {
        let bundle = Bundle.module
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}

final class FontProvider {
    static func registerFont(withName name: String) {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: name, withExtension: "otf"),
              let data = try? Data(contentsOf: url),
              let provider = CGDataProvider(data: data as CFData),
              let font = CGFont(provider) else {
            return
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}
