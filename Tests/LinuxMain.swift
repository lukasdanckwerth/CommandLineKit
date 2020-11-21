import XCTest
import CommandLineKitTests

var tests = [XCTestCaseEntry]()
tests += TestArguments.allTests()
tests += TestArgumentsInvalidValues.allTests()
tests += TestConfiguation.allTests()
tests += TestOptions.allTests()
tests += TextInfixOperators.allTests()
XCTMain(tests)
