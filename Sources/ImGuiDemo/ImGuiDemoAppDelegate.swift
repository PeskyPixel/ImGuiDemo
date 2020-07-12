//
//  ImGuiDemoAppDelegate.swift
//  ImGuiDemo
//
//  Created by Joseph Bennett on 3/1/20.
//

import AppFramework
import SwiftFrameGraph
import ImGui
import FrameGraphUtilities
import SwiftMath

final class ImGuiAppDelegate : ApplicationDelegate {
    init() {
        
    }
    
    func applicationWillInitialise() {
        TaggedHeap.initialise()
        FrameGraph.initialise()
    }
    
    func applicationDidUpdate(_ application: Application, frame: UInt64, deltaTime: Double) {
        application.windowFrameGraph.execute()
    }
    
    func applicationRenderedImGui(_ application: Application, frame: UInt64, renderData: ImGui.RenderData, window: Window, scissorRect: ScissorRect) {
        
        let renderTargetDescriptor = RenderTargetDescriptor(colorAttachments: [.init(texture: window.texture)])
        let clearRed = 0.5 * Double.sin(Double(frame) / 300.0) + 0.5
        let clearGreen = 0.5 * Double.cos(Double(frame) / 200.0) + 0.5
        let clearBlue = 0.5 * Double.cos(Double(frame) / 450.0) + 0.5
        frameGraph.addDrawCallbackPass(descriptor: renderTargetDescriptor, colorClearOperations: [.clear(ClearColor(red: clearRed, green: clearGreen, blue: clearBlue, alpha: 1.0))], { _ in })
        
        application.windowFrameGraph.addPass(ImGuiPass(renderData: renderData, renderTargetDescriptor: renderTargetDescriptor))
    }
}
