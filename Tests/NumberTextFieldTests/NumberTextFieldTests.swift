import XCTest
@testable import NumberTextField

final class NumberTextFieldTests: XCTestCase {
    func testStringAsIntValidity() throws {
        XCTAssertEqual(NumberTextField.testStringIsValidInt(string:"1"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidInt(string:"123"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidInt(string:""), true)
        XCTAssertEqual(NumberTextField.testStringIsValidInt(string:"1.0"), false)
        XCTAssertEqual(NumberTextField.testStringIsValidInt(string:"abc"), false)
        XCTAssertEqual(NumberTextField.testStringIsValidInt(string:"1a2"), false)
    }
    
    func testStringAsDecimalValidity() throws {
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string: "1"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string: "123"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string: ""), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:"1.0"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:"1.0.1"), false)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:".0"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:".1"), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:"1."), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:"."), true)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:"abc"), false)
        XCTAssertEqual(NumberTextField.testStringIsValidDecimal(string:"1a2"), false)
    }
    
    func testIntTextReplacement() throws {
        let textField = UITextField(frame: .zero)
        textField.text = "123"
        let isInt = true
        var replacementString = "1.0"
        var range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        replacementString = "10"
        range = NSRange(location: 1, length: 0)
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), true)
        
        replacementString = "10"
        range = NSRange(location: 1, length: replacementString.count)
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), true)
        
        replacementString = "1a0"
        range = NSRange(location: 1, length: 0)
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        replacementString = "a"
        range = NSRange(location: 1, length: 0)
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        replacementString = "1.0"
        range = NSRange(location: 0, length: replacementString.count)
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        replacementString = "1.001"
        range = NSRange(location: 0, length: textField.text!.count)
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
    }
    
    func testDecimalTextReplacement() throws {
        let textField = UITextField(frame: .zero)
        textField.text = "1.0"
        let isInt = false
        var replacementString = "1.0"
        var range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        textField.text = "10"
        replacementString = "1.0"
        range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), true)
        
        textField.text = "1.0"
        replacementString = "10"
        range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), true)
        
        textField.text = "10"
        replacementString = "a"
        range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        textField.text = "10"
        replacementString = "1a1"
        range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), false)
        
        textField.text = "1.0"
        replacementString = "1.0"
        range = NSRange(location: 0, length: replacementString.count) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: replacementString, isInt: isInt, textDidChangeAction: {_ in }), true)
        
        textField.text = "1.0"
        replacementString = "1.0"
        range = NSRange(location: 1, length: 0) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testProposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: replacementString), "11.0.0")
        
        textField.text = "1.0"
        replacementString = "1.0"
        range = NSRange(location: 0, length: replacementString.count) //Length 0 when not replacing, just inserting
        XCTAssertEqual(NumberTextField.testProposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: replacementString), "1.0")
    }
}
