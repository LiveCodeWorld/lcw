script "Global_View_Property_Menu"
--> MetaData
-
license: GPLv3
name: Global | View | Property | Menu
type: controller
version: 0.2


--> Menu | Props
-
local ViewPropertyMenu

on menu_Init tObject
   put the view_PropertyMenu of tObject into ViewPropertyMenu
end menu_Init

getprop menu_CheckTarget [mTarget]
   return true
   put the object_IsView of mTarget into someBoolean
   return someBoolean
end menu_CheckTarget


--> Global | View | Property | Menu
-
on menu_ViewProperty someView, someProp
   view_DoPropertyMenu someProp, someView
end menu_ViewProperty

on _
end _

on menu_EditViewBehavior someView
   put the behavior of someView into bObject
   edit the script of bObject
end menu_EditViewBehavior

on menu_EditViewTemplate mTarget
   put the view_Template of mTarget into templateObject
   object_GoTo templateObject
   put the behavior of templateObject into templateBehavior
   if exists(templateBehavior) then edit the script of templateBehavior
end menu_EditViewTemplate

on _
end _

on menu_PropertyPalette someView
   object_EditProperty someView
end menu_PropertyPalette

on menu_GoToTemplate someView
   put the template_Object of someView into tObject
   object_GoTo tObject
end menu_GoToTemplate

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | View | Property | Menu | Props
-
getprop some_Props [mTarget]
   return ViewPropertyMenu
end some_Props

getprop style_Name [mTarget]
   put the view_StyleName of mTarget into viewStyleName
   return viewStyleName
end style_Name

getprop style_Names [mTarget]
   put the template_StyleNames of mTarget into viewStyleNames
   if viewStyleNames is empty then
      put "Create new style" into viewStyleNames
   else
      put CR & "-" & CR & "Create new style" after viewStyleNames
   end if
   return viewStyleNames
end style_Names


--> Global | View | Property | Menu | Disabled
-
getprop disabled_EditViewBehavior [someView]
   put the behavior of someView into bObject
   put exists (bObject) into bExists
   if bExists is true then
      return false
   else
      return true
   end if
end disabled_EditViewBehavior

getprop disabled_ViewProperty [mTarget]
   if the long id of the target is not the long id of me then return false
   if exists(mTarget) is false then return true
   
   if ViewPropertyMenu is empty then
      return "delete"
   else
      return false
   end if
end disabled_ViewProperty


--> Global | View | Property | Menu | Helpers
-
command tree_BackspaceKey treeField
   put the linked_View of treeField into someView
   put the template_Array of someView into someArray
   
   set the itemdelimiter to "/"
   put the tree_SelectedPath of treeField into somePath
   
   switch the title_Text of treeField
      case "template_Array"
         -- display/template_StyleArrays/Bank Green/view_PropArray/...
         put item 3 of somePath into styleName
         put item 4 of somePath into arrayType
         if arrayType = "view_PropArray" then
            -- display/template_StyleArrays/Bank Green/view_PropArray/record_LabelLocked/true
            put 0 into cNum
            put item 5 of somePath into someProp
            put item 6 of somePath into someValue
            
            if someProp is empty then
               -- the whole "view_PropArray"
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType]
            else
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType][someProp]
            end if
         else
            -- display/template_StyleArrays/Bank Green/view_RevPropArray/1/htmlText/1234
            put item 5 of somePath into cNum
            put item 6 of somePath into someProp
            put item 7 of somePath into someValue
            
            if someProp is empty then
               -- a whole object
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType][cNum]
            else
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType][cNum][someProp]
            end if
         end if
         break
      case "view_RevPropertyArray"
         put item 1 of somePath into cNum
         put item 2 of somePath into someProp
         put item 3 of somePath into someValue
         
         if someProp is empty then
            -- a whole object
            delete local someArray [cNum]
         else
            delete local someArray [cNum][someProp]
         end if
         break
   end switch
   
   set the template_Array of someView to someArray
   put array_ToOutline (someArray) into someOutline
   set the tree_Outline of treeField to someOutline
end tree_BackspaceKey

command deleteTemplateArray
   put the params
end deleteTemplateArray


--> Dev | Menu
-
on submenu_Swap
   return "Global | View | Update | Menu"
end submenu_Swap

on menu_ViewOutline someView
   display_ViewOutline someView
end menu_ViewOutline

on menu_TemplateOutline someView
   put the view_Template of someView into templateObject
   display_ViewOutline templateObject
end menu_TemplateOutline

on _
end _

on menu_ViewStyle mTarget, styleName
   if styleName = "Create new style" then
      view_CreateNewStyle mTarget
   else
      set the view_Style of mTarget to styleName
   end if
end menu_ViewStyle

on menu_DisplayArray someView, menuChoice
   switch menuChoice
      case "template_Array"
         put the template_Array of someView into someArray
         break
      case "view_DisplayedStyleArray"
         put the view_DisplayedStyleArray of someView into someArray
         break
      case "view_RevPropertyArray"
         put the view_RevPropArray of someView into someArray
         break
   end switch
   
   if someArray is not an array then
      beep
      opn_Notify "Array is empty!", true
      return false
   end if
   
   
   display_Array someArray, menuChoice
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   put the object_Hkey ["tree_BackspaceKey,c"] of me into hKey
   set the event_Trigger ["backspaceKey"] of treeField to hKey
   set the linked_View of treeField to someView
end menu_DisplayArray
