// By Tom Meagher on 1/24/21 at 13:29

import XCTest

class HorizonUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginError() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accountWindow = XCUIApplication().windows["Account"]
        
        let emailTextField = accountWindow.textFields["Email"]
        emailTextField.click()
        emailTextField.typeText("foo@example.com")
        
        let passwordSecureTextField = accountWindow.secureTextFields["Password"]
        passwordSecureTextField.click()
        passwordSecureTextField.typeText("foobarbaz")
        
        accountWindow.buttons["Login"].click()
        
        let errorMessage = app.staticTexts["wrong credentials"]
        _ = errorMessage.waitForExistence(timeout: 5)
        
        XCTAssertTrue(errorMessage.exists)
    }
    
    func testLoginSuccess() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accountWindow = XCUIApplication().windows["Account"]
        
        guard let email = ProcessInfo.processInfo.environment["FUTURELAND_EMAIL"] else { return }
        guard let password = ProcessInfo.processInfo.environment["FUTURELAND_PASSWORD"] else { return }
        
        let emailTextField = accountWindow.textFields["Email"]
        emailTextField.click()
        emailTextField.typeText(email)
        
        let passwordSecureTextField = accountWindow.secureTextFields["Password"]
        passwordSecureTextField.click()
        passwordSecureTextField.typeText(password)
        
        accountWindow.buttons["Login"].click()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
