//
//  LogManager.swift
//  MegaMonkeyTester
//
//  Created by i.arslambekov on 08.11.2023.
//

import Foundation

final class LogManager {

    let crashCollectorManager = CrashCollectorManager()
    var userManager: UserDefaultsManager! = nil


    func enableReporter() {
        crashCollectorManager.enableReporter()
    }

    func appendCrashEvent(path: Path) {
        let text = crashCollectorManager.getCrashErrorReport()
        let crashReport = CrashReport(path: path, text: text ?? "-- unknown")
        userManager.addToReports(crashReport: crashReport)
    }
    
    func printFinalResult() {
        let collectedCrasher = userManager.crashReports

        print("-- TEST FINISHED 🙊")

        if collectedCrasher.isEmpty {
            print("-- NOT FOUND ANY CRASHES 🤞")
        } else {
            print("-- ============ FOUND CRASHES ============")
        }
        for crash in collectedCrasher {
            print("-- ===== CRASH ===== ☠️")
            let ids = crash.path.steps.map { $0.identifier }
            var str = ""
            for id in ids {
                str.append(id)
                str.append(" -> ")
            }
            print("-- PATH: \(str)")
            print("-- \(crash.text)")
            print("-- ====    ====")
        }
    }
}
