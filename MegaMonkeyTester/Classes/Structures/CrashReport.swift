//
//  CrashReport.swift
//  MegaMonkeyTester
//
//  Created by i.arslambekov on 12.11.2023.
//

import Foundation

struct CrashReport: Equatable, Codable {
    let path: Path
    let text: String
}
