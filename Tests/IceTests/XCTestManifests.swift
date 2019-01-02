import XCTest

extension AddTests {
    static let __allTests = [
        ("testBasicAdd", testBasicAdd),
        ("testBranchAdd", testBranchAdd),
        ("testDifferentNamedLib", testDifferentNamedLib),
        ("testSHAAdd", testSHAAdd),
        ("testSingleTargetAdd", testSingleTargetAdd),
        ("testTargetAdd", testTargetAdd),
        ("testVersionedAdd", testVersionedAdd),
    ]
}

extension BuildTests {
    static let __allTests = [
        ("testBuildErrors", testBuildErrors),
        ("testBuildProduct", testBuildProduct),
        ("testBuildTarget", testBuildTarget),
        ("testCleanBuild", testCleanBuild),
        ("testReleaseBuild", testReleaseBuild),
        ("testSimpleBuild", testSimpleBuild),
        ("testWatchBuild", testWatchBuild),
    ]
}

extension CleanTests {
    static let __allTests = [
        ("testClean", testClean),
    ]
}

extension ConfigTests {
    static let __allTests = [
        ("testGet", testGet),
        ("testSet", testSet),
        ("testSetInvalid", testSetInvalid),
        ("testShow", testShow),
    ]
}

extension DumpTests {
    static let __allTests = [
        ("testModel", testModel),
        ("testPackageDescription", testPackageDescription),
    ]
}

extension GenerateTestListTests {
    static let __allTests = [
        ("testGenerate", testGenerate),
    ]
}

extension InitTests {
    static let __allTests = [
        ("testExec", testExec),
        ("testLib", testLib),
    ]
}

extension NewTests {
    static let __allTests = [
        ("testExec", testExec),
        ("testLib", testLib),
    ]
}

extension OutdatedTests {
    static let __allTests = [
        ("testOutdated", testOutdated),
        ("testOutdatedNoDependencies", testOutdatedNoDependencies),
    ]
}

extension ProductTests {
    static let __allTests = [
        ("testAddExec", testAddExec),
        ("testAddLib", testAddLib),
        ("testRemove", testRemove),
    ]
}

extension RegistryTests {
    static let __allTests = [
        ("testAdd", testAdd),
        ("testLocalLookup", testLocalLookup),
        ("testRemove", testRemove),
        ("testSharedLookup", testSharedLookup),
    ]
}

extension RemoveTests {
    static let __allTests = [
        ("testBasicRemove", testBasicRemove),
        ("testRemoveDifferentName", testRemoveDifferentName),
    ]
}

extension ResolveTests {
    static let __allTests = [
        ("testResolve", testResolve),
    ]
}

extension RunTests {
    static let __allTests = [
        ("testBasicRun", testBasicRun),
        ("testWatchRun", testWatchRun),
    ]
}

extension SearchTests {
    static let __allTests = [
        ("testFullSearch", testFullSearch),
        ("testNameSearch", testNameSearch),
        ("testNoResults", testNoResults),
    ]
}

extension TargetTests {
    static let __allTests = [
        ("testBasicAdd", testBasicAdd),
        ("testDependAdd", testDependAdd),
        ("testSystemAdd", testSystemAdd),
        ("testTargetRemove", testTargetRemove),
    ]
}

extension TestTests {
    static let __allTests = [
        ("testGenerateList", testGenerateList),
    ]
}

extension ToolsVersionTests {
    static let __allTests = [
        ("testGet", testGet),
        ("testTaggedUpdate", testTaggedUpdate),
        ("testUpdate", testUpdate),
    ]
}

extension UpdateTests {
    static let __allTests = [
        ("testUpdate", testUpdate),
        ("testUpdateSingle", testUpdateSingle),
    ]
}

extension VersionTests {
    static let __allTests = [
        ("testVersion", testVersion),
    ]
}

extension XcTests {
    static let __allTests = [
        ("testXc", testXc),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AddTests.__allTests),
        testCase(BuildTests.__allTests),
        testCase(CleanTests.__allTests),
        testCase(ConfigTests.__allTests),
        testCase(DumpTests.__allTests),
        testCase(GenerateTestListTests.__allTests),
        testCase(InitTests.__allTests),
        testCase(NewTests.__allTests),
        testCase(OutdatedTests.__allTests),
        testCase(ProductTests.__allTests),
        testCase(RegistryTests.__allTests),
        testCase(RemoveTests.__allTests),
        testCase(ResolveTests.__allTests),
        testCase(RunTests.__allTests),
        testCase(SearchTests.__allTests),
        testCase(TargetTests.__allTests),
        testCase(TestTests.__allTests),
        testCase(ToolsVersionTests.__allTests),
        testCase(UpdateTests.__allTests),
        testCase(VersionTests.__allTests),
        testCase(XcTests.__allTests),
    ]
}
#endif
