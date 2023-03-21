Shader "URPPlus/Lit"
{
    Properties
    {
        /*************************************/
        /***********Surface Options***********/
        /*************************************/
        [HideInInspector] _WorkflowMode("WorkflowMode", Float) = 1.0
        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector][ToggleUI] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _ZTest("ZTest", Int) = 4
        // Normal Mode
        [Enum(Flip, 0, Mirror, 1, None, 2)] _DoubleSidedNormalMode("Double sided normal mode", Float) = 1
        [HideInInspector] _DoubleSidedConstants("Double-Sided Constants", Vector) = (1.0, 1.0, 1.0, 0.0)
        // Alpha Clipping
        [ToggleUI]  _AlphaCutoffEnable("Alpha Cutoff Enable", Float) = 0.0
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [ToggleUI]  _UseShadowThreshold("_UseShadowThreshold", Float) = 0.0
        _AlphaCutoffShadow("_AlphaCutoffShadow", Range(0.0, 1.0)) = 0.5
        // Geometric AA
        [ToggleUI] _EnableGeometricSpecularAA("EnableGeometricSpecularAA", Float) = 0.0
        _SpecularAAScreenSpaceVariance("SpecularAAScreenSpaceVariance", Range(0.0, 1.0)) = 0.1
        _SpecularAAThreshold("SpecularAAThreshold", Range(0.0, 1.0)) = 0.2
        // Displacement Mode
        [Enum(None, 0, Vertex Displacement, 1, Pixel Displacement, 2)]_DisplacementMode("DisplacementMode", Float) = 0.0
        [ToggleUI] _DisplacementLockObjectScale("displacement lock object scale", Float) = 1.0
        [ToggleUI] _DepthOffsetEnable("Depth Offset View space", Float) = 0.0
        _PPDMinSamples("Min sample for POM", Range(1.0, 64.0)) = 5
        _PPDMaxSamples("Max sample for POM", Range(1.0, 64.0)) = 15
        _PPDLodThreshold("Start lod to fade out the POM effect", Range(0.0, 16.0)) = 5
        _PPDPrimitiveLength("Primitive length for POM", Float) = 1
        _PPDPrimitiveWidth("Primitive width for POM", Float) = 1
        [HideInInspector] _InvPrimScale("Inverse primitive scale for non-planar POM", Vector) = (1, 1, 0, 0)

        /************************************/
        /***********Surface Inputs***********/
        /************************************/
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        // Mask Map
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _MaskMap("MaskMap", 2D) = "white" {}
        _MetallicRemapMin("MetallicRemapMin", Range(0.0, 1.0)) = 0.0
        _MetallicRemapMax("MetallicRemapMax", Range(0.0, 1.0)) = 1.0
        _SmoothnessRemapMin("SmoothnessRemapMin", Range(0.0, 1.0)) = 0.0
        _SmoothnessRemapMax("SmoothnessRemapMax", Range(0.0, 1.0)) = 1.0
        _AORemapMin("AORemapMin", Range(0.0, 1.0)) = 0.0
        _AORemapMax("AORemapMax", Range(0.0, 1.0)) = 1.0
        // Specular Map
        _SpecularColor("SpecularColor", Color) = (0.2, 0.2, 0.2, 1.0)
        _SpecularColorMap("SpecularColorMap", 2D) = "white" {}
        // Normal Map
        _BumpScale("Scale", Range(0.0, 8.0)) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BentNormalMap("Bent Normal Map", 2D) = "bump" {}

        // HeightMap
        _HeightMap("Height Map", 2D) = "black" {}
        [HideInInspector] _HeightAmplitude("Height Amplitude", Float) = 0.02 // In world units. This will be computed in the UI.
        [HideInInspector] _HeightCenter("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space

        [Enum(MinMax, 0, Amplitude, 1)] _HeightMapParametrization("Heightmap Parametrization", Int) = 1
        // MinMax mode
        _HeightMin("Heightmap Min", Float) = -1
        _HeightMax("Heightmap Max", Float) = 1
        // Amplitude mode
        _HeightTessAmplitude("Amplitude", Float) = 2.0 // in Centimeters
        _HeightTessCenter("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space
        // These parameters are for vertex displacement/Tessellation
        _HeightOffset("Height Offset", Float) = 0
        // These parameters are for pixel displacement
        _HeightPoMAmplitude("Height Amplitude", Float) = 2.0 // In centimeters

        // ClearCoat
        _ClearCoatMap("ClearCoatMap", 2D) = "white" {}
        _ClearCoatMask("ClearCoatMask", Range(0.0, 1.0)) = 0.0
        _ClearCoatSmoothness("ClearCoatSmoothness", Range(0.0, 1.0)) = 1.0
        _CoatNormalMap("Coat Normal Map", 2D) = "bump" {}
        _CoatNormalScale("CoatNormal Scale", Range(0.0, 8.0)) = 1.0

        /*************************************/
        /************Detail Inputs************/
        /*************************************/
        _DetailMap("Detail Map", 2D) = "white" {}
        _DetailAlbedoScale("Detail Albedo Scale", Range(0.0, 2.0)) = 1.0
        _DetailNormalScale("Detail Normal Scale", Range(0.0, 2.0)) = 1.0
        _DetailSmoothnessScale("Detail Smoothness Scale", Range(0.0, 2.0)) = 1.0

        /*************************************/
        /***********Emission Inputs***********/
        /*************************************/
        [HDR] _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}
        _EmissionScale("Emission Intensity", Float) = 1.0
        [ToggleUI] _AlbedoAffectEmissive("Albedo Affect Emissive", Float) = 0.0

        /************************************/
        /**********Advanced Options**********/
        /************************************/
        [ToggleUI]  _CastShadows("Cast Shadows", Float) = 0.0
        [ToggleUI]  _ReceiveShadows("Receive Shadows", Float) = 1.0
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        [ToggleUI]  _CoatNormal("ClearCoat Second Normal", Float) = 0.0
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
        
        // Specular Occlusion
        [ToggleOff] _HorizonOcclusion("Horizon Occlusion", Float) = 0.0
        _HorizonFade("HorizonFade", Range(0.0, 1.0)) = 0.5
        [Enum(Off, 0, From Ambient Occlusion, 1, From AO and Bent Normals, 2, From GI, 3)] _SpecularOcclusionMode("Specular Occlusion Mode", Int) = 0
        _GIOcclusionBias("GIOcclusion Bias", Range(0.0, 1.0)) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel"="4.5"}
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _BENTNORMALMAP

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON
            
            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _CLEARCOAT_NORMALMAP

            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _BENTNORMAL_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/Lit/LitForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest[_ZTest]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SHADOW_CUTOFF

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _VERTEX_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags{"LightMode" = "UniversalGBuffer"}

            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _BENTNORMALMAP

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON
            
            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _CLEARCOAT_NORMALMAP
            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _BENTNORMAL_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/Lit/LitGBufferPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest[_ZTest]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SHADOW_CUTOFF
            
            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _VERTEX_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/UniversalDepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON
            
            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_HIGH_QUALITY_DEPTH_NORMALS

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/UniversalDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #pragma shader_feature EDITOR_VISUALIZATION
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local_fragment _BENTNORMALMAP

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON
            
            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _CLEARCOAT_NORMALMAP

            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE

            #pragma shader_feature_local_fragment _BENTNORMAL_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/UniversalMetaPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Universal2D"
            Tags{ "LightMode" = "Universal2D" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel"="2.0"}
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _BENTNORMALMAP

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON
            
            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _CLEARCOAT_NORMALMAP

            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _BENTNORMAL_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/Lit/LitForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest[_ZTest]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SHADOW_CUTOFF

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _VERTEX_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest[_ZTest]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SHADOW_CUTOFF
            
            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _VERTEX_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/UniversalDepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_HIGH_QUALITY_DEPTH_NORMALS

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/UniversalDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #pragma shader_feature EDITOR_VISUALIZATION
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local_fragment _BENTNORMALMAP

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
            #pragma shader_feature_local_vertex _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local_fragment _DEPTHOFFSET_ON
            
            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _CLEARCOAT_NORMALMAP

            #pragma shader_feature_local_fragment _DETAIL

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE

            #pragma shader_feature_local_fragment _BENTNORMAL_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "ShaderLibrary/UniversalMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Universal2D"
            Tags{ "LightMode" = "Universal2D" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

            #include "ShaderLibrary/Lit/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShaderGUI"
}
