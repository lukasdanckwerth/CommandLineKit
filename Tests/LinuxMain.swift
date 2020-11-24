import XCTest
import CommandLineKitTests

var tests = [XCTestCaseEntry]()
tests += TestArguments.allTests()
tests += TestArgumentsInvalidValues.allTests()
tests += TestConfiguation.allTests()
tests += TestCommands.allTests()
tests += TextInfixOperators.allTests()
XCTMain(tests)
