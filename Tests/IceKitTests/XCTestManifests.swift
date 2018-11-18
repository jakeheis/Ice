import XCTest

extension BuildTransformTests {
    static let __allTests = [
        ("testCompile", testCompile),
        ("testCompileC", testCompileC),
        ("testError", testError),
        ("testLink", testLink),
        ("testLinkerError", testLinkerError),
        ("testNoteNoCode", testNoteNoCode),
        ("testNoteOtherModule", testNoteOtherModule),
        ("testPackageError", testPackageError),
        ("testPCHError", testPCHError),
        ("testRepeated", testRepeated),
        ("testSuggestion", testSuggestion),
        ("testUnusedWarning", testUnusedWarning),
        ("testWarningWithSingleNote", testWarningWithSingleNote),
    ]
}

extension ConfigTests {
    static let __allTests = [
        ("testGet", testGet),
        ("testSet", testSet),
    ]
}

extension InitTransformTests {
    static let __allTests = [
        ("testCreateFiles", testCreateFiles),
        ("testCreatePackage", testCreatePackage),
    ]
}

extension LineTests {
    static let __allTests = [
        ("testAssertionFailureLine", testAssertionFailureLine),
    ]
}

extension PackageDataTests {
    static let __allTests = [
        ("testModernize4_0", testModernize4_0),
        ("testSwiftToolsVersion", testSwiftToolsVersion),
    ]
}

extension PackageLoaderTests {
    static let __allTests = [
        ("testBasic", testBasic),
        ("testComplex4_2", testComplex4_2),
        ("testComplex", testComplex),
    ]
}

extension PackageTests {
    static let __allTests = [
        ("testAddDependency", testAddDependency),
        ("testAddProduct", testAddProduct),
        ("testAddTarget", testAddTarget),
        ("testDepend", testDepend),
        ("testRemoveDependency", testRemoveDependency),
        ("testRemoveProduct", testRemoveProduct),
        ("testRemoveTarget", testRemoveTarget),
        ("testUpdateDependency", testUpdateDependency),
    ]
}

extension PackageWriterTests {
    static let __allTests = [
        ("testCanWrite", testCanWrite),
        ("testCLanguageStandard", testCLanguageStandard),
        ("testCxxLanguageStandard", testCxxLanguageStandard),
        ("testDependencies", testDependencies),
        ("testFull", testFull),
        ("testProducts", testProducts),
        ("testProviders", testProviders),
        ("testSwiftLanguageVersions", testSwiftLanguageVersions),
        ("testTargets", testTargets),
    ]
}

extension RegistryTests {
    static let __allTests = [
        ("testAdd", testAdd),
        ("testAutoRefresh", testAutoRefresh),
        ("testGet", testGet),
        ("testRemove", testRemove),
    ]
}

extension RepositoryReferenceTests {
    static let __allTests = [
        ("testGithub", testGithub),
        ("testGitlab", testGitlab),
        ("testMostRecentVersion", testMostRecentVersion),
    ]
}

extension ResolveTransformTests {
    static let __allTests = [
        ("testFetch", testFetch),
        ("testResolve", testResolve),
        ("testUpdate", testUpdate),
    ]
}

extension TestTransformTests {
    static let __allTests = [
        ("testAllTests", testAllTests),
        ("testInterleavedOutput", testInterleavedOutput),
        ("testMultilineEquality", testMultilineEquality),
        ("testNoFilterMatch", testNoFilterMatch),
        ("testNoTests", testNoTests),
        ("testSelectedTests", testSelectedTests),
        ("testSuitePass", testSuitePass),
        ("testXCTAssert", testXCTAssert),
        ("testXCTEquals", testXCTEquals),
        ("testXCTEqualWithAccuracy", testXCTEqualWithAccuracy),
        ("testXCTFail", testXCTFail),
        ("testXCTFalse", testXCTFalse),
        ("testXCTGreaterThan", testXCTGreaterThan),
        ("testXCTGreaterThanOrEqual", testXCTGreaterThanOrEqual),
        ("testXCTLessThan", testXCTLessThan),
        ("testXCTLessThanOrEqual", testXCTLessThanOrEqual),
        ("testXCTNil", testXCTNil),
        ("testXCTNotEquals", testXCTNotEquals),
        ("testXCTNotEqualWithAccuracy", testXCTNotEqualWithAccuracy),
        ("testXCTNoThrow", testXCTNoThrow),
        ("testXCTNotNil", testXCTNotNil),
        ("testXCTThrow", testXCTThrow),
        ("testXCTTrue", testXCTTrue),
    ]
}

extension VersionTests {
    static let __allTests = [
        ("testBasicParse", testBasicParse),
        ("testComparison", testComparison),
        ("testEquality", testEquality),
        ("testIllegalVersion", testIllegalVersion),
        ("testVParse", testVParse),
    ]
}

extension XcTransformTests {
    static let __allTests = [
        ("testGenerate", testGenerate),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BuildTransformTests.__allTests),
        testCase(ConfigTests.__allTests),
        testCase(InitTransformTests.__allTests),
        testCase(LineTests.__allTests),
        testCase(PackageDataTests.__allTests),
        testCase(PackageLoaderTests.__allTests),
        testCase(PackageTests.__allTests),
        testCase(PackageWriterTests.__allTests),
        testCase(RegistryTests.__allTests),
        testCase(RepositoryReferenceTests.__allTests),
        testCase(ResolveTransformTests.__allTests),
        testCase(TestTransformTests.__allTests),
        testCase(VersionTests.__allTests),
        testCase(XcTransformTests.__allTests),
    ]
}
#endif
