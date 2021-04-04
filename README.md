# ImGuiDemo

A demo of using [Dear ImGui](https://github.com/ocornut/imgui) with [Substrate](https://github.com/troughton/SubstrateRender).

To build it, you’ll need to first install and add to your PATH [DirectXShaderCompiler](https://github.com/microsoft/DirectXShaderCompiler) and [spirv-opt](https://github.com/KhronosGroup/SPIRV-Tools), then run:

`swift build --configuration release --product ShaderTool`

from within the ImGuiDemo repository, which will build the tool used to compile the shaders. Then, you run 

`.build/release/ShaderTool Resources/Shaders Sources/ShaderReflection/ShaderReflection.swift`

to both build the shader binaries and generate the Swift reflection for the shaders. 

`swift build` should then work as per normal, and you can run it with `.build/debug/ImGuiDemo`.
