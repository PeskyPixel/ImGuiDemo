//
//  ImGuiDemoWindow.swift
//  ImGuiDemo
//
//  Created by Joseph Bennett on 3/1/20.
//

import AppFramework
import ImGui
import SwiftFrameGraph

final class ImGuiDemoWindow : WindowDelegate {
    var title: String = "ImGui Demo"
    var desiredSize = WindowSize(1283, 719)

    var window: Window! = nil {
       didSet {
           self.setup()
       }
    }
    
    var inputLayers: [InputLayer] = []
    
    let frameGraph : FrameGraph
    
    init(frameGraph: FrameGraph) {
        self.frameGraph = frameGraph
    }
    
    func setup() {
        
    }
    
    func update(frame: UInt64, deltaTime: Double) {
        var opened = true
        ImGui.showDemoWindow(opened: &opened)
    }
}
