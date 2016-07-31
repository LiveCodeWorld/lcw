script "Global_Script_Editor_Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Editor | Menu
type: controller
version: 0.3

/*
Moved to a script-only stack menu.
*/


--> Variables
-
local LocalArray
local BehaviorObjectMenu, ObjectDictionary, ViewNames


--> Menu | Props
-
getprop menu_Title [pMenuButton]
   put "This is not being called"
   if the shiftKey is "Down" then
      return "Global | Script Editor | Extras | Menu"
   else
      return "Global | Script | Editor | Menu"
   end if
end menu_Title

on menu_Init
   put rev_ScriptEditorField() into scriptField
   put scriptField into LocalArray ["scriptField"]
   
   field_SetSelected scriptField, textSelected, someLine, lineNum, someScript, startChar, endChar
   put textSelected into LocalArray ["textSelected"]
   put someLine into LocalArray ["someLine"]
   put lineNum into LocalArray ["lineNum"]
   put someScript into LocalArray ["someScript"]
   
   put hkey_FromSelected (someScript, endChar) into shortHkey
   put shortHkey into LocalArray ["selectedHkey"]
end menu_Init

getprop menu_Target [mTitlePath]
   put rev_ScriptObject() into scriptObject
   switch
      case mTitlePath contains "Global | Overlay | Array | Menu"
         put the overlay_Folder of scriptObject into overlayFolder
         return overlayFolder
      case mTitlePath = "Global | Script | Editor | Menu"
         return scriptObject
      default
         return scriptObject
   end switch
end menu_Target


--> Global | Script | Editor | Menu
-
on menu_FindLibraryHandler mTarget, findWhat
   put _getSelectedText (findWhat) into textToFind
   
   -- let's look in handler library folder
   put library_HandlerFolder() into findInsideFolder
   put spotlight_Find (textToFind, findInsideFolder) into filePaths
   
   -- sort filePaths
   put file_ConstructFolderArray (filePaths, "*/script.txt", findInsideFolder) into pathArray
   if pathArray is not an array then
      answer "I cannot find this handler anywhere!"
      exit to top
   end if
   
   put merge ("Files with hKey '[[textToFind]]") into someTitle
   display_Array pathArray, someTitle, titleMenu, lineMenu, "launchFile", "launchFile"
   put the result into treeWidget
   
   set the search_Folder of treeWidget to findInsideFolder
   set the search_Text of treeWidget to textToFind
end menu_FindLibraryHandler

on menu_FindProjectHandler mTarget, findWhat
   put _getSelectedText (findWhat) into textToFind
   
   local findInsideFolder -- let's look everywhere
   -- put project_HandlerFolder() into findInsideFolder -- let's look in handler any project folder
   put spotlight_Find (textToFind, findInsideFolder) into filePaths
   
   put "Global | Hkey | Send | Menu" into titleMenu
   put merge ("Files with hKey '[[item 1 of textToFind]]'") into someTitle
   display_Files filePaths, findInsideFolder, "launchFile", titleMenu, someTitle
   -- filePaths,"*/script.txt", fads 
   
   -- set the search_Folder of treeWidget to findInsideFolder
   set the search_Text of treeWidget to textToFind
end menu_FindProjectHandler

on _
end _

on menu_HierarchyObject mTarget, someThing
   menu_SetChoice someThing, someThing, someType
   put ObjectDictionary [someThing] into scriptObject
   if someType is "behavior" then
      put the behavior of scriptObject into scriptObject
   end if
   edit the script of scriptObject
end menu_HierarchyObject

on menu_CardView mTarget, viewThing
   put view_GetTemplateObject (viewThing) into someView
   if exists(someView) is false then
      beep
      exit to top
   end if
   
   put the behavior of someView into someBehavior
   if exists(someBehavior) then
      edit the script of someBehavior
   else
      edit the script of someView
   end if
end menu_CardView

on _
end _

on submenu_Script
   return "Global | Script | Edit | Menu"
end submenu_Script

on submenu_Behavior
   return "Global | Script | Behavior | Menu"
end submenu_Behavior

on submenu_ScriptBehavior
   return "Global | Dependency | Behavior | Menu"
end submenu_ScriptBehavior

on submenu_Template
   return "Global | Script | Template | Menu"
end submenu_Template

on _
end _

on menu_Go mTarget, whichStack
   switch whichStack
      case "Display Array"
         go to stack "Display Array"
         break
      case "Edit libOPN_Display"
         edit the script of stack "libOPN_Display"
         break
      case "-"
      case "View Browser"
         go to stack "libOPN_ViewBrowser"
         break
      case "libOPN_Menus"
         go to stack "libOPN_Menus"
         get library_ListGlobalMenuNames()
         sort it
         display_Lines it
         break
      case "libOPN_GIT"
         go to stack "libOPN_GIT"
         break
   end switch
end menu_Go

on menu_GoToObject
   put rev_ScriptObject() into someObject
   object_GoTo someObject
end menu_GoToObject

on submenu_Object
   return "Global | Script | Object | Menu"
end submenu_Object

on _
end _

on submenu_StackHistory
   return "Global | Git | Stack | History | Menu"
end submenu_StackHistory

-- on submenu_ScriptHistory
return "Global | Script | History | Menu"
end submenu_ScriptHistory

-- on submenu_Teamster
return "Global | Teamster | Menu"
end submenu_Teamster

-- on submenu_Script
return "Global | Script | Menu"
end submenu_Script

on submenu_Archive
   return "Global | OPN | Save Count | Menu"
end submenu_Archive

on _
end _

on submenu_Library
   return "Global | Library | Menu"
end submenu_Library

on submenu_ManageLibrary
   return "Global | Library | Manage | Menu"
end submenu_ManageLibrary

on submenu_Stack
   return "Global | Stack | Menu"
end submenu_Stack

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Script | Editor | Props
-
getprop some_Things [mTarget]
   return BehaviorObjectMenu
end some_Things

getprop view_Things [mTarget]
   return ViewNames
end view_Things

getprop find_Whats
   return "text,hkey"
end find_Whats

private function _getSelectedText findWhat
   switch findWhat
      case "text"
         put LocalArray ["textSelected"] into textToFind
         break
      case "hkey"
         put LocalArray ["selectedHkey"] into textToFind
         break
   end switch
   
   if textToFind is empty then
      put opn_Ask ("Enter some text to do a spotlight search for...") into textToFind
   end if
   return textToFind
end _getSelectedText


--> Global | Script | Editor | Disabled
-
getprop disabled_DisplayGlobalMenu
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   return exists (stack longStackFile) is false
end disabled_DisplayGlobalMenu

getprop disabled_HierarchyObject [mTarget]
   local longObjects, shortObjects, shortNames
   put the object_BehaviorHierarchyArray of mTarget into hierarchyArray
   
   put hierarchyArray ["longObjects"] into longObjects 
   put hierarchyArray ["menu"] into BehaviorObjectMenu
   put hierarchyArray ["dictionary"] into ObjectDictionary
   
   if longObjects is empty then
      return "delete"
   else
      return false
   end if
end disabled_HierarchyObject

getprop disabled_CardView [mTarget]
   put the card_Object of mTarget into cardObject
   if exists(cardObject) is false then return "delete"
   put the view_NameArray of cardObject into nameArray
   put keys(nameArray) into ViewNames
   if ViewNames is empty then
      return "delete"
   else
      return false
   end if
end disabled_CardView

getprop disabled_FindInHierarchy [mTarget]
   -- put the long id of the clickfield into scriptField
   put rev_ScriptEditorField() into scriptField
   if exists(scriptField) is false then return empty
   put the selectedtext of scriptField into someToken
   if someToken is empty then return "delete"
   
   if script_DictionaryTerm(someToken) is true then
      -- return "true"
      return "delete"
   else
      put hkey_GetSelected (scriptField) into hKey
      set the search_Hkey of me to hKey
      return false
   end if
end disabled_FindInHierarchy


--> Deps | Display
-
command launchFile treeWidget, shortPath
   -- for "display_Array" in "menu_FindLibraryHandler" and "menu_FindProjectHandler"
   
   put the search_Folder of treeWidget into findInsideFolder
   put the search_Text of treeWidget into textToFind
   
   text_AddTrailing findInsideFolder
   put findInsideFolder & shortPath into somePath
   set the itemdelimiter to "/"
   put item 1 of shortPath into shortHandlerFolder
   put hkey_FromShortFolder (shortHandlerFolder)
end launchFile


--> Deps
-
command field_SetSelected scriptField, @textSelected, @someLine, @lineNum, @someScript, @startChar, @endChar
   put the selectedText into textSelected   
   put the selectedchunk into chunkSelected
   put word 2 of the selectedLine into lineNum
   
   put word 2 of chunkSelected into startChar
   put word 4 of chunkSelected into endChar
   put the text of scriptField into someScript
   put line lineNum of someScript into someLine
end field_SetSelected

function hkey_GetSelected scriptField
   field_SetSelected scriptField, someScript, someLine, lineNum, someScript, startChar, endChar
   put hkey_FromSelected (someScript, endChar) into shortHkey
   return shortHkey
end hkey_GetSelected

function hkey_FromSelected someScript, endChar
   get char 1 to endChar of someScript
   put the number of tokens of it into tokenNum
   
   put token tokenNum of someScript into thisToken
   put token (tokenNum + 1) of someScript into nextToken
   put token (tokenNum - 1) of someScript into previousToken
   put token (tokenNum - 2) of someScript into setToken
   
   if nextToken is "(" then
      put "f" into handlerType
   else if previousToken = "the" then
      if setToken = "set" then
         put "s" into handlerType
      else
         put "g" into handlerType
      end if
   else
      -- what if it is a message?
      put "c" into handlerType
   end if
   
   -- needs to be short as handler could be anywhere in hierarchy
   return thisToken, handlerType
end hkey_FromSelected


--> Display | Controllers
-
on tree_MouseDoubleUp treeField 
   if the tree_IsLeaf of treeField is false then
      -- pass tree_MouseDoubleUp
      dispatch "tree_Expand" to treeField
   else
      put the tree_SelectedLink of treeField into hKey
      set the clipboarddata to hKey
      hkey_Edit hKey
   end if
end tree_MouseDoubleUp


--> Display
-
command display_ScriptKeywordLinks intersectArray
   -- display_Array intersectArray
   put _ConstructSortedOutlineSection ("and", intersectArray) after someOutline
   put _ConstructSortedOutlineSection ("handler keyword", intersectArray, true) after someOutline
   
   put "all keyword links" into someTitle
   put intersectArray [someTitle] into hKeys
   sort hKeys by item 1 of each
   put hkey_ConstructNameLinks (hKeys) into htmlLines
   put the number of lines of hKeys into someNum
   put someTitle && "(" & someNum & ")" into someTitle
   put someTitle & CR after someOutline
   put outline_IncreaseIndent (htmlLines, 1) & CR after someOutline 
   
   put "ordered keywords" into someTitle
   put someTitle & CR after someOutline
   put intersectArray [someTitle] into htmlLines
   put outline_IncreaseIndent (htmlLines, 1) & CR after someOutline 
   
   delete char -1 of someOutline
   
   put "Script Keyword Search" into displayTitle
   put empty into treeMenuTitle
   put empty into treeLineMenuTitle
   display_Outline someOutline, displayTitle, treeMenuTitle, treeLineMenuTitle, "and,2,handler keyword,ordered keywords"
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   put the long id of me into myController
   put hkey_Construct("tree_MouseDoubleUp", "c", myController) into hKey
   set the event_Trigger ["mouseDoubleUp"] of treeField to hKey
end display_ScriptKeywordLinks

private function _ConstructSortedOutlineSection someTitle, intersectArray, tidyHkeys
   put someTitle & CR after someOutline
   put intersectArray [someTitle] into titleArray
   
   repeat for each key nestedTitle in titleArray
      put titleArray [nestedTitle] into someNames
      put the number of lines of someNames into someNum
      put nestedTitle,someNum & CR after someTable
   end repeat
   delete char -1 of someTable
   -- sort someTable by item 1 of each
   sort numeric someTable by item 2 of each
   
   repeat for each line someLine in someTable
      put item 1 of someLine into nestedTitle
      put item 2 of someLine into someNum
      put titleArray [nestedTitle] into someNames
      sort someNames by item 1 of each
      
      put nestedTitle && "(" & someNum & ")" into nestedTitle
      if someNames is not empty then
         if tidyHkeys is true then put hkey_ConstructNameLinks (someNames) into someNames
         put tab & nestedTitle & CR after someOutline
         put outline_IncreaseIndent (someNames, 2) & CR after someOutline
      end if
   end repeat
   return someOutline
end _ConstructSortedOutlineSection


--> Dev | menu
-
/*
Several script menus want to edit the scripts of objects.
So put it here where they can all get it.

To do: could break this up into individual menu_Handlers,
so it can be used both as a submenu and inserted menu.
*/

on menu_AddAllHandlersToLibrary scriptObject, someBoolean
   library_ExportAllHandlersFromObject scriptObject, someBoolean
end menu_AddAllHandlersToLibrary

on menu_OpenHandlerLibraryFolder
   put library_HkeyFolder (empty, false) into hkeyFolder
   finder_Reveal hkeyFolder
end menu_OpenHandlerLibraryFolder

on menu_IndexAndExport scriptObject
   hArray_IndexAndStoreScriptAndAllHkeyCalls scriptObject, true
   put the result into newlyIdexedHkeyArray
      
   put "Indexed handlers of script, exported any new ones together with their short calls!" into someComment
   opn_Notify someComment
   if newlyIdexedHkeyArray is an array then
      display_Array newlyIdexedHkeyArray, "Newly indexed handlers"
   end if
end menu_IndexAndExport

on _
end _

on menu_StashScript scriptObject
   global gTemp_Stash
   
   put the script of scriptObject into someScript
   put the tempname & ".txt" into stashFile
   put someScript into url ("binfile:" & stashFile)
   
   put revRuggedID (scriptObject) into scriptObject
   put stashFile into gTemp_Stash ["scripts"][scriptObject]["stashFile"]
end menu_StashScript

on menu_RestoreStash scriptObject
   global gTemp_Stash
   
   put revRuggedID (scriptObject) into scriptObject
   put gTemp_Stash ["scripts"][scriptObject]["stashFile"] into stashFile
   put url ("binfile:" & stashFile) into someScript
   
   put someScript
   
   -- set the script of scriptObject to someScript
   -- edit the script of scriptObject
end menu_RestoreStash

on _
end _

on menu_FindFromKeywords
   put opn_Ask ("Input some handler names or keywords seperated by commas...", "path,array") into keywordList
   put hArray_KeywordHkeys (keywordList) into hKeys
   display_HkeyIndex hKeys
end menu_FindFromKeywords

on menu_DisplayScriptAnalysis scriptObject
   -- put the script_BreakdownArray of scriptObject into breakdownArray
   
   -- should make sure the object is indexed and stored.
   object_AddToGlobalArray scriptObject
   put revRuggedID (scriptObject) into rObject
   put hArray_GetObjectScriptArray (rObject) into scriptArray
   put script_ConstructBreakDownArray (scriptArray) into breakdownArray
   
   put breakdownArray ["uniqueKeys"] into uniqueKeys
   repeat for each line uniqueKey in uniqueKeys
      put hArray_ListHkeyObjects (uniqueKey) into otherObjects
      put item 1 to 2 of uniqueKey into shortKey
      put otherObjects into breakdownArray ["elsewhere"][shortKey]
   end repeat
   if breakdownArray ["duplicateArray"] is empty then delete variable breakdownArray ["duplicateArray"]
   delete variable breakdownArray ["scriptArray"]
   
   put "Script analysis for" && the name of scriptObject into someTitle
   display_Array breakdownArray, someTitle, "Global | Script | Duplicates | Menu", "Global | Script | Duplicates | Line | Menu"
   put the result into treeView
   
   put the object_Hkey ["display_DuplicateKey,c"] of me into hKey
   set the event_Trigger ["mouseDoubleUp"] of the tree_Field of treeView to hKey
end menu_DisplayScriptAnalysis

on menu_DuplicatesInScript scriptObject
   put the script_BreakdownArray of scriptObject into breakdownArray
   put breakdownArray ["uniqueKeys"] into uniqueKeys
   put breakdownArray ["duplicateArray"] into duplicateArray
   put breakdownArray ["scriptArray"] into scriptArray
   
   if duplicateArray is not an array then
      answer "No duplicates found!"
   else
      sort uniqueKeys
      display_Outline uniqueKeys, "Unique Hkeys"
      
      local depScript, missingHkeys
      script_FetchFromHkeys uniqueKeys, depScript, missingHkeys
      put script_ConstructSuite ("Deps", depScript) into depSuite
      
      display_Array duplicateArray, "Duplicate Handlers", "Global | Script | Duplicates | Menu", "Global | Script | Duplicates | Line | Menu"
      
      put "Dep suite for" && the mobile_Name of scriptObject into someTitle
      display_Text depSuite, someTitle
   end if
end menu_DuplicatesInScript


--> Global | Dev | Menu | Disabled
-
getprop disabled_RestoreStash [scriptObject]
   global gTemp_Stash
   
   put revRuggedID (scriptObject) into scriptObject
   put gTemp_Stash ["scripts"][scriptObject]["stashFile"] into stashFile
   if stashFile is empty then
      return true
   else
      return false
   end if
end disabled_RestoreStash


--> Deps
-
command display_DuplicateKey treeField
   if the tree_IsLeaf of treeField is true then
      put the selected_Index of treeField into hKey
      hkey_Edit hKey
   else
      pass display_DuplicateKey
   end if
end display_DuplicateKey

function menu_LibraryOutline
    local subMenu
    
    put "Used libraries" & CR after subMenu
    put library_ListUsedNames () into usedNames
    put outline_IncreaseIndent(usedNames, 1) & CR after subMenu
    
    put library_ListBackNames() into backNames
    if backNames is empty then
        put "(Backscript libraries" & CR after subMenu
    else
        put "Backscript libraries" & CR after subMenu
        put outline_IncreaseIndent(backNames) & CR after subMenu
    end if
     
    put library_ListFrontNames() into frontNames
    if frontNames is empty then
        put "(Frontscript libraries" & CR after subMenu
    else
        -- put the opn_FrontLibraries of the opn_Library of me into frontNames
        -- sort frontNames
        put "Frontscript libraries" & CR after subMenu
        put outline_IncreaseIndent(frontNames) & CR after subMenu
    end if
    put "-" & CR after subMenu
     
    put "In use" & CR after subMenu
    get the stacksinuse
    sort it
    put outline_IncreaseIndent(it) & CR after subMenu
    
    delete char -1 of subMenu
    return subMenu
end menu_LibraryOutline
