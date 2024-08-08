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

enum Font {
    case pretendardBold
    case pretendardSemiBold
    case pretendardRegular
    
    var fontName: String {
        switch self {
        case .pretendardBold: return "Pretendard-Bold"
        case .pretendardSemiBold: return "Pretendard-SemiBold"
        case .pretendardRegular: return "Pretendard-Regular"
        }
    }
    
    var familyName: String { "Pretendard" }
    
    func uiFont(ofSize size: CGFloat) -> UIFont {
        if (UIFont.fontNames(forFamilyName: self.familyName).count == 0) {
            FontProvider.registerFont(withName: "Pretendard-Bold")
            FontProvider.registerFont(withName: "Pretendard-Regular")
            FontProvider.registerFont(withName: "Pretendard-SemiBold")
        }
        switch self {
        case .pretendardBold:
            return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: .bold)
        case .pretendardSemiBold:
            return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: .semibold)
        case .pretendardRegular:
            return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: .regular)
        }
        
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

final class ImageProvider {
    static func loadImage(named name: String) -> UIImage? {
        let bundle = Bundle.module
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
