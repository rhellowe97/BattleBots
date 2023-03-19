using Sirenix.OdinInspector.Editor;
using UnityEditor;
using UnityEngine;

[DrawerPriority( DrawerPriorityLevel.WrapperPriority )]
public class DisplayInParentAttributeDrawer : OdinAttributeDrawer<DisplayInParentAttribute>
{
    protected override void DrawPropertyLayout( GUIContent label )
    {
        EditorGUILayout.BeginHorizontal();

        if ( label != null )
            EditorGUILayout.PrefixLabel( label );

        EditorGUILayout.BeginVertical();

        for ( int i = 0; i < Property.Children.Count; ++i )
            Property.Children[i].Draw();

        EditorGUILayout.EndVertical();

        EditorGUILayout.EndHorizontal();
    }
}
