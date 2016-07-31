script "behavior_View|Tree|Datagrid"
--> MetaData
-
license: GPLv3
name: behavior_View|Tree|Datagrid
type: view behavior
version: 0.1
copyright: David Bovill

/*
Here we have a general header and body view, designed to display information felxibly.
*/

getprop datagrid_Tree
    return the long id of me
end  datagrid_Tree

getprop view_Object
    return the long id of me
end view_Object


--> Datagrid
-
getprop dg_Data
   put the dg_View of me into revDataGrid
   if exists(revDataGrid) is false then return empty
   
   put the dgData of revDataGrid into dataArray
   return dataArray
end dg_Data

setprop dg_Data [someTitle] dataArray
   put the dg_View of me into revDataGrid
   if exists(revDataGrid) is false then return empty
   
   lock screen
   set the dgData of revDataGrid to dataArray
   if someTitle is not empty then
      put the title_View of me into titleView
      set the title_Text of titleView to someTitle
   end if
   unlock screen
   return dgView
end dg_Data

getprop record_Behavior
   put the record_View of the target into recordObject
   if exists (recordObject) is false then return empty
   put the behavior of recordObject into someObject
   return someObject
end record_Behavior

setprop record_Behavior someObject
   put the record_View of the target into recordObject
   if exists (recordObject) is false then return empty
   set the behavior of recordObject to someObject
   return someObject
end record_Behavior

setprop record_Behavior someObject
   put the record_View of the target into recordObject
   if exists (recordObject) is false then return empty
   set the behavior of recordObject to someObject
   return someObject
end record_Behavior

getprop record_View
   put the dg_View of me into revDataGrid
   if exists(revDataGrid) is false then return empty
   put the dgProps ["row template"] of revDataGrid into someObject
   return someObject
end record_View

setprop record_View someObject
   put the dg_View of me into revDataGrid
   if exists(revDataGrid) is false then return empty
   set the dgProps ["row template"] of revDataGrid to someObject
   return someView
end record_View

getprop record_ViewName
   put the record_View of me into templateObject
   if exists (templateObject) is false then return empty
   return the view_Name of templateObject
end record_ViewName
 
setprop record_ViewName vName
   put the dg_View of me into revDataGrid

   put view_GetTemplateObject (vName) into templateObject
   if exists(templateObject) is false then return empty
   put the long id of templateObject into templateObject
   set the dgProps ["row template"] of revDataGrid to templateObject
   return templateObject
end record_ViewName


--> Menu | Props
-
/*
getprop menu_Target [mTitlePath]
   set the itemDelimiter to "|"
   switch
      case mTitlePath contains "Global | Tree |"
         return the tree_Field of me
      case mTitlePath contains "Global | Title |"
         return the title_View of me
      default
         pass menu_Target
   end switch
end menu_Target

getprop menu_Title
   if the long id of the target is not the long id of me then pass menu_Title
   put the view_Value ["menu_Title"] of me into mTitle
   -- put the uOPN ["menu_Title"] of me into mTitle
   if mTitle is not empty then return mTitle
   put the menu_DefaultTitle of me into mTitle
   return mTitle
end menu_Title

setprop menu_Title mTitle
   if the long id of the target is not the long id of me then pass menu_Title
   set the view_Value ["menu_Title"] of me to mTitle
   -- set the uOPN ["menu_Title"] of me to mTitle
end menu_Title

getprop menu_DefaultTitle
   if the long id of the target is not the long id of me then pass menu_DefaultTitle
   put the menu_DefaultTitle of the body_View of me into mTitle
   return mTitle
end menu_DefaultTitle

getprop menu_ToolTitle
   if the long id of the target is not the long id of me then pass menu_ToolTitle
   put the view_Value ["menu_ToolTitle"] of the target into mTitle
   if mTitle is not empty then
      return mTitle
   else
      local testController
      put the menu_DefaultToolTitle of the body_View of me into globalMenuTitle
      menu_SearchGlobalObjectHierarchy globalMenuTitle, testController
      return globalMenuTitle
   end if
end menu_ToolTitle
*/


--> Title
-
/*
These standard title_View scripts are passed down to be handeled by the title_View of the layout.

In order to avoid recursion if the target = the title_View then the call are passed,
however calls to a target within the body view or to this view itself are accepted.
*/

getprop title_Text
    if the long id of the target is not the long id of me then pass title_Text
   put the title_View of me into titleView
   put the title_Text of titleView into titleText
   return titleText
end title_Text

setprop title_Text titleText
   if the long id of the target is not the long id of me then pass title_Text
   put the title_View of me into titleView
   set the title_Text of titleView to titleText
end title_Text

getprop title_TextAlign
   put the title_View of me into titleView
   if the long id of the target = titleView then pass title_TextAlign
   get the title_TextAlign of titleView
   return it
end title_TextAlign

setprop title_TextAlign alignHow
   put the title_View of me into titleView
   if the long id of the target = titleView then pass title_TextAlign
   set the title_TextAlign of titleView to alignHow
end title_TextAlign


--> Title | Colours
-
getprop colour_Palette
   put the title_View of me into titleView
   if the long id of the target = titleView then pass colour_Palette
   get the colour_Palette of titleView
   return it
end colour_Palette

setprop colour_Palette colourPaletteArray
   put the title_View of me into titleView
   if the long id of the target = titleView then pass colour_Palette
   set the colour_Palette of titleView to colourPaletteArray
end colour_Palette

getprop title_TextColour
   put the title_View of me into titleView
   if the long id of the target = titleView then pass title_TextColour
   get the title_TextColour of titleView
   return it
end title_TextColour

setprop title_TextColour someColour
   put the title_View of me into titleView
   if the long id of the target = titleView then pass title_TextColour
   set the title_TextColour of titleView to someColour
end title_TextColour

getprop title_Colour
   put the title_View of me into titleView
   if the long id of the target = titleView then pass title_Colour
   get the title_Colour of titleView
   return it
end title_Colour

setprop title_Colour someColour
   put the title_View of me into titleView
   if the long id of the target = titleView then pass title_Colour
   set the title_Colour of titleView to someColour
end title_Colour


--> Geometry
-
on resizeControl
    if the long id of target = the long id of me is false then pass resizeControl
    LayoutControl the rect of me
end resizeControl

setprop view_Rect someRect
   if the long id of target is not the long id of me then pass view_Rect
   LayoutControl someRect
end view_Rect

on LayoutControl pRect
   if the long id of the target is not the long id of me then return empty -- this is important for nested datagrids at the moment.
   if pRect is empty then put the rect of me into pRect
   
   if pRect is empty then put the rect of me into pRect
   put the title_View of me into titleView
   put the body_View of me into bodyView
   
   put the inner_Rect [pRect] of me into innerRect
   put the view_Spacing of me into viewSpacing
   put the body_Indent of me into bodyIndent
   
   put the title_Height of titleView into titleHeight
   if titleHeight is empty then put the formatted_Height of titleView into titleHeight
   if titleHeight is empty then put the height of titleView into titleHeight
   
   put innerRect into titleRect
   put item 2 of innerRect + titleHeight into headerBottom
   put headerBottom into item 4 of titleRect
   
   put innerRect into bodyRect
   put headerBottom + viewSpacing into item 2 of bodyRect
   add bodyIndent to item 1 of bodyRect
   
   lock screen
   set the rect of titleView to titleRect
   set the rect of bodyView to bodyRect
   unlock screen
end LayoutControl

getprop view_Spacing
   put the customproperties of me into propArray
   put propArray ["view_Spacing"] into viewSpacing
   
   if viewSpacing is empty then pass view_Spacing
   if viewSpacing is empty then return 4
   return viewSpacing
end view_Spacing

setprop view_Spacing viewSpacing
   set the view_DisplayProperty ["view_Spacing"] of me to viewSpacing
   dispatch "LayoutControl" to me -- changes the target
   return the result
end view_Spacing

getprop body_Indent
   put the customproperties of me into propArray
   put propArray ["body_Indent"] into bodyIndent
   if bodyIndent is empty then pass body_Indent
   return bodyIndent
end body_Indent

setprop body_Indent bodyIndent
   set the view_DisplayProperty ["body_Indent"] of me to bodyIndent
   dispatch "LayoutControl" to me -- changes the target
   return the result
end body_Indent

getprop title_Height
   put the customproperties of me into propArray
   put propArray ["title_Height"] into titleHeight
   
   if titleHeight is empty then pass title_Height
   return titleHeight
end title_Height

setprop title_Height titleHeight 
   set the view_DisplayProperty ["title_Height"] of me to titleHeight
   dispatch "LayoutControl" to me -- changes the target
   return the result
end title_Height

getprop title_DefaultHeight
   return the height of the title_View of me
end title_DefaultHeight

getprop title_ViewName
   put the title_View of me into titleView
   put the view_Name of titleView into vName
   return vName
end title_ViewName
 
setprop title_ViewName vName
   put the title_View of me into titleView
   set the view_Swap of titleView to vName
end title_ViewName

getprop body_ViewName
   put the body_View of me into bodyView
   put the view_Name of bodyView into vName
   return vName
end body_ViewName
 
setprop body_ViewName vName
   put the body_View of me into bodyView
   set the view_Swap of bodyView to vName
end body_ViewName


--> Objects
-
getprop dg_View
   put the body_View of me into bodyView
   put the dgControl of bodyView into dgView
   return dgView
end dg_View

getprop tree_Field
   put the body_View of me into bodyView
   if the view_IsClass ["Tree|Field"] of bodyView is true then
      return bodyView
   else
      return empty
   end if
end tree_Field

getprop tree_View
   return the long id of me
end tree_View


--> Objects | Children
-
getprop title_View
   put the top_Control ["Title"] of me into someView
   return someView
end title_View

getprop header_View
   return the title_View of me
end header_View

getprop body_View
   put the top_Control ["Body"] of me into someView
   return someView
end body_View

getprop top_Control [pName]
   put the childcontrolids of me into topControlIDs
   switch
      case pName is empty
         put line 1 of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of me
      case pName is a number
         put line pName of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of me
      default
         repeat for each line cID in topControlIDs
            put the long id of control id cID of me into topControl
            if the short name of topControl = pName then
               return topControl
            end if
         end repeat
         return empty
   end switch
end top_Control

getprop menu_Button
   return the menu_Button of the title_View of me
end menu_Button
