script "Global_Handler_Menu"
--> MetaData
-
license: GPLv3
name: Global_Handler_Menu
type: controller
version: 0.4


--> Menu | Props
-
/*
Changed this menu to be a general hKey menu. 
The menu_Init code has been removed so it can be placed in the local mController that calls the hkey menu.
See the behavior "Livecode Script History Button"
*/

local LocalArray

getprop menu_CheckTarget [hKey]
   put library_HandlerFile (hKey, empty, true) into hkeyFolder
   put hkeyFolder into LocalArray ["hkeyFolder"]
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   return exists (hObject)
end menu_CheckTarget


--> Global | Handler | Menu
-
on menu_SaveAsGist hKey
   local shortGistFile
   gist_SaveHkey hKey, shortGistFile
   put the result into gistReplyArray
   
   put gistReplyArray ["html_url"] into htmlURL
   launch url htmlURL
   
   display_Array gistReplyArray, shortGistFile
end menu_SaveAsGist

on menu_SaveAsPrivateGist hKey
   local shortGistFile
   put hkey_FetchHelp (hKey) into helpText
   put html_StripAllTags (helpText) into helpText
   put opn_Ask ("Give a description for [[hKey]]...", helpText) into pDescription
   gist_SaveHkey hKey, shortGistFile, pDescription, true
   put the result into gistReplyArray
   display_Array gistReplyArray, shortGistFile
end menu_SaveAsPrivateGist

on _
end _

on menu_OtherObjectsWithHandler hKey, otherPlace
   put LocalArray ["friendlyArray"][otherPlace] into otherPlace
   put revRuggedID (otherPlace) into item 3 of hKey
   put 1 into item 4 of hKey
   hkey_EditFoundHandler hkey
end menu_OtherObjectsWithHandler

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Handler | Menu | Props
-
getprop other_Places [hKey]
   return LocalArray ["orderedFriendlyObjects"]
end other_Places

getprop suite_Title
   rev_SetScriptEditorInfo hKey, someHandler, suiteTitle, scriptSuite, scriptObject
   return suiteTitle
end suite_Title

getprop suite_Titles
   put rev_ScriptObject() into scriptObject
   put the script_SuiteTitles of scriptObject into suiteTitles
   -- display_Text suiteTitles
   return word 1 to -1 of suiteTitles
end suite_Titles


--> Global | Handler | Menu | Disabled
-
getprop disabled_ExportHandler [hKey]
   put LocalArray ["hkeyFolder"] into hkeyFolder
   if there is a folder hkeyFolder then
      return "delete"
   else
      return false
   end if
end disabled_ExportHandler

getprop disabled_ReexportHandler [hKey]
   put LocalArray ["hkeyFolder"] into hkeyFolder
   if there is a folder hkeyFolder then
      return false
   else
      return "delete"
   end if
end disabled_ReexportHandler

getprop disabled_OtherObjectsWithHandler [hKey]
   put hArray_GetOtherPlaces (hKey) into otherObjects
   put item 3 of hKey into scriptObject
   line_Delete scriptObject, otherObjects
   
   if otherObjects is empty then
      delete variable LocalArray ["orderedFriendlyObjects"]
      delete variable LocalArray ["friendlyArray"]
      
      return "delete"
   else
      objects_MakeFriendly otherObjects, orderedFriendlyObjects, friendlyArray
      put orderedFriendlyObjects into LocalArray ["orderedFriendlyObjects"]
      put friendlyArray into LocalArray ["friendlyArray"]
      
      return false
   end if
end disabled_OtherObjectsWithHandler


--> Dev | Menu
-
on menu_FindSimilarHandlers hKey
   put hkey_ConstructKeywords (item 1 of hKey) into keywordList
   replace CR with comma in keywordList
   put opn_Ask ("Input some handler names or keywords seperated by commas...", keywordList) into keywordList
   
   put hArray_ListShortKeys (keywordList) into hKeys
   display_HkeyIndex hKeys
end menu_FindSimilarHandlers

on menu_AnalizeMainStack hKey
   put item 3 of hKey into hObject
   put the main_Stack of hObject into scriptObject
   display_ScriptObject scriptObject
end menu_AnalizeMainStack

on menu_UnitTests hKey
   display_UnitTests hKey
end menu_UnitTests

on _
end _

on menu_AddHandlerToLibrary hKey
   library_AddHkey hKey
   
   display_Hkey hKey, "project"
   put merge ("Added handler '[[item 1 to 2 of hKey]]' to the handler library!") into someComment
   opn_Notify someComment
end menu_AddHandlerToLibrary

on menu_EditHandler hKey
   hkey_Edit hKey
end menu_EditHandler

on menu_EditHandlerHelp hKey
   put hkey_FetchHelp (hKey) into helpText
   put opn_Ask ("Edit the help text...", helpText) into helpText
   hkey_StoreHelp hKey, helpText
end menu_EditHandlerHelp

on menu_RevealHandlerHelpFile hKey
   put hkey_HelpFile (hKey) into someFile
   finder_Reveal someFile
end menu_RevealHandlerHelpFile

on _
end _

on menu_ReindexHandlerHarray hKey
   -- could directly do this
   -- hArray_AddHandlerHash hArray, hKey, someHandler, handlerHash, indexTime
   -- but may not properly index the entire script that way?
   
   -- the other way to do it is to hack hArray, and delete the handlerHashEntry for that key
   -- if handlerHashArray ["cached"][handlerHash]["indexTime"] is empty then -- this is what "object_AddToArray" check to reindex
   --alternatively we could look up the hKey in all the handler hashes, but for now lets assume the existing hash is valid
   opn_Answer "Fix this handlers global hArray entry?"
   
   put hArray_GetHandlerHash (hKey) into handlerHash
   
   /* forgot handlerHashArray is not stored in the global array, only locally stored mainstack arrays
   -- first let's do the global hArray
   global gHkey_Array
   if gHkey_Array ["handlerHashArray"]["cached"][handlerHash] is an array then -- othewise could just get this one handler indexed?
      put empty into gHkey_Array ["handlerHashArray"]["cached"][handlerHash]["indexTime"]
      object_AddToGlobalArray someObject
      put "Reindexed" && hKey & ", and updated the global gHkey_Array!" into someComment
      opn_Notify someComment
   end if
   */
   
   put item 3 of hKey into scriptObject
   put the textStack_Folder of scriptObject into mainStackFolder
   put mainstack_FetchHarray (mainStackFolder) into hArray
   --
   if hArray ["handlerHashArray"]["cached"][handlerHash] is an array then
      put empty into hArray ["handlerHashArray"]["cached"][handlerHash]["indexTime"]
   end if
   put the script of scriptObject into someScript
   put false into pExportHandlers
   put pref_GetValue ("Construct hashArray on stack export") into pCreateHashArray
   object_AddToArray hArray, scriptObject, someScript, pExportHandlers, pCreateHashArray  -- force reindex
   --
   mainstack_StoreHarray hArray, mainStackFolder
   
   put "Reindexed" && hKey & ", and stored the new mainstack metadata!" into someComment
   opn_Notify someComment
end menu_ReindexHandlerHarray
