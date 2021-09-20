//
//  Theme.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 19.05.2021.
//

import UIKit

// MARK: -
// MARK: Lossy codable
extension Theme {
    struct Collection: Codable {
        @LossyCodableList var themes: [Theme]
    }
}

// MARK: -
// MARK: ThemeType
extension Theme {
    
    struct HexColor {
        let hexValue: String
        
        var color: UIColor? {
            UIColor(hex: hexValue)
        }
        
        static func color(from hexValue: String) -> HexColor? {
            let hexColor = HexColor(hexValue: hexValue)
            guard hexColor.color != nil else { return nil }
            
            return hexColor
        }
    }

    struct Icon {
        let imageName: String
        
        var thumbnailName: String {
            "\(imageName)_thumbnail"
        }
        
        var image: UIImage? {
            UIImage(named: imageName)
        }
        
        var thumbnail: UIImage? {
            UIImage(named: thumbnailName)
        }
        
        static func icon(from imageName: String) -> Icon? {
            let icon = Icon(imageName: imageName)
            guard icon.image != nil && icon.thumbnail != nil
            else {
                return nil
            }
            return icon
        }
    }
    
    enum ThemeType {
        case color(HexColor)
        case local(Icon)
        case url(String)
    }
}

// MARK: -
// MARK: Struct declaration
struct Theme: Codable {
    
    let title: String
    let font: String
    let type: ThemeType
    
    init(title: String, font: String, type: ThemeType) {
        self.title = title
        self.font = font
        self.type = type
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case font
        case backgroundColor = "bg_color"
        case backgroundUrl = "bg_url"
        case backgroundImageName = "bg_image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        font = try container.decode(String.self, forKey: .font)
        
        let localImageName = try? container.decode(String.self, forKey: .backgroundImageName)
        let colorHex = try? container.decodeIfPresent(String.self, forKey: .backgroundColor)
        let urlString = try? container.decode(String.self, forKey: .backgroundUrl)
        
        if let requierdLocalImageName = localImageName, let requiredIcon = Icon.icon(from: requierdLocalImageName) {
            self.type = .local(requiredIcon)
        } else if let requiredColorHex = colorHex, let requiredColor = HexColor.color(from: requiredColorHex) {
            self.type = .color(requiredColor)
        } else if let requiredURLString = urlString {
            self.type = .url(requiredURLString)
        } else {
            throw DecodingError.valueNotFound(ThemeType.self,
                                              .init(codingPath: [CodingKeys.backgroundImageName,
                                                                 CodingKeys.backgroundColor,
                                                                 CodingKeys.backgroundUrl],
                                                    debugDescription: "value of type ThemeType not found"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(font, forKey: .font)
        
        switch type {
        case .color(let color):
            try container.encode(color.hexValue, forKey: .backgroundColor)
        case .local(let icon):
            try container.encode(icon.imageName, forKey: .backgroundImageName)
        case .url(let url):
            try container.encode(url, forKey: .backgroundUrl)
        }
    }
}

extension Theme: Equatable {
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.title == rhs.title
    }
}
