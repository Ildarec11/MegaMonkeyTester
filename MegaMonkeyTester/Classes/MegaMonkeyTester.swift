import XCTest

public class MegaMonkeyTester {

    var navigator = TestNavigator()

    public init() {}

    public func startMonkeyTesting(app: XCUIApplication) {
        navigator.startIterations(app: app)
    }
}
