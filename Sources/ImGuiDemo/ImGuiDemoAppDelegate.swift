//
//  ImGuiDemoAppDelegate.swift
//  ImGuiDemo
//
//  Created by Joseph Bennett on 3/1/20.
//

import AppFramework
import Substrate
import ImGui
import SubstrateUtilities
import SubstrateMath

final class ImGuiAppDelegate : ApplicationDelegate {
    init() {
        
    }
    
    func applicationWillInitialise() {
        TaggedHeap.initialise()
    }
    
    func applicationDidUpdate(_ application: Application, frame: UInt64, deltaTime: Double) async {
        await application.windowRenderGraph.execute()
    }
    
    func applicationRenderedImGui(_ application: Application, frame: UInt64, renderData: ImGui.RenderData, window: Window, scissorRect: ScissorRect) async {
        
        let renderTargetDescriptor = await RenderTargetDescriptor(colorAttachments: [.init(texture: window.texture)])
        let clearRed = 0.5 * Double.sin(Double(frame) / 300.0) + 0.5
        let clearGreen = 0.5 * Double.cos(Double(frame) / 200.0) + 0.5
        let clearBlue = 0.5 * Double.cos(Double(frame) / 450.0) + 0.5
        await application.windowRenderGraph.addClearPass(renderTarget: renderTargetDescriptor, colorClearOperations: [.clear(ClearColor(red: clearRed, green: clearGreen, blue: clearBlue, alpha: 1.0))])
        
        await application.windowRenderGraph.addPass(ImGuiPass(renderData: renderData, renderTargetDescriptor: renderTargetDescriptor))
    }
}
