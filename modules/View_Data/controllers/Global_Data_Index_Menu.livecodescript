script "Global | Data | Index | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Index | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Data | Index | Menu
-
on menu_FormattedWidth dView
   put the formatted_Width of dView into fWidth
   set the stack_Width of dView to fWidth
end menu_FormattedWidth

on menu_FormattedHeight dView
   put the formatted_Height of dView into fHeight
   set the stack_Height of dView to fHeight
end menu_FormattedHeight

private on ___
end ___

on menu_ChangeDoubleClick indexView
   put the doubleClick_Message of indexView into mDoubleUp
   put lcw_Ask ("Edit the doubleClick_Message of indexView", mDoubleUp) into mDoubleUp
   --
   set the doubleClick_Message of indexView to mDoubleUp
end menu_ChangeDoubleClick

on menu_FindDoubleClickHandler indexView
   put the doubleClick_Message of indexView into mDoubleUp
   put "M" && mDoubleUp into shortHkey
   --
   put the mouse_Target of indexView into mTarget
   if exists (mTarget) is false then
      lcw_AnswerWarning "The mouse_Target of [[indexView]] does not exist!", indexView, indexView
   end if
   
   put the found_Hkey [shortHkey] of mTarget into hKey
   if hKey is empty then
      put shortHkey
      lcw_AnswerWarning "Cannot locate [[shortHkey]]", indexView, shortHkey
   else
      hkey_Edit hKey
   end if
end menu_FindDoubleClickHandler

private on __
end __

on menu_InspectIndexField indexView
   put the index_Field of indexView into indexField
   revIDEInspectObjects indexField
end menu_InspectIndexField

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on submenu_Dev
   return "Global | Data | Index | Menu"
end submenu_Dev
