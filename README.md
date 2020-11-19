# FileManagerCopyAllChildren

A tiny class extension for FileManager that gives you a method to copy all the children of a directory into another directory. Bundled in a Swift Package with unit tests.

    FileManager.default.copyAllChildren(from: URL, to: URL)

or

    FileManager.default.copyAllChildren(from: URL, 
                                          to: URL, 
                        deleteOriginWhenDone: Bool, 
                           ignoreHiddenFiles: Bool)
