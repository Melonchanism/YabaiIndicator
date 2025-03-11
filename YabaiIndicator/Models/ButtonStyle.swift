//
//  ButtonStyle.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 03/01/2022.
//

import Foundation
import Defaults

@objc
enum ButtonStyle : Int, Identifiable, CaseIterable, Defaults.Serializable {
    case numeric
    case windows
    
    var id: Int { rawValue }
}
