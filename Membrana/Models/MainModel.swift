//
//  MainModel.swift
//  Membrana
//
//  Created by Fedor Bebinov on 14.12.22.
//

import Foundation
import UIKit

struct MainModel {

    let fingerPrintImage = UIImage(named: "fingerprint")

    struct Sound {
        static let grom = ("grom", "mp3")
        static let solnce = ("zvuk_solnca", "mp3")
        static let dojd = ("rain", "mp3")
    }

    struct LottieNamed {
        static let lightning = "lightning"
        static let double_tap = "double_tap_lighting"
        static let rain = "rain"
    }

    struct GestureTitle {
        static let contact = "Контакт"
        static let grom = "Гром"
        static let dojd = "Дождь"
        static let svet = "Свет"
    }

    struct Images {
        static let fingerPrintImageName = "fingerprint"
        static let backgroundImageName = "bg_image"
    }
}
