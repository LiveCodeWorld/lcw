script "model_Label"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Label
type: model
version: 0.3


--> Label | Module
-
function label_FromModuleName moduleName, pPathDelim, pAddColon
   if moduleName is empty then return empty
   --
   return label_FromPiped (moduleName, "Module", pAddColon, true, " ")
end label_FromModuleName

function label_ToModuleName moduleLabel, pReverse
   return label_ToViewName (moduleLabel, pReverse) -- same as view name
end label_ToModuleName

function label_ToViewName moduleLabel, pReverse
   if word 1 of moduleLabel is not Module then return empty
   --
   put label_ToPiped (moduleLabel, "View", pReverse) into viewName
   return viewName
end label_ToViewName


--> Label | Piped
-
function label_FromPiped pipedName, pFirstWord, pAddColon, pReverse, pDelim
   if pFirstWord is empty then
      set the itemdelimiter to "|"
      put word 1 to -1 of item 1 of pipedName into pFirstWord
   end if
   
   put label_ViewToCamelTitle (pipedName, pReverse, pDelim) into camelCaps
   if pAddColon is true then
      return pFirstWord & ":" && camelCaps
   else
      return pFirstWord && camelCaps   
   end if
end label_FromPiped

function label_ToPiped sLabel, pFirstItem, pReverse
   replace ":" with empty in sLabel
   if pFirstItem is empty then
      put word 1 of sLabel into pFirstItem
   end if
   put word 2 of sLabel into camelTitle
   put word_SplitCaps (camelTitle, "|") into pipedBit
   --
   if pReverse is false then
      return pFirstItem & "|" & pipedBit
   else
      put pFirstItem & "|" into rLabel
      put itemList_Reverse (pipedBit, "|") after rLabel
      return rLabel
   end if
end label_ToPiped

function label_ViewToCamelTitle pipedName, pReverse, pDelim
   set the itemdelimiter to "|"
   if item 1 of pipedName is among the items of "View|Layout" then
      delete item 1 of pipedName
   end if
   
   # Create camelCaps
   if pReverse is false then
      put label_CamelFromPiped (pipedName, pDelim) into camelCaps
   else
      put label_ReverseCamelFromPiped (pipedName, pDelim) into camelCaps
   end if
   return camelCaps
end label_ViewToCamelTitle

function label_CamelTitleToView camelTitle, pFirstItem
   if pFirstItem is empty then put "View" into pFirstItem
   
   put word_SplitCaps (camelTitle, "|") into viewName
   --
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then
      put pFirstItem & "|" before viewName
   end if
   return viewName
end label_CamelTitleToView

function label_ReverseCamelFromPiped pipedName, pDelim
   replace space with empty in pipedName -- hack
   
   set the itemdelimiter to "|"
   repeat with itemNum = the number of items of pipedName down to 1
      put word 1 to -1 of item itemNum of pipedName into sItem
      get toLower (sItem)
      put text_InitialCaps (it) into capsItem
      put capsItem & pDelim after camelCaps
   end repeat
   if pDelim is not empty then
      delete char -1 of camelCaps
   end if
   return camelCaps
end label_ReverseCamelFromPiped

function label_ReversePipedFromCamel camelWord
   put "|" into delimChar
   --
   put word_SplitCaps (camelWord, delimChar) into pipedItems
   put itemList_Reverse (pipedItems, delimChar) into reversedPiped
   return reversedPiped
end label_ReversePipedFromCamel


--> CamelCase
-
function camelCase_Word sText
   get word 1 to -1 of sText
   put text_InitialCaps (it) into camelWord
   replace space with empty in camelWord
   return camelWord
end camelCase_Word

function camelcase_BulletList hNameList
   local kWordArray
   replace comma with CR in hNameList
   --
   repeat for each line hName in hNameList
      put text_SplitIntoWords (hName) into kWords
      put toLower (kWords) into kWords
      split kWords with CR as set
      --
      union kWordArray with kWords 
   end repeat
   put keys (kWordArray) into tagItems
   --
   put markdown_TagItems (tagItems) into keyWordLinks
   -- replace CR with ", " in keyWordLinks
   return keyWordLinks
end camelcase_BulletList


--> Tiddly
-
getprop tiddly_Label
   put the stack_Name of the target into stackName
   put tiddly_StackNameToLabel (stackName) into tiddlyLabel
   return tiddlyLabel
end tiddly_Label

function tiddly_StackNameToLabel stackName
   set the itemdelimiter to "_"
   put item 1 of stackName into projectRoot
   put item 2 of stackName into shortProjectName
   
   # Duck Type
   set the itemdelimiter to "|"
   switch
      case word 1 to -1 of item 1 of stackName = "View"
         -- assume it is module
         return label_FromModuleName (stackName)
      case word 1 to -1 of item -1 of stackName = "Menu"
         -- assume it is menu
         return label_FromMenuTitle (stackName)
         break
      case stackName begins with "lcw_"
         -- original LCW Project
         return label_FromProjectName (stackName)
      case stackName contains "_"
         -- assume some other project
         -- breakpoint
         return text_InitialCaps (projectRoot) & ":" && shortProjectName 
      default
         -- breakpoint
         return stackName
   end switch
end tiddly_StackNameToLabel

function tiddly_ReadmeLabelFromUrl tiddlyUrl
   set the itemdelimiter to slash
   -- put item 3 to -1 of tiddlyUrl into tiddlyPath
   -- put env_GetRepoFolder() into repoFolder
   -- put file_GetRelativePath (tiddlyPath, repoFolder, commonPath) into relPath
   switch item -3 of tiddlyUrl
      case "modules"
         put item -2 of tiddlyUrl into moduleName
         replace "_" with "|" in moduleName
         put label_FromModuleName (moduleName) into cloneName
         put space & "Readme" after cloneName
         break
      case "LivecodeWorld"
         put item -2 of tiddlyUrl into projectName
         put label_FromProjectName (projectName) into cloneName
         put space & "Readme" after cloneName
         break
      default
         put "README" into cloneName
   end switch
   return cloneName
end tiddly_ReadmeLabelFromUrl

function tiddly_LabelToStackName tiddlyLabel
   switch word 1 of tiddlyLabel
      case "Menu"
         put label_ToMenuTitle (tiddlyLabel) into stackName
         break
      case "Module"
         put label_ToViewName (tiddlyLabel) into stackName
         break
      case "Project"
         put label_ToProjectName (tiddlyLabel) into stackName
         break
      default
   end switch
   return stackName
end tiddly_LabelToStackName


--> Props
-
getprop module_Label [pAddColon]
   put the module_Name of the target into moduleName
   return label_FromModuleName (moduleName, pAddColon)
end module_Label

getprop project_Label [pAddColon]
   put the project_Name of the target into projectName
   --
   put label_FromProjectName (projectName) into projectLabel
   return projectLabel
end project_Label

getprop project_MenuTitle
   put the project_Name of the target into pName
   if pName is empty then return empty
   put default_ConstructMenuTitle (pName) into mTitle 
   return mTitle
end project_MenuTitle

getprop view_Label [pAddColon]
   put the view_Name of the target into viewName
   if viewName is empty then return empty
   --
   return label_FromPiped (viewName, "View", pAddColon)
end view_Label

getprop view_GlobalMenuTitle
   put the view_Name of the target into viewName
   put default_ConstructMenuTitle (viewName) into globalMenuTitle
   return globalMenuTitle
end view_GlobalMenuTitle

getprop view_Name
   put the long id of the target into tObject   
   if the uRIP ["type"] of tObject is not "view" then return empty
   put the uRIP ["name"] of tObject into viewName
   return viewName
end view_Name


--> Label
-
function label_BehaviorName mName
   return "behavior_" & label_CamelFromPiped (mName)
end label_BehaviorName

function label_UnderscoreToPipes shortFolder, pPretty
   if pPretty is true then
      replace "_" with " | " in shortFolder
   else
      replace "_" with "|" in shortFolder
   end if
   return shortFolder
end label_UnderscoreToPipes

function label_PipesToUnderscore moduleName
   set the itemdelimiter to "|"
   repeat for each item someItem in moduleName
      put word 1 to -1 of someItem & "_" after shortFolder
   end repeat
   delete char -1 of shortFolder
   return shortFolder
end label_PipesToUnderscore

function label_CamelFromPiped pipedName
   replace space with empty in pipedName -- hack
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of pipedName
      put word 1 to -1 of item itemNum of pipedName into sItem
      get toLower (sItem)
      put text_InitialCaps (it) into capsItem
      put capsItem after camelCaps
   end repeat
   return camelCaps
end label_CamelFromPiped


--> Label | mTitle
-
function label_ToMenuTitle mLabel
   -- Tiddlywiki Plugins Menu
   if word -1 of mLabel is not "Menu" then return empty
   delete word -1 of mLabel
   
   put "Global | " into mTitle
   repeat for each word mBit in mLabel
      put mBit && "| " after mTitle
   end repeat
   put "Menu" after mTitle
   return mTitle
end label_ToMenuTitle

function label_ToMenuTitle tiddlyLabel
   if word 1 of tiddlyLabel is not "Menu" then return empty
   if the number of words of tiddlyLabel is not 2 then return empty
   
   put word 2 of tiddlyLabel into camelWord
   put word_SplitCaps (camelWord, "|") into pipedItems
   put "Global|" & pipedItems & "|Menu" into mTitle
   replace "|" with " | " in mTitle
   return mTitle
end label_ToMenuTitle

function label_FromMenuTitle mTitle, pPathDelim, pAddColon
   set the itemdelimiter to "|"
   --
   get word 1 to -1 of item -1 of mTitle
   if it is not "Menu" then
      return empty
   end if
   
   # Label start
   put "Menu" into mLabel
   if pAddColon is true then put ":" after mLabel
   put space after mLabel
   
   # Delete Menu
   delete item -1 of mTitle
   
   # Delete Global
   get word 1 to 1 of item 1 of mTitle
   if it = "Global" then delete item 1 of mTitle
   
   # Make CapsWord
   replace space with empty in pipedItem 
   repeat for each item pipedItem in mTitle
      get word 1 to -1 of pipedItem
      put text_InitialCaps (it) into capsWord
      put capsWord after mLabel
      put pPathDelim after mLabel
   end repeat
   
   if pPathDelim is not empty then
      put -1 * the number of chars of pPathDelim into dNum
      delete char dNum to -1 of mLabel
   end if
   return mLabel
end label_FromMenuTitle

function label_ShortModuleFolderFromName moduleName
   view_NormalizePiped moduleName
   put moduleName into shortModuleFolder
   replace "|" with "_" in shortModuleFolder
   return shortModuleFolder
end label_ShortModuleFolderFromName

function label_FromProjectName projectName
   if projectName is empty then return empty
   --
   set the itemdelimiter to "_"
   put item 1 of projectName into projectRoot
   put item 2 of projectName into shortProjectName
   --
   if projectRoot = "lcw" then
      -- original LCW Project
      return "Project" && shortProjectName
   else
      breakpoint
      return "Project" && projectName
   end if
end label_FromProjectName

function label_ToProjectName tiddlyLabel
   if word 1 of tiddlyLabel is not "Project" then return empty
   if the number of words of tiddlyLabel is not 2 then return empty
   
   -- LCW Project
   return "lcw_" & word -1 of tiddlyLabel
end label_ToProjectName


--> View | Names | Old
-
function view_FromModuleStackName moduleStackName
   replace "_" with "|" in moduleStackName
   return moduleStackName
end view_FromModuleStackName

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then put "View|" before viewPath
   return true
end view_NormalizeName

command view_NormalizePiped @viewPath, pMakePretty
   if viewPath is empty then return false
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      if pMakePretty is true then
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someItem
      end if
      put someItem into item itemNum of viewPath
   end repeat
   return true
end view_NormalizePiped


--> Deps
-
function itemList_Reverse itemList, pDelimChar
   if pDelimChar is empty then put comma into pDelimChar
   set the itemdelimiter to pDelimChar
   repeat with itemNum = the number of items of itemList down to 1
      get item itemNum of itemList 
      put it & pDelimChar after reversedItems
   end repeat
   delete char -1 of reversedItems
   return reversedItems
end itemList_Reverse
