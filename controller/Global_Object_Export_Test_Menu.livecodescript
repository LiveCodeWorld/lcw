script "Global_Object_Export_Test_Menu"
--> MetaData
-
license: GPLv3
name: Global_Object_Export_Test_Menu
type: controller
version: 0.1


--> Menu | Props
-
local LocalArray


--> Global | Object | Export | Test | Menu
-
on menu_RevealTextStackFolder scriptObject
   put the textStack_Folder of scriptObject into someFolder
   finder_Reveal someFolder
end menu_RevealTextStackFolder

on menu_RevealObjectFolder scriptObject
   put the object_Folder [true] of scriptObject into someFolder
   finder_Reveal someFolder
end menu_RevealObjectFolder

on _
end _

on menu_FetchManifestArrayForStack scriptObject, stackObject
   put the meta_ManifestArray of stackObject into someArray
   display_Array someArray, "the meta_ManifestArray"
end menu_FetchManifestArrayForStack

on menu_FetchMainStackManifestArray scriptObject
   put the mainStack_ManifestArray of scriptObject into someArray
   display_Array someArray, "the mainStack_ManifestArray"
end menu_FetchMainStackManifestArray

getprop stack_Objects [scriptObject]
   if exists (scriptObject) is false then return empty
   put the main_Stack of scriptObject into mainStackObject
   
   put revRuggedID (mainStackObject) into stackObjectMenu
   
   put the short name of mainStackObject into mainStackName
   put the substacks of mainStackObject into subStackNames
   if subStackNames is empty then return stackObjectMenu
   
   put CR & "-" & CR after stackObjectMenu
   repeat for each line subStackName in subStackNames
      put the long name of stack subStackName of stack mainStackName into subStack
      put revRuggedID (subStack) into subStack
      put subStack & CR after stackObjectMenu
   end repeat
   delete char -1 of stackObjectMenu
   return stackObjectMenu
end stack_Objects
      
on menu_ObjectPropertyArray scriptObject
   put the object_PropertyArray of scriptObject into objectPropArray
   display_Array objectPropArray, "object_PropertyArray"
end menu_ObjectPropertyArray

on menu_ObjectArray scriptObject
   put the object_Array of scriptObject into someArray
   objectArray_StripScripts someArray
   display_Array someArray, "the object_Array"
end menu_ObjectArray


on _
end _
   
on menu_LiveMainStackArray scriptObject
   put the object_MainStackArray of scriptObject into someArray
   objectArray_StripScripts someArray
   display_Array someArray, "the object_MainStackArray"
end menu_LiveMainStackArray

on menu_LiveStackArray scriptObject
   put the stack_Array of scriptObject into stackArray
   display_StackArray stackArray, "the stack_Array"
end menu_LiveStackArray

on menu_LiveCardArray scriptObject
   put the card_Array of scriptObject into someArray
   objectArray_StripScripts someArray
   display_Array someArray, "the card_Array"
end menu_LiveCardArray

on _
end _

on menu_ObjectPropertyText scriptObject
   put the long id of btn 1 of me into scriptObject
   put the object_PropertyText of scriptObject into propText   
   display_Text propText
end menu_ObjectPropertyText

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Object | Export | Test | Menu | Disabled
-
getprop disabled_RevealTextStackFolder [scriptObject]
   put the textStack_Folder of scriptObject into someFolder
   return there is not a folder someFolder
end disabled_RevealTextStackFolder

getprop disabled_RevealObjectFolder [scriptObject]
   put the object_Folder of scriptObject into someFolder
   return there is not a folder someFolder
end disabled_RevealObjectFolder


--> Dev | Menu
-
on menu_DisplayMetaArray scriptObject
   put the meta_Array of scriptObject into metaArray
   display_Array metaArray, "meta_Array"
end menu_DisplayMetaArray

on _
end _

on menu_TestMergeScript someButton
   delete variable LocalArray
   
   put revRuggedID (someButton) into rObject
   put the script of rObject into oScript
   put oScript into mergeScript
   put the revAvailableHandlers of rObject into handlerTable
   
   script_ExportHandlerFolder handlerTable, oScript
   put the result into mergeScript
   
   put script_MergeLines (mergeScript, handlerTable) into remergedScript
   
   put remergedScript = oScript into someBoolean
   put mergeScript & CR & CR & Cr & remergedScript
   answer someBoolean
end menu_TestMergeScript

on menu_TestSpeeds
   timer_Start "the object_ScriptArray"
   repeat 10
      get the object_ScriptArray of stack "libOPN_ObjectText"
   end repeat
   timer_Stop "the object_ScriptArray"
   
   timer_Start "the hArray_ScriptData"
   repeat 10
      get the hArray_ScriptData of stack "libOPN_ObjectText"
   end repeat
   timer_Stop "the hArray_ScriptData"
   
   timer_Start "the revAvailableHandlers"
   repeat 10
      get the revAvailableHandlers of stack "libOPN_ObjectText"
   end repeat
   timer_Stop "the revAvailableHandlers"
   
   put the name of stack "libOPN_ObjectText" into tObject
   timer_Start "object_ConstructMergeScriptArray (tObject)"
   repeat 10
      get object_ConstructMergeScriptArray (tObject)
   end repeat
   timer_Stop "object_ConstructMergeScriptArray (tObject)"
end menu_TestSpeeds
