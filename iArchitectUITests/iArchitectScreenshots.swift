import XCTest

final class iArchitectScreenshots: XCTestCase {

    var app: XCUIApplication!
    let outputDir = "/Users/aisrasto/iOS/Screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true   // keep capturing even if one step fails
        app = XCUIApplication()
        app.launch()
        Thread.sleep(forTimeInterval: 3)
    }

    func test_captureAllScreenshots() {
        // ── 1. Architectures Hub ─────────────────────────────────
        saveScreenshot("01_architectures_hub")

        // Scroll to reveal Clean + TCA cards
        app.swipeUp()
        Thread.sleep(forTimeInterval: 1)
        saveScreenshot("02_architectures_hub_scrolled")
        app.swipeDown()
        Thread.sleep(forTimeInterval: 1)

        // ── 2. MVVM Detail ────────────────────────────────────────
        tapText("Model-View-ViewModel")
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("03_mvvm_demo_tab")

        // Add a task to populate the demo
        let tf = app.textFields["New task…"]
        if tf.waitForExistence(timeout: 3) {
            tf.tap(); tf.typeText("Buy groceries")
            app.buttons["Add"].tap(); Thread.sleep(forTimeInterval: 0.5)
            tf.tap(); tf.typeText("Read Swift book")
            app.buttons["Add"].tap(); Thread.sleep(forTimeInterval: 0.5)
            saveScreenshot("04_mvvm_demo_with_tasks")
        }

        app.buttons["Code"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("05_mvvm_code_tab")

        app.buttons["Diagram"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("06_mvvm_diagram_tab")

        app.buttons["Concepts"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("07_mvvm_concepts_tab")

        navigateBack()

        // ── 3. VIPER Detail ───────────────────────────────────────
        tapText("VIPER")
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("08_viper_demo_tab")

        let viperTF = app.textFields["New task…"]
        if viperTF.waitForExistence(timeout: 2) {
            viperTF.tap(); viperTF.typeText("Finish VIPER module")
            app.buttons["Add"].tap(); Thread.sleep(forTimeInterval: 0.5)
            saveScreenshot("09_viper_demo_with_task")
        }

        app.buttons["Diagram"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("10_viper_diagram")

        app.buttons["Concepts"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("11_viper_concepts")
        navigateBack()

        // ── 4. TCA Detail ─────────────────────────────────────────
        app.swipeUp(); Thread.sleep(forTimeInterval: 1)
        tapText("Unidirectional / TCA-inspired")
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("12_tca_demo_tab")

        let tcaTF = app.textFields["New task…"]
        if tcaTF.waitForExistence(timeout: 2) {
            tcaTF.tap(); tcaTF.typeText("Learn TCA pattern")
            app.buttons["Add"].tap(); Thread.sleep(forTimeInterval: 0.5)
        }
        // Show action log
        let logBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Action Log'")).firstMatch
        if logBtn.waitForExistence(timeout: 2) {
            logBtn.tap(); Thread.sleep(forTimeInterval: 1)
        }
        saveScreenshot("13_tca_action_log")
        navigateBack()
        app.swipeDown()

        // ── 5. Interview Prep ─────────────────────────────────────
        app.tabBars.buttons["Interview Prep"].tap()
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("14_interview_prep_list")

        tapText("Memory Management")
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("15_topic_overview")

        // Expand first concept
        tapText("ARC")
        Thread.sleep(forTimeInterval: 0.5)
        saveScreenshot("16_topic_concept_expanded")

        app.buttons["Code"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("17_topic_code_tab")

        // Quiz
        app.buttons["Quiz"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("18_quiz_question_1")

        // Answer: tap first option button
        let answerBtns = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Automatic'"))
        if answerBtns.firstMatch.waitForExistence(timeout: 3) {
            answerBtns.firstMatch.tap(); Thread.sleep(forTimeInterval: 1)
            saveScreenshot("19_quiz_answer_feedback")
            app.buttons["Next Question"].tap(); Thread.sleep(forTimeInterval: 1)
            saveScreenshot("20_quiz_question_2")
        }
        navigateBack()

        // ── 6. Comparison View ────────────────────────────────────
        app.tabBars.buttons["Compare"].tap()
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("21_comparison_layers")

        app.buttons["Pros & Cons"].tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("22_comparison_pros_cons")

        app.buttons["Code"].firstMatch.tap(); Thread.sleep(forTimeInterval: 1)
        saveScreenshot("23_comparison_code")

        // ── 7. Progress View ──────────────────────────────────────
        app.tabBars.buttons["Progress"].tap()
        Thread.sleep(forTimeInterval: 2)
        saveScreenshot("24_progress_view")
    }

    // MARK: - Helpers

    private func tapText(_ text: String) {
        let el = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
        if el.waitForExistence(timeout: 4) { el.tap() }
    }

    private func navigateBack() {
        let backBtn = app.navigationBars.buttons.firstMatch
        if backBtn.waitForExistence(timeout: 2) { backBtn.tap(); Thread.sleep(forTimeInterval: 1) }
    }

    private func saveScreenshot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        if let data = shot.image.pngData() {
            let url = URL(fileURLWithPath: "\(outputDir)/\(name).png")
            try? data.write(to: url)
        }
        let att = XCTAttachment(screenshot: shot)
        att.name = name; att.lifetime = .keepAlways
        add(att)
    }
}
