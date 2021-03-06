import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TestArguments.allTests),
        testCase(TestArgumentsInvalidValues.allTests),
        testCase(TestConfiguation.allTests),
        testCase(TestCommands.allTests),
        testCase(TextInfixOperators.allTests)
    ]
}
#endif
