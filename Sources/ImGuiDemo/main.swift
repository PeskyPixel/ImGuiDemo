import AppFramework
import SwiftFrameGraph
import Foundation

let inflightFrameCount = 3

let rootDirectory = CommandLine.arguments[1]
let libraryPath = "\(rootDirectory)/Resources/Shaders/Metal/Library.metallib"

RenderBackend.initialise(api: .metal, libraryPath: libraryPath)

let delegate = ImGuiAppDelegate()

let frameGraph = FrameGraph(inflightFrameCount: inflightFrameCount)

let scheduler = SDLUpdateScheduler(appDelegate: delegate, windowDelegates: [ImGuiDemoWindow(frameGraph: frameGraph)], windowFrameGraph: frameGraph)


print("Hello, world!")
