// By Tom Meagher on 1/24/21 at 13:29

import XCTest

extension XCUIApplication {
    func statusItem() -> XCUIElement {
        menuBars.children(matching: .statusItem).firstMatch
    }
    
    func statusItemMenu() -> XCUIElement {
        statusItem().menus.firstMatch
    }
    
    func statusItemMenuItem(_ identifier: String) -> XCUIElement {
        statusItemMenu().menuItems[identifier].firstMatch
    }
}

extension HorizonUITests {
    func openPanel() {
        let statusItem = app.statusItem()
        statusItem.click()
        
        let statusItemMenuItem = app.statusItemMenuItem("Open Horizon")
        statusItemMenuItem.click()
    }
    
    func openPreferences() {
        let statusItem = app.statusItem()
        statusItem.click()
        
        let statusItemMenuItem = app.statusItemMenuItem("Preferences")
        statusItemMenuItem.click()
    }
    
    func openPreferencesWindow(_ identifier: String) {
        openPreferences()
        app.radioButtons[identifier].click()
    }
    
    func logIn(email: String, password: String) {
        openPreferencesWindow("Account")
                
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.click()
        emailTextField.typeText(email)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        passwordSecureTextField.click()
        passwordSecureTextField.typeText(password)
        
        let logInButton = app.buttons["Login"]
        XCTAssertTrue(logInButton.exists)
        logInButton.click()
        
        let logOutButton = app.buttons["Log out"]
        _ = logOutButton.waitForExistence(timeout: 5)
        XCTAssertTrue(logOutButton.exists)
    }
    
    func logOut() {
        openPreferencesWindow("Account")
        
        let logOutButton = app.buttons["Log out"]
        XCTAssertTrue(logOutButton.exists)
        logOutButton.click()
        
        let logInButton = app.buttons["Login"]
        XCTAssertTrue(logInButton.exists)
    }
}

class HorizonUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDown() {
        app.terminate()
    }

    func testLoginError() throws {
        logIn(email: "foo@example.com", password: "foobarbaz")

        let errorMessage = app.staticTexts["wrong credentials"]
        _ = errorMessage.waitForExistence(timeout: 5)

        XCTAssertTrue(errorMessage.exists)
    }

    func testLoginSuccess() throws {
        guard let email = ProcessInfo.processInfo.environment["FUTURELAND_EMAIL"] else { return }
        guard let password = ProcessInfo.processInfo.environment["FUTURELAND_PASSWORD"] else { return }

        logIn(email: email, password: password)
        logOut()
    }
    
    func testPublishEntry() throws {
        guard let email = ProcessInfo.processInfo.environment["FUTURELAND_EMAIL"] else { return }
        guard let password = ProcessInfo.processInfo.environment["FUTURELAND_PASSWORD"] else { return }
                
        logIn(email: email, password: password)
        openPanel()
                        
        let journalPopUpButton = app.popUpButtons.firstMatch
        XCTAssertTrue(journalPopUpButton.exists)
        journalPopUpButton.click()
        
        let journalMenuItem = app.menuItems["Horizon Test"]
        XCTAssertTrue(journalMenuItem.exists)
        journalMenuItem.click()
        
        let entryTextView = app.textViews.firstMatch
        XCTAssertTrue(entryTextView.exists)
        entryTextView.click()
        entryTextView.typeText("testPublishEntry")
        
        let publishButton = app.buttons["Publish"]
        XCTAssertTrue(publishButton.exists)
        publishButton.click()
        
        logOut()
    }
}
