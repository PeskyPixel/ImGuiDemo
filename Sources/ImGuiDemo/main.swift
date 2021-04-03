import AppFramework
import Substrate
import Foundation

let inflightFrameCount = 3

let rootDirectory = CommandLine.arguments[1]

#if canImport(Metal)
let libraryPath = "\(rootDirectory)/Resources/Shaders/Metal/Library.metallib"
RenderBackend.initialise(api: .metal, applicationName: "ImGuiDemo", libraryPath: libraryPath)
#elseif canImport(Vulkan)
let libraryPath = "\(rootDirectory)/Resources/Shaders/Vulkan"
RenderBackend.initialise(api: .vulkan, applicationName: "ImGuiDemo", libraryPath: libraryPath)
#else
fatalError("No supported APIs found")
#endif

GPUResourceUploader.initialise()

let delegate = ImGuiAppDelegate()

let renderGraph = RenderGraph(inflightFrameCount: inflightFrameCount)

let _ = SDLUpdateScheduler(appDelegate: delegate, windowDelegates: [ImGuiDemoWindow(renderGraph: renderGraph)], windowRenderGraph: renderGraph)
