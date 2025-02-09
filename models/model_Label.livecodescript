script "model_Label"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Label
type: model
version: 0.1


--> Working on
-
getprop tiddly_Label
   put the stack_Name of the target into stackName
   put tiddly_StackNameToLabel (stackName) into tiddlyLabel
   return tiddlyLabel
end tiddly_Label

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
         breakpoint
         return text_InitialCaps (projectRoot) & ":" && shortProjectName 
      default
         breakpoint
         return stackName
   end switch
end tiddly_StackNameToLabel


--> Menu | Names
-
getprop project_Menu
   put the project_Name of the target into pName
   if pName is empty then return empty
   put module_ConstructGlobalMenuTitle (pName, true) into mTitle 
   return mTitle
end project_Menu

getprop module_Menu
   put the module_Name of the target into mName
   -- put the short name of the defaultstack into mName
   if mName is empty then return empty
   put module_ConstructGlobalMenuTitle (mName, true) into mTitle 
   return mTitle
end module_Menu


--> View | Names
-
getprop view_Label [pAddColon]
   put the view_Name of the target into viewName
   if viewName is empty then return empty
   --
   return label_FromPiped (viewName, "View", pAddColon)
end view_Label

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

getprop view_GlobalMenuTitle
   put the view_Name of the target into viewName
   put menu_GlobalTitleFromViewName (viewName) into globalMenuTitle
   return globalMenuTitle
end view_GlobalMenuTitle


--> Label
-
function label_ViewToCamelTitle pipedName, pReverse
   set the itemdelimiter to "|"
   if item 1 of pipedName is among the items of "View|Layout" then
      delete item 1 of pipedName
   end if
   
   # Create camelCaps
   if pReverse is false then
      put label_CamelFromPiped (pipedName) into camelCaps
   else
      put label_ReverseCamelFromPiped (pipedName) into camelCaps
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

function label_FromModuleName moduleName, pPathDelim, pAddColon
   if moduleName is empty then return empty
   --
   return label_FromPiped (moduleName, "Module", pAddColon)
end label_FromModuleName

function label_ToModuleName moduleLabel, pReverse
   -- naming of modules makes no sense?
   return label_ToViewName(moduleLabel, pReverse) -- same as view name
end label_ToModuleName

function label_ToViewName moduleLabel, pReverse
   if word 1 of moduleLabel is not Module then return empty
   --
   put label_ToPiped (moduleLabel, "View", pReverse) into viewName
   return viewName
end label_ToViewName


--> Label | Piped
-
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

function label_FromPiped pipedName, pFirstWord, pAddColon, pReverse
   if pFirstWord is empty then
      set the itemdelimiter to "|"
      put word 1 to -1 of item 1 of pipedName into pFirstWord
   end if
   
   put label_ViewToCamelTitle (pipedName, pFirstWord, pAddColon, pReverse) into camelCaps
   if pAddColon is true then
      return pFirstWord & ":" && camelCaps
   else
      return pFirstWord && camelCaps   
   end if
end label_FromPiped

function label_ReverseCamelFromPiped pipedName
   replace space with empty in pipedName -- hack
   
   set the itemdelimiter to "|"
   repeat with itemNum = the number of items of pipedName down to 1
      put word 1 to -1 of item itemNum of pipedName into sItem
      get toLower (sItem)
      put text_InitialCaps (it) into capsItem
      put capsItem after camelCaps
   end repeat
   return camelCaps
end label_ReverseCamelFromPiped

function label_ReversePipedFromCamel camelWord
   put "|" into delimChar
   --
   put word_SplitCaps (camelWord, delimChar) into pipedItems
   put itemList_Reverse (pipedItems, delimChar) into reversedPiped
   return reversedPiped
end label_ReversePipedFromCamel

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
