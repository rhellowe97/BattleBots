using DB;
using Sirenix.OdinInspector.Editor;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

public class IDBRefAttributeProcessor : OdinAttributeProcessor
{
    public static List<Type> PropagatedAttributes = new List<Type>()
    {
        typeof(Sirenix.OdinInspector.InlineEditorAttribute),
    };

    protected List<Attribute> cachedAttributes = new List<Attribute>();

    public override bool CanProcessSelfAttributes( InspectorProperty property )
    {
        return true;
    }

    public override bool CanProcessChildMemberAttributes( InspectorProperty parentProperty, MemberInfo member )
    {
        if ( member.MemberType == MemberTypes.Property )
            return true;

        return false;
    }

    public override void ProcessSelfAttributes( InspectorProperty property, List<Attribute> attributes )
    {
        for ( int i = attributes.Count - 1; i >= 0; --i )
        {
            if ( PropagatedAttributes.Contains( attributes[i].GetType() ) )
            {
                cachedAttributes.Add( attributes[i] );
                attributes.RemoveAt( i );
            }
        }
    }

    public override void ProcessChildMemberAttributes( InspectorProperty parentProperty, MemberInfo member, List<Attribute> attributes )
    {
        foreach ( var attribute in cachedAttributes )
            attributes.Add( attribute );
    }
}
