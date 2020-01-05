//
//  RenderPassImgui.swift
//  InterdimensionalLlama
//
//  Created by Thomas Roughton on 6/04/17.
//
//

import AppFramework
import SwiftFrameGraph
import SwiftMath
import cimgui
import ImGui

import ShaderReflection

final class ImGuiPass : ReflectableDrawRenderPass {
    
    public typealias Reflection = ImGuiPassReflection
    
    static let vertexDescriptor : VertexDescriptor = {
        var vertexDescriptor = VertexDescriptor()
        //pos
        vertexDescriptor.attributes[0].offset = 0 //OFFSETOF(ImDrawVert, pos);
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 2//OFFSETOF(ImDrawVert, uv);
        vertexDescriptor.attributes[1].format = .float2;
        vertexDescriptor.attributes[1].bufferIndex = 0;
        vertexDescriptor.attributes[2].offset = MemoryLayout<Float>.size * 4 //OFFSETOF(ImDrawVert, col)
        vertexDescriptor.attributes[2].format = .uchar4Normalized
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<ImDrawVert>.size
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        return vertexDescriptor
    }()
    
    static let pipelineDescriptor : RenderPipelineDescriptor = {
        var descriptor = RenderPipelineDescriptor(attachmentCount: 1)
        
        descriptor.vertexDescriptor = ImGuiPass.vertexDescriptor
        
        var blendDescriptor = BlendDescriptor()
        blendDescriptor.sourceRGBBlendFactor = .sourceAlpha
        blendDescriptor.sourceAlphaBlendFactor = .sourceAlpha
        blendDescriptor.destinationRGBBlendFactor = .oneMinusSourceAlpha
        blendDescriptor.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        descriptor.blendStates[0] = blendDescriptor
        descriptor.label = "ImGui Pass Pipeline"
        
        return descriptor
    }()
    
    static let samplerDescriptor : SamplerDescriptor = {
        var samplerDescriptor = SamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        return samplerDescriptor
    }()
    
    struct ImGuiFragmentFunctionConstants : Equatable {
        enum TextureType : UInt32, Equatable {
            case float = 0
            case uint = 1
            case depth = 2
            case depthArray = 3
        }
        
        var textureType : TextureType = .float
        var channelCount : UInt16 = 0
        var convertTextureLinearToSRGB : Bool = false
        
        init() {
            
        }
        
        public init?(descriptor: TextureDescriptor, convertLinearToSRGB: Bool) {
            let pixelFormat = descriptor.pixelFormat
            
            switch pixelFormat {
            case _ where pixelFormat.isDepth:
                if descriptor.textureType == .type2DArray {
                    self.textureType = .depthArray
                } else {
                    self.textureType = .depth
                }
                self.channelCount = 1
            case .rgba32Float, .rgba16Float, .rgba16Unorm, .rgba8Unorm, .rgba8Unorm_sRGB:
                self.textureType = .float
                self.channelCount = 4
            case .rg32Float, .rg16Float, .rg16Unorm, .rg8Unorm, .rg8Unorm_sRGB:
                self.textureType = .float
                self.channelCount = 2
            case .r32Float, .r16Float, .r16Unorm, .r8Unorm:
                self.textureType = .float
                self.channelCount = 1
            default:
                return nil
            }
            
            self.convertTextureLinearToSRGB = convertLinearToSRGB
        }
    }
    
    let name = "ImGui"
    let renderData : ImGui.RenderData
    let renderTargetDescriptor: RenderTargetDescriptor
    
    init(renderData: ImGui.RenderData, renderTargetDescriptor: RenderTargetDescriptor) {
        self.renderData = renderData
        self.renderTargetDescriptor = renderTargetDescriptor
    }
    
    func execute(renderCommandEncoder renderEncoder: TypedRenderCommandEncoder<ImGuiPassReflection>) {
        
        if renderData.vertexBuffer.isEmpty {
            return
        }
        
        renderEncoder.setTriangleFillMode(.fill)
        
        let vertexBuffer = Buffer(descriptor: BufferDescriptor(length: renderData.vertexBuffer.count * MemoryLayout<ImDrawVert>.size, usage: .vertexBuffer), bytes: renderData.vertexBuffer.baseAddress!)
        let indexBuffer = Buffer(descriptor: BufferDescriptor(length: renderData.indexBuffer.count * MemoryLayout<ImDrawIdx>.size, usage: .indexBuffer), bytes: renderData.indexBuffer.baseAddress!)
        
        
        let displayPosition = self.renderData.displayPosition
        let displayWidth = Float(self.renderData.displaySize.x)
        let displayHeight = Float(self.renderData.displaySize.y)
        
        let fbWidth = self.renderTargetDescriptor.size.width
        let fbHeight = self.renderTargetDescriptor.size.height
        let fbWidthF = Float(fbWidth)
        let fbHeightF = Float(fbHeight)
        
        renderEncoder.pipeline.descriptor = ImGuiPass.pipelineDescriptor
        renderEncoder.pipeline.vertexFunction =  .vertex
        renderEncoder.pipeline.fragmentFunction =  .fragment
        renderEncoder.depthStencil = DepthStencilDescriptor()
        
        let left = displayPosition.x, right = displayPosition.x + displayWidth, top = displayPosition.y, bottom = displayPosition.y + displayHeight
        let near : Float = 0
        let far : Float = 1
        let orthoMatrix = Matrix4x4f.ortho(left: left, right: right, bottom: bottom, top: top, near: near, far: far)
        
        renderEncoder.pushConstants.uniforms.projectionMatrix = orthoMatrix
        renderEncoder.set0.textureSampler = ImGuiPass.samplerDescriptor
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        renderEncoder.setViewport(Viewport(originX: 0.0, originY: 0.0, width: Double(fbWidth), height: Double(fbHeight), zNear: 0.0, zFar: 1.0))
        
        let clipSpaceDisplayPosition = displayPosition * renderData.clipScaleFactor
        
        for drawCommand in renderData.drawCommands {
            
            renderEncoder.setVertexBufferOffset(drawCommand.vertexBufferByteOffset, index: 0)
            
            var idxBufferOffset = 0
            
            for pcmd in drawCommand.subCommands {
                if pcmd.UserCallback != nil {
                    fatalError("User callbacks are unsupported.")
                } else {
                    let clipRect = ImVec4(x: pcmd.ClipRect.x - clipSpaceDisplayPosition.x, y: pcmd.ClipRect.y - clipSpaceDisplayPosition.y, z: pcmd.ClipRect.z - clipSpaceDisplayPosition.x, w: pcmd.ClipRect.w - clipSpaceDisplayPosition.y)
                    if clipRect.x < fbWidthF && clipRect.y < fbHeightF && clipRect.z >= 0.0 && clipRect.w >= 0.0 {
                        let scissorRect = ScissorRect(x: max(Int(clipRect.x), 0), y: max(Int(clipRect.y), 0), width: Int(min(clipRect.z, fbWidthF) - clipRect.x), height: Int(min(clipRect.w, fbHeightF) - clipRect.y))
                        renderEncoder.setScissorRect(scissorRect)
                        
                        let textureIdentifier = UInt64(UInt(bitPattern: pcmd.TextureId))
                        
                        let texture : Texture
                        if textureIdentifier & (UInt64(ResourceType.texture.rawValue) << Resource.typeBitsRange.lowerBound) != 0 {
                            // Texture handle
                            texture = Texture(handle: Texture.Handle(textureIdentifier))
                        } else {
                            let lookupHandle = UInt32(truncatingIfNeeded: textureIdentifier.bits(in: Resource.indexBitsRange))
                            texture = TextureLookup.textureWithId(lookupHandle) ?? Texture.invalid
                        }
                        
                        let isFontTexture = pcmd.TextureId == ImGui.io.pointee.Fonts.pointee.TexID

                        guard let functionConstants = ImGuiFragmentFunctionConstants(descriptor: texture.descriptor, convertLinearToSRGB: isFontTexture) else { continue }
                        renderEncoder.pipeline.constants.imGuiTextureConvertLinearToSRGB = isFontTexture
                        renderEncoder.pipeline.constants.imGuiTextureChannelCount = UInt32(functionConstants.channelCount)
                        renderEncoder.pipeline.constants.imGuiTextureType = functionConstants.textureType.rawValue
                        
                        if texture != renderEncoder.set0.floatTexture {
                            renderEncoder.set0.floatTexture = texture
                        }
                        
                        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: Int(pcmd.ElemCount), indexType: MemoryLayout<ImDrawIdx>.size == 2 ? .uint16 : .uint32, indexBuffer: indexBuffer, indexBufferOffset: drawCommand.indexBufferByteOffset + MemoryLayout<ImDrawIdx>.size * idxBufferOffset)
                    }
                }
                
                idxBufferOffset += Int(pcmd.ElemCount)
            }
        }
    }
}
