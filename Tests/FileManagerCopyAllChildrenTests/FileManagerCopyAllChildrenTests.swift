import XCTest
@testable import FileManagerCopyAllChildren

final class FileManagerCopyAllChildrenTests: XCTestCase {
    
    private let fileManager = FileManager.default
    
    private func generateOriginAndTargetURLs(removeAnyExistingTargetDirectory: Bool = false) -> (URL, URL, URL)? {
        guard let root = Bundle.module.url(forResource: "FileManagerCopyAllChildrenTestAssets", withExtension: nil) else {
            print("Could not find the root test content folder.")
            return nil
        }
        
        let origin = root.appendingPathComponent("Original Test Content")
        
        // Double check that this testing folder actually exists in bundle.
        var originIsDirectory: ObjCBool = false
        let originExists = fileManager.fileExists(atPath: origin.path, isDirectory: &originIsDirectory)
        guard originExists else {
            print("The testing folder does not exist.")
            return nil
        }
        guard originIsDirectory.boolValue else {
            print("The testing folder is not a folder.")
            return nil
        }
        
        let target = root.appendingPathComponent("My Newly Copied Test Content")
        
        /** The `FileManager` method `copyAllChildren(from:to:)` method we're testing here should be able to handle a target directory which is empty, not empty, or entirely nonexistent. Below we support the`removeAnyExistingTargetDirectory` flag to allow testing of this functionality.
         */
        
        // Check if target already exists.
        let targetExists = fileManager.fileExists(atPath: origin.path, isDirectory: &originIsDirectory)
        if targetExists {
            guard originIsDirectory.boolValue else {
                print("The testing folder is not a folder.")
                return nil
            }
        }
        
        // Delete the target if needed.s
        if targetExists && removeAnyExistingTargetDirectory {
            do {
                try fileManager.removeItem(at: target)
            } catch {
                print("Error: \(error)")
                return nil
            }
        }
        
        return (origin: origin, target: target, root: root)
    }
    
    func testBasicCopy() {
        guard let (origin, target, _) = generateOriginAndTargetURLs() else {
            XCTAssert(false, "generateOriginAndTargetURLs() is returning nil.")
            return
        }
        
        do {
            try fileManager.copyAllChildren(from: origin, to: target)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "Failed to run copyAllChildren without throwing an error.")
        }
        
        // Check that contents of target are all there.
        
        // Get contents of origin.
        var originContents: [String]!
        do {
            originContents = try fileManager.contentsOfDirectory(atPath: origin.path)
        } catch {
            print("Error: \(error)")
            XCTAssert(false)
            return
        }
        
        // Get contents of target.
        var targetContents: [String]!
        do {
            targetContents = try fileManager.contentsOfDirectory(atPath: target.path)
        } catch {
            print("Error: \(error)")
            XCTAssert(false)
            return
        }
        
        // Compare them.
        XCTAssert(targetContents == originContents, "The contents of the target and origin do not match after copy.")
    }
    
    func testWithInvalidOrigin() {
        guard let (origin, target, root) = generateOriginAndTargetURLs() else {
            XCTAssert(false, "generateOriginAndTargetURLs() is returning nil.")
            return
        }
        
        // Test with an origin that is empty
        let emptyOrigin = root.appendingPathComponent("Leave Me Empty")
        do {
            try fileManager.copyAllChildren(from: emptyOrigin, to: target)
        } catch FileManager.FileManagerCopyAllChildrenError.originIsEmpty {
            print("Successfully tested that FileManagerCopyAllChildrenError.originIsEmpty is thrown when origin is empty.")
            XCTAssert(true)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "We are intentionally testing for the FileManagerCopyAllChildrenError.originIsEmpty error - which is not what we got.")
        }
        
        // Test with an origin that is not a directory
        let notADirectoryOrigin = origin.appendingPathComponent("test.txt")
        do {
            try fileManager.copyAllChildren(from: notADirectoryOrigin, to: target)
        } catch FileManager.FileManagerCopyAllChildrenError.originIsNotADirectory {
            print("Successfully tested that FileManagerCopyAllChildrenError.originIsNotADirectory is thrown when origin is not a directory.")
            XCTAssert(true)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "We are intentionally testing for the FileManagerCopyAllChildrenError.originIsNotADirectory error - which is not what we got.")
        }
        
        // Test with an origin that does not exist
        let nonexistentOrigin = root.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.copyAllChildren(from: nonexistentOrigin, to: target)
        } catch FileManager.FileManagerCopyAllChildrenError.originDoesNotExist {
            print("Successfully tested that FileManagerCopyAllChildrenError.originDoesNotExist is thrown when origin does not exist.")
            XCTAssert(true)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "We are intentionally testing for the FileManagerCopyAllChildrenError.originDoesNotExist error - which is not what we got.")
        }
    }
    
    func testWithInvalidTarget() {
        guard let (origin, _, root) = generateOriginAndTargetURLs() else {
            XCTAssert(false, "generateOriginAndTargetURLs() is returning nil.")
            return
        }
        
        // Test with an target that does not exist
        let nonexistentTarget = root.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.copyAllChildren(from: origin, to: nonexistentTarget)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "We should be able to use a nonexistent target but that failed.")
        }
        
        // Test using the same URL for both the origin and target
        do {
            try fileManager.copyAllChildren(from: origin, to: origin)
        }  catch FileManager.FileManagerCopyAllChildrenError.originAndTargetAreTheSame {
            print("Successfully tested that FileManagerCopyAllChildrenError.originAndTargetAreTheSame is thrown when origin and target match.")
            XCTAssert(true)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "We are intentionally testing for the FileManagerCopyAllChildrenError.originAndTargetAreTheSame error - which is not what we got.")
        }
    }
    
    func testOriginDeletionAfterRun() {
        guard let (origin, target, _) = generateOriginAndTargetURLs() else {
            XCTAssert(false, "generateOriginAndTargetURLs() is returning nil.")
            return
        }
        
        // First lets make a copy of our original test files so we don't delete them and break all our other tests.
        do {
            try fileManager.copyAllChildren(from: origin, to: target, deleteOriginWhenDone: false)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "Failed to run copyAllChildren without throwing an error.")
        }
        
        guard let root = Bundle.module.url(forResource: "FileManagerCopyAllChildrenTestAssets", withExtension: nil) else {
            XCTAssert(false)
            return
        }
        let newTarget = root.appendingPathComponent("My Newly Copied Test Content 2")
        
        // Now we can copy and delete the newly created folder.
        do {
            try fileManager.copyAllChildren(from: target, to: newTarget, deleteOriginWhenDone: true)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "Failed to run copyAllChildren without throwing an error.")
        }
        
        // Check that the original target is gone now.
        if fileManager.fileExists(atPath: target.path) {
            XCTAssert(false, "The origin file should be deleted after the call to copyAllChildren(from: origin, to: target, deleteOriginWhenDone: true)")
        }
    }
    
    func testHiddenFileSkipping() {
        guard let (origin, target, _) = generateOriginAndTargetURLs() else {
            XCTAssert(false, "generateOriginAndTargetURLs() is returning nil.")
            return
        }
        
        // First delete any existing target file that may already contain the hidden files we are making sure aren't copied.
        do {
            try fileManager.removeItem(at: target)
        } catch {
            print("Error: \(error)")
            XCTAssert(false)
        }
        
        XCTAssertFalse(fileManager.fileExists(atPath: target.path))
        
        do {
            try fileManager.copyAllChildren(from: origin, to: target, ignoreHiddenFiles: true)
        } catch {
            print("Error: \(error)")
            XCTAssert(false, "Failed to run copyAllChildren without throwing an error.")
        }
        
        // Check that contents of target are all there.
        
        // Get contents of target.
        var targetContents: [String]!
        do {
            targetContents = try fileManager.contentsOfDirectory(atPath: target.path)
        } catch {
            print("Error: \(error)")
            XCTAssert(false)
            return
        }
        
        // Compare them.
        let foundOurHiddenTxt = targetContents.contains(".hidden.txt")
        XCTAssertFalse(foundOurHiddenTxt, "The contents of the target contains the hidden file - but it shouldn't because we set ignoreHiddenFiles.")
    }
    
    static var allTests = [
        ("testBasicCopy", testBasicCopy),
        ("testWithInvalidOrigin", testWithInvalidOrigin),
        ("testWithInvalidTarget", testWithInvalidTarget),
        ("testOriginDeletionAfterRun", testOriginDeletionAfterRun),
        ("testHiddenFileSkipping", testHiddenFileSkipping)
    ]
    
}
