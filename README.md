# FileManagerCopyAllChildren

A tiny class extension for FileManager that gives you a method to copy all the children of a directory into another directory. Bundled in a Swift Package with unit tests.


### Usage

    FileManager.default.copyAllChildren(from: URL, to: URL)

or

    FileManager.default.copyAllChildren(from: URL, 
                                          to: URL, 
                        deleteOriginWhenDone: Bool, 
                           ignoreHiddenFiles: Bool)

### Install

Include `.package(url: "httpe://github.com/wvdk/FileManagerCopyAllChildren", .upToNextMinor(from: "0.1.0"))` in your Package.swift under `dependencies`.

