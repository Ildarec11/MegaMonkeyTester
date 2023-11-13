//
//  ScreenElementsHelper.swift
//  MegaMonkeyTester
//
//  Created by i.arslambekov on 10.11.2023.
//

import Foundation
import XCTest

final class ScreenElementsHelper {

    func elementIsWithinWindow(element: XCUIElement) -> Bool {
        guard element.exists && !CGRectIsEmpty(element.frame) && element.isHittable else { return false }
        return CGRectContainsRect(XCUIApplication().windows.element(boundBy: 0).frame, element.frame)
    }

    func getExistingElements() -> [XCUIElement] {
        let app = XCUIApplication()
        var allExistingElements = [XCUIElement]()
        for element in app.windows.allElementsBoundByIndex {
            if element.exists {
                allExistingElements.append(element)
            }
        }
        return allExistingElements
    }

    func getHittableButtons() -> [XCUIElement] {
        let app = XCUIApplication()
        var allHittableElements = [XCUIElement]()
        for i in 0..<app.buttons.count {
            let element = app.buttons.element(boundBy: i)
            if element.isHittable {
                allHittableElements.append(element)
            }
        }
        return allHittableElements
    }
}
