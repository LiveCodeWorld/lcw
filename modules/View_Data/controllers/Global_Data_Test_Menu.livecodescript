script "Global | Data | Test | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Test | Menu
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

function mdl_fromIndexArray sIndexArray, uName, pMakePretty
   put item 2 of the extents of sIndexArray into mNum
   repeat with iNum = 1 to mNum
      put sIndexArray [iNum] into iArray
      put iArray [uName] into sTitle
      delete variable iArray [uName]
      --
      put "#" && sTitle after mdlText
      put CR after mdlText
      
      # Add Yaml
      if pStripEmpty is not false then
         put yaml_FromArray (iArray) into sYaml
      else
         combine iArray using CR and ":"
         put iArray into sYaml
      end if
      put sYaml & CR&CR after mdlText
   end repeat
   
   put "---" after mdlText
   put CR & "Yam Title:" && uName after mdlText
   put CR & "Created:" && the internet date after mdlText
   return mdlText
end mdl_fromIndexArray

function yaml_FromArray iArray
   local sYaml
   repeat for each key sKey in iArray
      put iArray [sKey] into sValue
      if sValue is not empty then
         put sKey & ":" && sValue & CR after sYaml
      end if
   end repeat
   delete char -1 of sYaml
   return sYaml
end yaml_FromArray

getprop displayDataLayout_Params
   put poly_ListNames() into polyNames
   return polyNames
end displayDataLayout_Params

getprop tiddlyOpen_Params [dView]
   put _WikiDomain() into wDomain
   get tiddlyFile_ListShort (wDomain)
   return it
end tiddlyOpen_Params

private function _TiddlyFile shortFile
   put _WikiDomain() into wDomain
   put tiddlyFolder_Get (wDomain) into tiddlyFolder
   put tiddlyFolder & shortFile into tiddlyFile
   if there is a file tiddlyFile then
      return tiddlyFile
   else
      return empty
   end if
end _TiddlyFile

private function _WikiDomain
   return "david.livecode.wiki"
end _WikiDomain


--> Global | Data | Test | Menu
-
on menu_TiddlyOpen dView, shortFile
   put _TiddlyFile (shortFile) into tiddlyFile
   display_TiddlyFile tiddlyFile
end menu_TiddlyOpen

on menu_DisplayStackfiles dView
   put the stackFile_Array of dView into sArray
   --
   repeat for each key sName in sArray
      put sArray [sName] into sKey
      put empty into sArray [sName][sKey]
   end repeat
   set the tree_Data of dView to sArray
end menu_DisplayStackfiles

on menu_DisplayDataLayout dView, polyName
   put poly_GetLayoutData (polyName) into layoutData
   --
   set the tree_Data of dView to layoutData
   set the poly_DataLayout [polyName] of dView to layoutData
end menu_DisplayDataLayout

on menu_TestMdl dView, polyName
   put poly_GetLayoutData (polyName) into layoutData
   --
   put mdl_fromIndexArray (layoutData, "name")
end menu_TestMdl

private on _
end _

on menu_SaveDataLayout dView
   put the poly_LayoutName of dView into polyName
   get lcw_Ask ("What do you want to call this dataLayout?", polyName, dView)
   put it into polyName
   --
   put the poly_DataLayout of dView into layoutData
   poly_SetLayoutData polyName, layoutData
   --
   menu_DisplayDataLayout dView, polyName
end menu_SaveDataLayout

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Data | Test | Menu")
end submenu_Dev
