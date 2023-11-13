//
//  UserDefaultsManager.swift
//  MegaMonkeyTester
//
//  Created by i.arslambekov on 08.11.2023.
//

import Foundation

final class UserDefaultsManager {

    let sharedDefaults = UserDefaults.standard

    var blackList: [Path]
    var finalPassed: [Path] = []
    var checkingTransitionPath: Path = Path(steps: [])

    var crashReports: [CrashReport] = []

    init() {
        let decoder = JSONDecoder()
        if let encodedBlackList = sharedDefaults.object(forKey: UserDefaultsKeys.blackList.rawValue) as? Data, let list = try? decoder.decode([Path].self, from: encodedBlackList) {
            blackList = list
        } else {
            blackList = []
        }

        if let encodedFinalPassed = sharedDefaults.object(forKey: UserDefaultsKeys.finalPassed.rawValue) as? Data, let passed = try? decoder.decode([Path].self, from: encodedFinalPassed) {
            finalPassed = passed
        } else {
            finalPassed = []
        }

        if let encodedCheckingTransitionPath = sharedDefaults.object(forKey: UserDefaultsKeys.checkingTransitionPath.rawValue) as? Data, let transitionPath = try? decoder.decode(Path.self, from: encodedCheckingTransitionPath) {
            checkingTransitionPath = transitionPath
        } else {
            checkingTransitionPath = Path(steps: [])
        }

        if let encodedReport = sharedDefaults.object(forKey: UserDefaultsKeys.crashReport.rawValue) as? Data, let reports = try? decoder.decode([CrashReport].self, from: encodedReport) {
            crashReports = reports
        } else {
            crashReports = []
        }
    }

    func addPathToFinalPassed(path: Path) {
        finalPassed.append(path)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(finalPassed) {
            sharedDefaults.set(data, forKey: UserDefaultsKeys.finalPassed.rawValue)
        }
    }

    func addPathToBlackList(path: Path) {
        blackList.append(path)

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(blackList) {
            sharedDefaults.set(data, forKey: UserDefaultsKeys.blackList.rawValue)
        }
    }

    func addToReports(crashReport: CrashReport) {
        crashReports.append(crashReport)

        print("-- append to crash report")

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(crashReports) {
            sharedDefaults.set(data, forKey: UserDefaultsKeys.crashReport.rawValue)
        }
    }

    func registerCheckingTransitionPath(path: Path) {
        checkingTransitionPath = path

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(checkingTransitionPath) {
            sharedDefaults.set(data, forKey: UserDefaultsKeys.checkingTransitionPath.rawValue)
        }
    }

    func cleanTransitionPath() {
        sharedDefaults.removeObject(forKey: UserDefaultsKeys.checkingTransitionPath.rawValue)
    }

    func cleanAllData() {
        sharedDefaults.removeObject(forKey: UserDefaultsKeys.blackList.rawValue)
        sharedDefaults.removeObject(forKey: UserDefaultsKeys.finalPassed.rawValue)
        sharedDefaults.removeObject(forKey: UserDefaultsKeys.checkingTransitionPath.rawValue)
        sharedDefaults.removeObject(forKey: UserDefaultsKeys.crashReport.rawValue)
    }

    func shouldPressButton(currentPath: Path, buttonId: String) -> Bool {
        let possibleLastStep = Step(identifier: buttonId)
        var possibleFinalPath = currentPath
        possibleFinalPath.steps.append(possibleLastStep)
        if blackList.contains(where: { $0.steps == possibleFinalPath.steps }) || finalPassed.contains(where: { $0.steps == possibleFinalPath.steps }) {
            return false
        }

        var possibleNotFinalPath = currentPath
        possibleNotFinalPath.steps.append(Step(identifier: buttonId))
        if blackList.contains(where: { $0.steps == possibleNotFinalPath.steps }) || finalPassed.contains(where: { $0.steps == possibleNotFinalPath.steps }) {
            return false
        } else {
            return true
        }
    }
}
