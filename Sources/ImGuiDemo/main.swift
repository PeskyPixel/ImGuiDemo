import AppFramework
import Substrate
import Foundation

let inflightFrameCount = 3

let rootDirectory = CommandLine.arguments[1]

#if canImport(Metal)
let libraryPath = "\(rootDirectory)/Resources/Shaders/Compiled/Library-macOS.metallib"
RenderBackend.initialise(api: .metal, applicationName: "ImGuiDemo", libraryPath: libraryPath)
#elseif canImport(Vulkan)
let libraryPath = "\(rootDirectory)/Resources/Shaders/Compiled/Vulkan"
RenderBackend.initialise(api: .vulkan, applicationName: "ImGuiDemo", libraryPath: libraryPath)
#else
fatalError("No supported APIs found")
#endif

GPUResourceUploader.initialise()

let delegate = ImGuiAppDelegate()

let renderGraph = RenderGraph(inflightFrameCount: inflightFrameCount)

Task {
    let _ = await SDLUpdateScheduler(appDelegate: delegate, windowDelegates: [ImGuiDemoWindow(renderGraph: renderGraph)], windowRenderGraph: renderGraph)
}

#if canImport(Darwin)
RunLoop.main.run()
#else
dispatchMain()
#endif
