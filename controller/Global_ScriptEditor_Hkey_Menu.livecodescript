script "Global_ScriptEditor_Hkey_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Hkey_Menu
type: controller
version: 0.5


-->Variables
-
local LocalArray


--> Global | ScriptEditor | Hkey | Menu
-
on submenu_TestTransporter
   return "Global | revIgniter | Remote | Menu"
end submenu_TestTransporter

on insert_SendHkey
   return "Global | Hkey | Send | Menu"
end insert_SendHkey

on _
end _

on submenu_Handler
   return "Global | Handler | Menu"
end submenu_Handler

on submenu_History
   return "Global | Hkey | History | Menu"
end submenu_History

on submenu_Walk
   return "Global | Hkey | Walk | Menu"
end submenu_Walk

on _
end _

on menu_FindHandlerWithSpotlight hKey
   local handlerFolder -- just look in handler library folder
   -- put library_HandlerFolder() into handlerFolder
   
   put item 1 to 2 of hKey into shortFolder
   replace comma with "_" in shortFolder
   put spotlight_FindFile (shortFolder, handlerFolder) into handerFolderPaths
   
   put "Global | Hkey | Send | Menu" into titleMenu
   put merge ("Folders nameshKey '[[shortFolder]]'") into someTitle
   display_Files handerFolderPaths, handlerFolder, "launchFile", titleMenu, someTitle
   put the result into treeWidget
end menu_FindHandlerWithSpotlight

on _
end _

on menu_AddHandlerToLibrary hKey
   library_AddHkey hKey
   display_Hkey hKey, "project"
   put merge ("Added handler '[[item 1 to 2 of hKey]]' to the handler library!") into someComment
   opn_Notify someComment
end menu_AddHandlerToLibrary

on menu_ReplaceHandlerInLibrary hKey
   library_AddHkey hKey
   display_Hkey hKey, "project"
   put merge ("Added handler '[[item 1 to 2 of hKey]]' to the handler library!") into someComment
   opn_Notify someComment
end menu_ReplaceHandlerInLibrary

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Hkey | Menu | Props
-
-- getprop handler_IsIndexed [hKey]
-- complains some times?
put hkey_IsInLibrary (hKey) into isInLibrary
return isInLibrary
end handler_IsIndexed


--> Hkey | Menu | Disabled
-
getprop disabled_DisplayLibraryHandler [hKey]
   put hkey_IsExported (hKey) into isInLibrary
   if isInLibrary is true then
      return false
   else
      return true
   end if
end disabled_DisplayLibraryHandler

getprop disabled_AddHandlerToLibrary [hKey]
   -- want to be able to re-add it
   put hkey_IsInLibrary (hKey) into isInLibrary
   if isInLibrary is true then
      return "delete"
   else
      return false
   end if
end disabled_AddHandlerToLibrary

getprop disabled_DisplayLibraryHandler [hKey]
   -- want to be able to re-add it
   put hkey_IsInLibrary (hKey) into isInLibrary
   if isInLibrary is true then
      return false
   else
      return true
   end if
end disabled_DisplayLibraryHandler

getprop disabled_ReplaceHandlerInLibrary [hKey]
   -- want to be able to re-add it
   put hkey_IsInLibrary (hKey) into isInLibrary
   if isInLibrary is true then
      return false
   else
      return "delete"
   end if
end disabled_ReplaceHandlerInLibrary


--> Dev | Menu
-
on menu_FetchProjectHandler hKey
   put project_FetchHandler (hKey) into someHandler
   script_CreateAndEditHashCard someHandler
end menu_FetchProjectHandler

on menu_FetchLibraryCalls hKey
   set the cursor to watch
   put library_FetchHkeyCalls (hKey) into hkeyCalls
   put hkeyCalls
end menu_FetchLibraryCalls

-- on menu_FetchDeps hKey, fetchHow
   set the cursor to watch
   put hkey_FetchDeps (hKey, fetchHow) into hKeyDeps
   put hKeyDeps
end menu_FetchDeps

-- getprop fetch_Hows [hKey]
   -- put the object_Hkey ["hkey_RecurseCallArray,c"] of stack
   put hArray_FindHkey ("hkey_RecurseCallArray,c") into hKey
   put hkey_GetCaseConditions (hKey) into fetchHows
   return fetchHows
end fetch_Hows

on menu_FilteredLibraryDeps hKey
   local hKeyArray
   hkey_RecurseCallArray hKey, hkeyArray
   display_HKeyArray hKeyArray, hkey
end menu_FilteredLibraryDeps


--> Menu | Props
-
on menu_Init targetObject, mPath, mTitlePath
   put rev_GetHandlerTreeSelectedInfo() into hInfo
   put word 1 of hInfo into hType
   switch hType
      case "M"
         put "c" into hType
         break
      default
   end switch
   put word 2 of hInfo into hName
   put word 3 of hInfo into startLineNum
   put word 4 of hInfo into endLineNum
   put rev_ScriptObject() into hObject
   put hName,hType,hObject,1 into hKey
   
   put hKey into LocalArray ["hKey"]
   put hObject into LocalArray ["scriptObject"]
   put startLineNum into LocalArray ["startLineNum"]
   put endLineNum into LocalArray ["endLineNum"]
   put line startLineNum to endLineNum of the script of hObject into LocalArray ["someHandler"]
   
   put library_HandlerFile (hKey, empty, true) into LocalArray ["hkeyFolder"]
   
   put hArray_ListHkeyObjects (hKey) into otherObjects
   line_Delete hObject, otherObjects
   put word 1 to -1 of otherObjects into LocalArray ["other objects"]
end menu_Init

getprop menu_Target [mTitlePath]
   return LocalArray ["hKey"]
end menu_Target


--> Handlers
-
command launchFile treeWidget, shortPath
   put the search_Folder of treeWidget into findInsideFolder
   put the search_Text of treeWidget into textToFind
   
   text_AddTrailing findInsideFolder
   put findInsideFolder & shortPath into somePath
   set the itemdelimiter to "/"
   put item 1 of shortPath into shortHandlerFolder
   -- put hkey_FromShortFolder (shortHandlerFolder)
   put somePath
end launchFile


--> Deps | menu_Init
-
command line_Delete someLines, @fromContainer, partLine, skipLines
   set the wholematches to (partLine is empty)
   repeat with ii = 1 to the number of lines of someLines
      put line ii of someLines into someLine
      get lineoffset(someLine, fromContainer, skipLines)
      if it is not 0 then
         put it + skipLines into lineNum
         delete line lineNum of fromContainer
      end if 
   end repeat
   return the number of lines of someIndex
end line_Delete

function hArray_ListHkeyObjects hKey
   put item 1 to 2 of hKey into shortHkey
   put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   put keys (hkeyArray) into foundHkeys
   repeat for each line foundHkey in foundHkeys
      put item 3 of foundHkey & CR after foundObject
   end repeat
   return foundObject
end hArray_ListHkeyObjects

function hArray_GetFoundHkeyArray hKey, pHArray
   put item 1 to 2 of hKey into shortHkey
   if pHArray is an array then
      return pHArray ["handlerArray"][shortHkey]
   else
      global gHkey_Array
      return gHkey_Array ["handlerArray"][shortHkey]
   end if
end hArray_GetFoundHkeyArray

function library_HandlerFile hKey, pShortFileBit, pDontCreate
   -- returns empty if there is no folder, but the filename if there is
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   if there is not a folder hkeyFolder then return empty
   put pShortFileBit after hkeyFolder
   return hkeyFolder
end library_HandlerFile

function library_HkeyFolder hKey, pDontCreate
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   put hkey_FolderName (shortHkey) into folderName
   put library_HandlerFolder (folderName, pDontCreate) into hkeyFolder
   if folderName is not empty then put "/" after hkeyFolder
   
   if pDontCreate is false then folder_CreateNested hkeyFolder
   return hkeyFolder
end library_HkeyFolder

function library_HandlerFolder shortFileBit, pDontCreate
   return library_PluginFolder ("opn_Text/rev/handlers/", pDontCreate) & shortFileBit
end library_HandlerFolder

function library_PluginFolder pSubFolder, pDontCreate
   put revEnvironmentUserPluginsPath() & "/" into opnRootFolder
   put opnRootFolder & "opn_Plugins/" into someFolder
   
   if pSubFolder is not empty then
      folder_Format pSubFolder
      put pSubFolder after someFolder
   end if
   
   if pDontCreate is not true then folder_CreateNested someFolder
   return someFolder
end library_PluginFolder

command folder_CreateNested @someFolder
   folder_Format someFolder
   if there is a folder someFolder then return empty
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
end folder_CreateNested

command folder_Format @someFolder
   -- should be renamed "folder_Normalize"
   if someFolder is empty then return empty
   repeat while last char of someFolder is "/"
      delete last char of someFolder
   end repeat
   put "/" after someFolder
end folder_Format

function hkey_FolderName hKey
   put item 1 of hKey into hName
   put item 2 of hKey into hType
   if hType = "o" then put "c" into hType -- as "on" and "command" are functionally equivalent
   put hName & "_" & tolower (hType) into folderName
   return folderName
end hkey_FolderName

function library_HkeyToPublicShortHkey hKey
   -- change private handler to public one for library
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if char 1 of hType = "p" then delete char 1 of hType
   put hName,hType into shortHKey
   return shortHKey
end library_HkeyToPublicShortHkey

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   put word 1 to -1 of item 1 of hKey into hName
   put word 1 to -1 of item 2 of hKey into hType
   if hType is empty then put "c" into hType
   put word 1 to -1 of item 3 of hKey into hObject
   put item 4 of hKey into hNum
end hkey_Deconstruct

function rev_GetHandlerTreeSelectedInfo
   put rev_HandlerTreeField() into handlerField
   put the hilitedLine of handlerField into lineNum
   put line lineNum of the cHandlers of handlerField into tHandler
   return tHandler
end rev_GetHandlerTreeSelectedInfo

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return rev_TopScriptEditor()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
   end switch
end rev_ScriptEditorStack

function rev_TopScriptEditor
   put the stack_Name of the target into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else 
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      -- opn_Notify stackNames, true
      if stackNames is empty then return empty
      put line 1 of stackNames into stackName
      if exists(stack stackName) is false then
         put the stack_Name of the target into stackName
      end if
      return the long id of stack stackName
   end if
end rev_TopScriptEditor

function rev_ScriptObject
   put rev_TopScriptEditor() into stackObject
   if exists(stackObject) is false then return empty
   dispatch "revSEGetCurrentObject" to stackObject
   put the result into someObject
   return someObject
end rev_ScriptObject
