using UnityEngine;
using UnityEditor.Rendering;

namespace UnityEditor
{    
    internal class URPPlusStyles
    {
        // Categories
        public static readonly GUIContent SurfaceOptions = EditorGUIUtility.TrTextContent("Surface Options", "Controls how URP+ Renders the material on screen.");
        public static readonly GUIContent TessellationOptions = EditorGUIUtility.TrTextContent("Tessellation Options");
        public static readonly GUIContent SurfaceInputs = EditorGUIUtility.TrTextContent("Surface Inputs", "These settings describe the look and feel of the surface itself.");    
        public static readonly GUIContent DetailInputs = EditorGUIUtility.TrTextContent("Detail Inputs");
        public static readonly GUIContent ThreadInputs = EditorGUIUtility.TrTextContent("Thread Inputs");
        public static readonly GUIContent EmissionInputs = EditorGUIUtility.TrTextContent("Emission Inputs");
		public static readonly GUIContent AdvancedLabel = EditorGUIUtility.TrTextContent("Advanced Options", "These settings affect behind-the-scenes rendering and underlying calculations.");
        public static readonly GUIContent fixNormalNow = EditorGUIUtility.TrTextContent("Fix now", "Converts the assigned texture to be a normal map format.");
        public static readonly GUIContent bumpScaleNotSupported = EditorGUIUtility.TrTextContent("Bump scale is not supported on mobile platforms");

        // Layered
        public static readonly GUIContent MainLayer = EditorGUIUtility.TrTextContent("Main layer");
        public static readonly GUIContent Layer1 = EditorGUIUtility.TrTextContent("Layer 1");
        public static readonly GUIContent Layer2 = EditorGUIUtility.TrTextContent("Layer 2");
        public static readonly GUIContent Layer3 = EditorGUIUtility.TrTextContent("Layer 3");

        // Surface Options
        public static readonly GUIContent workflowModeText = EditorGUIUtility.TrTextContent("Workflow Mode", "Select a workflow that fits your textures. Choose between Metallic or Specular.");
        public static readonly GUIContent surfaceTypeText = EditorGUIUtility.TrTextContent("Surface Type", "Controls whether the Material supports transparency or not");
        public static readonly GUIContent blendingModeText = EditorGUIUtility.TrTextContent("Blending Mode", "Controls how the color of the Transparent surface blends with the Material color in the background.");
        public static readonly GUIContent cullingText = EditorGUIUtility.TrTextContent("Cull Mode", "Specifies which faces to cull from your geometry. Front culls front faces. Back culls backfaces. None means that both sides are rendered.");
        public static readonly GUIContent doubleSidedNormalModeText = EditorGUIUtility.TrTextContent("Normal Mode", "Specifies the method URP+ uses to modify the normal base.\nMirror: Mirrors the normals with the vertex normal plane.\nFlip: Flips the normal.");
        public static readonly GUIContent useShadowThresholdText = EditorGUIUtility.TrTextContent("Use Shadow Threshold", "Enable separate threshold for shadow pass");
        public static readonly GUIContent alphaCutoffEnableText = EditorGUIUtility.TrTextContent("Alpha Clipping", "When enabled, URP+ processes Alpha Clipping for this Material.");
        public static readonly GUIContent alphaCutoffText = EditorGUIUtility.TrTextContent("Threshold", "Controls the threshold for the Alpha Clipping effect.");
        public static readonly GUIContent alphaCutoffShadowText = EditorGUIUtility.TrTextContent("Shadow Threshold", "Controls the threshold for shadow pass alpha clipping.");

        public static readonly GUIContent materialIDText = EditorGUIUtility.TrTextContent("Material Type", "Specifies additional feature for this Material. Customize you Material with different settings depending on which Material Type you select.");
        public static readonly GUIContent transmissionEnableText = EditorGUIUtility.TrTextContent("Transmission", "When enabled URP+ processes the transmission effect for subsurface scattering. Simulates the translucency of the object.");

        public static readonly GUIContent zWriteEnableText = EditorGUIUtility.TrTextContent("Depth Write", "When enabled, transparent objects write to the depth buffer.");
        public static readonly GUIContent transparentZTestText = EditorGUIUtility.TrTextContent("Depth Test", "Set the comparison function to use during the Z Testing.");

        public static readonly GUIContent displacementModeText = EditorGUIUtility.TrTextContent("Displacement Mode", "Specifies the method URP+ uses to apply height map displacement to the selected element: Vertex, pixel, or tessellated vertex.\nYou must use flat surfaces for Pixel displacement.");
        public static readonly GUIContent lockWithObjectScaleText = EditorGUIUtility.TrTextContent("Lock With Object Scale", "When enabled, displacement mapping takes the absolute value of the scale of the object into account.");
        public static readonly GUIContent lockWithTilingRateText = EditorGUIUtility.TrTextContent("Lock With Height Map Tiling Rate", "When enabled, displacement mapping takes the absolute value of the tiling rate of the height map into account.");

        // Tessellation
        public static readonly GUIContent tessellationModeText = EditorGUIUtility.TrTextContent("Tessellation Mode", "Controls mode of tessellation factor");
        public static readonly GUIContent phongTessellationText = EditorGUIUtility.TrTextContent("Phong Tessellation", "Phong tessellation applies vertex interpolation to make geometry smoother. If you assign a displacement map for this Material and select this option, URP+ applies smoothing to the displacement map.");
        public static readonly GUIContent tessellationFactorText = EditorGUIUtility.TrTextContent("Tessellation Factor", "Controls the strength of the tessellation effect. Higher values result in more tessellation. Maximum tessellation factor is 15 on the Xbox One and PS4");
        public static readonly GUIContent tessellationEdgeLengthText = EditorGUIUtility.TrTextContent("Tessellation Edge Length", "Bases tessellation factor on the length of edges.");
        public static readonly GUIContent tessellationFactorMinDistanceText = EditorGUIUtility.TrTextContent("Start Fade Distance", "Sets the distance from the camera at which tessellation begins to fade out.");
        public static readonly GUIContent tessellationFactorMaxDistanceText = EditorGUIUtility.TrTextContent("End Fade Distance", "Sets the maximum distance from the Camera where URP+ tessellates triangle. Set to 0 to disable adaptative factor with distance.");
        public static readonly GUIContent tessellationFactorTriangleSizeText = EditorGUIUtility.TrTextContent("Triangle Size", "Sets the desired screen space size of triangles (in pixels). Smaller values result in smaller triangle. Set to 0 to disable adaptative factor with screen space size.");
        public static readonly GUIContent tessellationShapeFactorText = EditorGUIUtility.TrTextContent("Shape Factor", "Controls the strength of Phong tessellation shape (lerp factor).");
        public static readonly GUIContent tessellationBackFaceCullEpsilonText = EditorGUIUtility.TrTextContent("Triangle Culling Epsilon", "Controls triangle culling. A value of -1.0 disables back face culling for tessellation, higher values produce more aggressive culling and better performance.");
        public static readonly GUIContent tessellationMaxDisplacementText = EditorGUIUtility.TrTextContent("Max Displacement", "Positive maximum displacement in meters of the current displaced geometry. This is used to adapt the culling algorithm in case of large deformation. It can be the maximum height in meters of a heightmap for example.");
        
        // Per pixel displacement
        public static readonly GUIContent ppdMinSamplesText = EditorGUIUtility.TrTextContent("Minimum Steps", "Controls the minimum number of steps URP+ uses for per pixel displacement mapping.");
        public static readonly GUIContent ppdMaxSamplesText = EditorGUIUtility.TrTextContent("Maximum Steps", "Controls the maximum number of steps URP+ uses for per pixel displacement mapping.");
        public static readonly GUIContent ppdLodThresholdText = EditorGUIUtility.TrTextContent("Fading Mip Level Start", "Controls the Height Map mip level where the parallax occlusion mapping effect begins to disappear.");
        public static readonly GUIContent ppdPrimitiveLength = EditorGUIUtility.TrTextContent("Primitive Length", "Sets the length of the primitive (with the scale of 1) to which URP+ applies per-pixel displacement mapping. For example, the standard quad is 1 x 1 meter, while the standard plane is 10 x 10 meters.");
        public static readonly GUIContent ppdPrimitiveWidth = EditorGUIUtility.TrTextContent("Primitive Width", "Sets the width of the primitive (with the scale of 1) to which URP+ applies per-pixel displacement mapping. For example, the standard quad is 1 x 1 meter, while the standard plane is 10 x 10 meters.");

        public static readonly GUIContent enableGeometricSpecularAAText = EditorGUIUtility.TrTextContent("Geometric Specular AA", "When enabled, URP+ reduces specular aliasing on high density meshes (particularly useful when the not using a normal map).");
        public static readonly GUIContent specularAAScreenSpaceVarianceText = EditorGUIUtility.TrTextContent("Screen space variance", "Controls the strength of the Specular AA reduction. Higher values give a more blurry result and less aliasing.");
        public static readonly GUIContent specularAAThresholdText = EditorGUIUtility.TrTextContent("Threshold", "Controls the effect of Specular AA reduction. A values of 0 does not apply reduction, higher values allow higher reduction.");

        // Surface Inputs
        public static readonly GUIContent baseColorText = EditorGUIUtility.TrTextContent("Base Map", "Specifies the base color (RGB) and opacity (A) of the Material.");
        public static readonly GUIContent metallicText = EditorGUIUtility.TrTextContent("Metallic", "Controls the scale factor for the Material's metallic effect.");
        public static readonly GUIContent metallicRemappingText = EditorGUIUtility.TrTextContent("Metallic Remapping", "Controls a remap for the metallic channel in the Mask Map.");
        public static readonly GUIContent smoothnessText = EditorGUIUtility.TrTextContent("Smoothness", "Controls the scale factor for the Material's smoothness.");
        public static readonly GUIContent smoothnessRemappingText = EditorGUIUtility.TrTextContent("Smoothness Remapping", "Controls a remap for the smoothness channel in the Mask Map.");
        public static readonly GUIContent aoRemappingText = EditorGUIUtility.TrTextContent("Ambient Occlusion Remapping", "Controls a remap for the ambient occlusion channel in the Mask Map.");
        public static readonly GUIContent maskMapSText = EditorGUIUtility.TrTextContent("Mask Map", "Specifies the Mask Map for this Material - Metallic (R), Ambient occlusion (G), Detail mask (B), Smoothness (A).");
        public static readonly GUIContent maskMapSpecularText = EditorGUIUtility.TrTextContent("Mask Map", "Specifies the Mask Map for this Material - Ambient occlusion (G), Detail mask (B), Smoothness (A).");

        public static readonly GUIContent normalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Specifies the Normal Map for this Material and controls its strength.");
        public static readonly GUIContent bentNormalMapText = EditorGUIUtility.TrTextContent("Bent normal map", "Specifies the cosine weighted Bent Normal Map for this Material. Use only with indirect diffuse lighting (Lightmaps and Light Probes).");

        // Height
        public static readonly GUIContent heightMapText = EditorGUIUtility.TrTextContent("Height Map", "Specifies the Height Map (R) for this Material.\nFor floating point textures, set the Min, Max, and base values to 0, 1, and 0 respectively.");
        public static readonly GUIContent heightMapCenterText = EditorGUIUtility.TrTextContent("Base", "Controls the base of the Height Map (between 0 and 1).");
        public static readonly GUIContent heightMapMinText = EditorGUIUtility.TrTextContent("Min", "Sets the minimum value in the Height Map (in centimeters).");
        public static readonly GUIContent heightMapMaxText = EditorGUIUtility.TrTextContent("Max", "Sets the maximum value in the Height Map (in centimeters).");
        public static readonly GUIContent heightMapAmplitudeText = EditorGUIUtility.TrTextContent("Amplitude", "Sets the amplitude of the Height Map (in centimeters).");
        public static readonly GUIContent heightMapOffsetText = EditorGUIUtility.TrTextContent("Offset", "Sets the offset URP+ applies to the Height Map (in centimeters).");
        public static readonly GUIContent heightMapParametrization = EditorGUIUtility.TrTextContent("Parametrization", "Specifies the parametrization method for the Height Map.");

        // Anisotropy
        public static readonly GUIContent tangentMapText = EditorGUIUtility.TrTextContent("Tangent Map", "Specifies the Tangent Map for this Material.");
        public static readonly GUIContent anisotropyText = EditorGUIUtility.TrTextContent("Anisotropy", "Controls the scale factor for anisotropy.");
        public static readonly GUIContent anisotropyMapText = EditorGUIUtility.TrTextContent("Anisotropy Map", "Specifies the Anisotropy Map(R) for this Material.");

        // Specular color
        public static readonly GUIContent specularColorText = EditorGUIUtility.TrTextContent("Specular Color", "Specifies the Specular color (RGB) of this Material.");
        // Iridescence
        public static readonly GUIContent iridescenceLUTText = EditorGUIUtility.TrTextContent("Iridescence LUT");
        public static readonly GUIContent iridescenceMaskText = EditorGUIUtility.TrTextContent("Iridescence Mask", "Specifies the Iridescence Mask (R) for this Material - This map controls the intensity of the iridescence.");
        public static readonly GUIContent iridescenceThicknessText = EditorGUIUtility.TrTextContent("Iridescence Layer Thickness");
        public static readonly GUIContent iridescenceThicknessMapText = EditorGUIUtility.TrTextContent("Iridescence Layer Thickness map", "Specifies the Thickness map (R) of the thin iridescence layer over the material. Unit is micrometer multiplied by 3. A value of 1 is remapped to 3 micrometers or 3000 nanometers.");
        public static readonly GUIContent iridescenceThicknessRemapText = EditorGUIUtility.TrTextContent("Iridescence Layer Thickness remap");
        // SubSurface Scattering
        public static readonly GUIContent thicknessText = EditorGUIUtility.TrTextContent("Thickness", "Controls the strength of the Thickness Map, low values allow some light to transmit through the object.");
        public static readonly GUIContent curvatureText = EditorGUIUtility.TrTextContent("Curvature", "Controls the strength of the Curvature Map.");
        public static readonly GUIContent thicknessMapText = EditorGUIUtility.TrTextContent("Thickness Map", "Specifies the Thickness Map (R) for this Material - This map describes the thickness of the object. When subsurface scattering is enabled, low values allow some light to transmit through the object.");
        public static readonly GUIContent thicknessCurvatureMapText = EditorGUIUtility.TrTextContent("TC Map", "Specifies the Thickness(R) and Curvature(G) for this Material - This map describes the thickness and curvature of the object. When subsurface scattering or translucency is enabled, low values allow some light to transmit through the object.");
        public static readonly GUIContent thicknessRemapText = EditorGUIUtility.TrTextContent("Thickness Remapping", "Controls a remap for the Thickness Map from [0, 1] to the specified range.");
        public static readonly GUIContent curvatureRemapText = EditorGUIUtility.TrTextContent("Curvature Remapping", "Controls a remap for the Curvature Map from [0, 1] to the specified range.");
        public static readonly GUIContent transmissionScaleText = EditorGUIUtility.TrTextContent("Transmission Scale", "Controls the strength of the transmission.");
        // Translucency
        public static readonly GUIContent translucencyScaleText = EditorGUIUtility.TrTextContent("Translucency Scale", "Controls the strength of the translucency.");
        public static readonly GUIContent translucencyPowerText = EditorGUIUtility.TrTextContent("Translucency Power", "Controls the power of the translucency.");
        public static readonly GUIContent translucencyAmbientText = EditorGUIUtility.TrTextContent("Translucency Ambient", "Controls the ambient of the translucency.");
        public static readonly GUIContent translucencyDistortionText = EditorGUIUtility.TrTextContent("Translucency Distortion", "Controls the distortion of the translucency.");
        public static readonly GUIContent translucencyShadowsText = EditorGUIUtility.TrTextContent("Translucency Shadows", "Controls the strength of the shadows that effects on translucency.");

        // CoatMask
        public static readonly GUIContent clearCoatMaskText = EditorGUIUtility.TrTextContent("Coat Mask",
                "Specifies the amount of the coat blending." +
                "\nActs as a multiplier of the clear coat map mask value or as a direct mask value if no map is specified." +
                "\nThe map specifies clear coat mask in the red channel and clear coat smoothness in the green channel.");

        public static readonly GUIContent clearCoatSmoothnessText = EditorGUIUtility.TrTextContent("ClearCoat Smoothness",
                "Specifies the smoothness of the coating." +
                "\nActs as a multiplier of the clear coat map smoothness value or as a direct smoothness value if no map is specified.");
        public static readonly GUIContent coatNormalMapText = EditorGUIUtility.TrTextContent("Coat Normal Map", "Specifies the Coat Normal Map for this Material and controls its strength.");

        // DetailMap
        public static readonly GUIContent detailMapNormalText = EditorGUIUtility.TrTextContent("Detail Map", "Specifies the Detail Map albedo (R) Normal map y-axis (G) Smoothness (B) Normal map x-axis (A) - Neutral value is (0.5, 0.5, 0.5, 0.5)");
        public static readonly GUIContent detailAlbedoScaleText = EditorGUIUtility.TrTextContent("Detail Albedo Scale", "Controls the scale factor for the Detail Map's Albedo.");
        public static readonly GUIContent detailNormalScaleText = EditorGUIUtility.TrTextContent("Detail Normal Scale", "Controls the scale factor for the Detail Map's Normal map.");
        public static readonly GUIContent detailSmoothnessScaleText = EditorGUIUtility.TrTextContent("Detail Smoothness Scale", "Controls the scale factor for the Detail Map's Smoothness.");

        // Emission Inputs
        public static readonly GUIContent emissionEnableText = EditorGUIUtility.TrTextContent("Emission", "Makes the surface look like it emits lights.");
        public static readonly GUIContent emissiveMapText = EditorGUIUtility.TrTextContent("Emissive Map", "Specifies the emissive color (RGB) of the Material.");
        public static readonly GUIContent albedoAffectEmissiveText = EditorGUIUtility.TrTextContent("Emission multiply with Base", "Specifies whether or not the emission color is multiplied by the albedo.");
        public static readonly GUIContent emissiveIntensityText = EditorGUIUtility.TrTextContent("Emission Intensity", "Emission intensity in scale factor");

        // Advanced Options
        public static readonly GUIContent castShadowText = EditorGUIUtility.TrTextContent("Cast Shadows", "When enabled, this GameObject can cast shadows onto other GameObjects.");
        public static readonly GUIContent receiveShadowText = EditorGUIUtility.TrTextContent("Receive Shadows", "When enabled, other GameObjects can cast shadows onto this GameObject.");
        public static readonly GUIContent highlightsText = EditorGUIUtility.TrTextContent("Specular Highlights", "When enabled, the Material reflects the shine from direct lighting.");
        public static readonly GUIContent reflectionsText = EditorGUIUtility.TrTextContent("Environment Reflections", "When enabled, the Material samples reflections from the nearest Reflection Probes or Lighting Probe.");
        public static readonly GUIContent secondaryClearCoatNormalText = EditorGUIUtility.TrTextContent("ClearCoat Second Normal", "When enabled, the Material calculate another normal for ClearCoat.");
        public static readonly GUIContent horizonOcclusionText = EditorGUIUtility.TrTextContent("Horizon Occlusion");
        public static readonly GUIContent specularOcclusionModeText = EditorGUIUtility.TrTextContent("Specular Occlusion Mode", "Determines the mode used to compute specular occlusion");
        public static readonly GUIContent giOcclusionBiasText = EditorGUIUtility.TrTextContent("GIOcclusion Bias", "Controls bias of specular occlusion from GI");
        public static readonly GUIContent queueSlider = EditorGUIUtility.TrTextContent("Sorting Priority", "Determines the chronological rendering order for a Material. Materials with lower value are rendered first.");
        public static readonly GUIContent queueControl = EditorGUIUtility.TrTextContent("Queue Control", "Controls whether render queue is automatically set based on material surface type, or explicitly set by the user.");

        // Layer Options
        public static readonly GUIContent layerMapMaskText = EditorGUIUtility.TrTextContent("Layer Mask", "Specifies the Layer Mask for this Material");
        public static readonly GUIContent vertexColorModeText = EditorGUIUtility.TrTextContent("Vertex Color Mode", "Specifies the method URP+ uses to color vertices.\nMultiply: Multiplies vertex color with the mask.\nAdditive: Remaps vertex color values between [-1, 1] and adds them to the mask (neutral value is 0.5 vertex color).");
        public static readonly GUIContent layerCountText = EditorGUIUtility.TrTextContent("Layer Count", "Controls the number of layers for this Material.");
        public static readonly GUIContent useHeightBasedBlendText = EditorGUIUtility.TrTextContent("Use Height Based Blend", "When enabled, URP+ blends the layer with the underlying layer based on the height.");
        public static readonly GUIContent useMainLayerInfluenceModeText = EditorGUIUtility.TrTextContent("Main Layer Influence", "Switches between regular layers mode and base/layers mode.");
        public static readonly GUIContent heightTransition = EditorGUIUtility.TrTextContent("Height Transition", "Sets the size, in world units, of the smooth transition between layers.");
        public static readonly GUIContent layerInfluenceMapMaskText = EditorGUIUtility.TrTextContent("Layer Influence Mask", "Specifies the Layer Influence Mask for this Material.");
        public static readonly GUIContent opacityAsDensityText = EditorGUIUtility.TrTextContent("Use Opacity map as Density map", "When enabled, URP+ uses the opacity map (alpha channel of Base Color) as the Density map.");
        public static readonly GUIContent inheritBaseNormalText = EditorGUIUtility.TrTextContent("Normal influence", "Controls the strength of the normals inherited from the base layer.");
        public static readonly GUIContent inheritBaseHeightText = EditorGUIUtility.TrTextContent("Heightmap influence", "Controls the strength of the height map inherited from the base layer.");
        public static readonly GUIContent inheritBaseColorText = EditorGUIUtility.TrTextContent("BaseColor influence", "Controls the strength of the Base Color inherited from the base layer.");

        // Hair Surface Inputs
        public static readonly GUIContent aoMapText = EditorGUIUtility.TrTextContent("AO Map", "Assign a Texture that defines the ambient occlusion for this material.");
        public static readonly GUIContent smoothnessMaskText = EditorGUIUtility.TrTextContent("Smoothness Mask", "Assign a Texture that defines the smoothness for this material.");
        public static readonly GUIContent specularColorHairText = EditorGUIUtility.TrTextContent("Specular Color", "Set the representative color of the highlight that Unity uses to drive both the primary specular highlight color, which is mainly monochrome, and the secondary specular highlight color, which is chromatic.");
        public static readonly GUIContent specularMultiplierText = EditorGUIUtility.TrTextContent("Specular Multiplier", "Modifies the primary specular highlight by this multiplier.");
        public static readonly GUIContent specularShiftText = EditorGUIUtility.TrTextContent("Specular Shift", "Modifies the position of the primary specular highlight.");
        public static readonly GUIContent secondarySpecularMultiplierText = EditorGUIUtility.TrTextContent("Secondary Specular Multiplier", "Modifies the secondary specular highlight by this multiplier.");
        public static readonly GUIContent secondarySpecularShiftText = EditorGUIUtility.TrTextContent("Secondary Specular Shift", "Modifies the position of the secondary specular highlight.");
        public static readonly GUIContent transmissionColorText = EditorGUIUtility.TrTextContent("Transmission Color", "Set the fraction of specular lighting that penetrates the hair from behind.");
        public static readonly GUIContent transmissionRimText = EditorGUIUtility.TrTextContent("Transmission Rim", "Set the intensity of back lit hair around the edge of the hair.");
    }
    internal class LayeredStyles
    {
        public static Vector2 layerIconSize = new Vector2(5, 5);
        public static GUIContent[] layers { get; } =
        {
            EditorGUIUtility.TrTextContent(" Main layer", icon: Texture2D.whiteTexture),
            EditorGUIUtility.TrTextContent(" Layer 1", icon: CoreEditorStyles.redTexture),
            EditorGUIUtility.TrTextContent(" Layer 2", icon: CoreEditorStyles.greenTexture),
            EditorGUIUtility.TrTextContent(" Layer 3", icon: CoreEditorStyles.blueTexture),
        };
        public static LitExpandable[] layerExpandableBits { get; } =
        {
            LitExpandable.MainLayer,
            LitExpandable.Layer1,
            LitExpandable.Layer2,
            LitExpandable.Layer3,
        };
    }
}