//
//  TestNavigator.swift
//  MegaMonkeyTester
//
//  Created by i.arslambekov on 08.11.2023.
//

import Foundation
import XCTest

import CrashReporter

final class TestNavigator {

    var passedSteps: [String] = []
    var currentPath: Path = Path(steps: [])

    var userDefaultsManager: UserDefaultsManager = UserDefaultsManager()
    var screenElementsHelper: ScreenElementsHelper = ScreenElementsHelper()

    var logManager = LogManager()

    func startIterations(app: XCUIApplication) {
        logManager.userManager = userDefaultsManager
        logManager.enableReporter()
        if checkIsFinalScreen() {
            printResult()
            userDefaultsManager.cleanAllData()
        } else {
            checkIsCrashedLastIteration()
            goNext(app: app)
        }
    }

    func printResult() {
        logManager.printFinalResult()
    }

    func checkIsCrashedLastIteration() {
        let transitionPath = userDefaultsManager.checkingTransitionPath
        if !transitionPath.steps.isEmpty {
            userDefaultsManager.addPathToBlackList(path: transitionPath)
            userDefaultsManager.cleanTransitionPath()

            logManager.appendCrashEvent(path: transitionPath)
        }
    }

    // Нажатие кнопки и сохранение
    func goNext(app: XCUIApplication) {
        let allHittableElements = screenElementsHelper.getHittableButtons()
        for button in allHittableElements {
            let identifier = button.identifier
            let shouldPressButton = shouldPressButton(buttonId: identifier)
            if !passedSteps.contains(identifier) && shouldPressButton {
                pressButton(button: button, app: app)

                let isFinalStep = checkIsFinalScreen()
                if isFinalStep {
                    userDefaultsManager.addPathToFinalPassed(path: currentPath)
                    XCTFail()
                    return
                } else {
                    goNext(app: app)
                    return
                }
            }
            // add screen to passed
        }
        userDefaultsManager.addPathToFinalPassed(path: currentPath)
        // go to next iteration
        XCTFail()
        return
    }

    func recoverPossibleCrashData() {

    }

    func pressButton(button: XCUIElement, app: XCUIApplication) {
        var transitionPath = currentPath
        transitionPath.steps.append(Step(identifier: button.identifier))
        userDefaultsManager.registerCheckingTransitionPath(path: transitionPath)

        // crash catch here
        button.press(forDuration: 1)

        userDefaultsManager.cleanTransitionPath()

        currentPath.steps.append(Step(identifier: button.identifier))
        passedSteps.append(button.identifier)
    }


    func checkIsFinalScreen() -> Bool {
        let hittableButtons = screenElementsHelper.getHittableButtons()
        let filtered = hittableButtons.filter({ element in
            return !passedSteps.contains(element.identifier) && shouldPressButton(buttonId: element.identifier)
        })
        return filtered.isEmpty
    }

    private func shouldPressButton(buttonId: String) -> Bool {
        let possibleLastStep = Step(identifier: buttonId)
        var possibleFinalPath = currentPath

        possibleFinalPath.steps.append(possibleLastStep)
        if userDefaultsManager.blackList.contains(where: { $0.steps == possibleFinalPath.steps }) || userDefaultsManager.finalPassed.contains(where: { $0.steps == possibleFinalPath.steps }) {
            return false
        } else {
            return true
        }
    }
}
