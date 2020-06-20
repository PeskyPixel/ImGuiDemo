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
        frameGraph.addDrawCallbackPass(descriptor: renderTargetDescriptor, colorClearOperations: [.clear(ClearColor())], execute: { _ in })
        
        application.windowFrameGraph.addPass(ImGuiPass(renderData: renderData, renderTargetDescriptor: renderTargetDescriptor))
    }
}
