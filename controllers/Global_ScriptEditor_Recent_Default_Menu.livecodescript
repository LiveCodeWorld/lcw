script "Global_ScriptEditor_Recent_Default_Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Recent | Default | Menu
type: controller
version: 0.6


local LocalArray


--> Menu | Props
-
on menu_Init
   put stack_ListEditedNames() into editedStacks
   repeat for each line stackName in editedStacks
      switch
         case exists (stack stackName) is false
         case word 1 of stackName = "Untitled"
            next repeat
         default
            put stackName & CR after goodEditedStackNames
      end switch
   end repeat
   delete char -1 of goodEditedStackNames
   put goodEditedStackNames into LocalArray ["editedStacks"]
end menu_Init

getprop menu_Target [mTitlePath]
   put scriptEditor_Object() into scriptObject
   return scriptObject
end menu_Target


--> Global | ScriptEditor | Recent | Default | Menu
-
on menu_RecentScripts scriptObject, recentObject
   put LocalArray ["friendlyArray"][recentObject] into someObject
   if exists (someObject) then
      edit the script of someObject
   else
      breakpoint
   end if
end menu_RecentScripts

on menu_SaveEditedStacks mTarget, editedStackName
   stack_SaveEdited editedStackName
end menu_SaveEditedStacks

on _
end _

on insert_MyCustomMenu
   return "Global | ScriptEditor | Recent | Custom | Menu"
end insert_MyCustomMenu

on _
end _

on menu_CheckAvailableMenus
   put url "https://gist.github.com/opn/1aee32a3796af1d1dc85ec5ad1566f5f/raw/d8e15f2e2a0797c2fc8e9e6535535b0b4f44ec35/index,Recent%2520Changes%2520Menus" into recentMenuList
   -- display_Lines recentMenuList
   
   put recentMenuList into recentMenuArray
   split recentMenuArray with CR and comma
   
   put recentMenuList into columnArray
   set the columndel to comma
   split columnArray by column
   put columnArray [1] into mNames
   put columnArray [1] into mURLs
   
   display_Array recentMenuArray
end menu_CheckAvailableMenus

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "Recent", mTitle
end menu_SetMenu


--> Global | ScriptEditor | Recent | Default | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("Recent")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end m_Titles

getprop edited_StackNames
   put LocalArray ["editedStacks"] into editedStacks
   if editedStacks is empty then
      return empty
   else
      return editedStacks & ",-,Save All"
   end if
end edited_StackNames


--> Global | ScriptEditor | Recent | Default | Menu | Disabled
-
getprop disabled_SaveEditedStacks
   put LocalArray ["editedStacks"] into editedStacks
   if editedStacks is empty then
      return "delete"
   else
      return false
   end if
end disabled_SaveEditedStacks


--> Deps
-
function stack_ListEditedNames pType
   global gREVStackStatus
   
   repeat for each key stackName in gREVStackStatus
      if exists (stack stackName) is false then next repeat
      switch pType
         case "saved"
            if gREVStackStatus [stackName] = empty then
               put "saved" into stackArray [stackName]
            end if
            break
         default
            if gREVStackStatus [stackName] = "edited" then
               put "edited" into stackArray [stackName]
            end if
      end switch
   end repeat
   return keys (stackArray)
end stack_ListEditedNames

getprop recent_Objects
   put scriptEditor_ListEditingObjects() into historyObjects
   objects_MakeFriendly historyObjects, orderedFriendlyObjects, friendlyArray
   put friendlyArray into LocalArray ["friendlyArray"]
   return orderedFriendlyObjects
end recent_Objects

function scriptEditor_ListEditingObjects pEditorNum
   put rev_HistoryButton (pEditorNum) into historyButton
   put value ("seHistoryGet()", historyButton) into someObjects
   return someObjects
end scriptEditor_ListEditingObjects

function rev_HistoryButton pEditorNum
   put rev_TopScriptEditor() into editorStack
   if exists (btn "history" of group "Script Tabs" of cd "Main" of editorStack) is false then return empty
   put the long id of btn "history" of group "Script Tabs" of cd "Main" of editorStack into someObject
   return someObject
end rev_HistoryButton

function rev_TopScriptEditor
   put the openstacks into stackNames
   filter stackNames with "revNewScriptEditor*"
   if stackNames is empty then return empty
   put line 1 of stackNames into stackName
   if exists (stack stackName) is false then return empty
   return the long id of stack stackName
end rev_TopScriptEditor

command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   repeat for each line someObject in someObjects
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly scriptObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of scriptObject & space into tFriendlyName
   
   if the name of scriptObject is the short name of scriptObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of scriptObject after tFriendlyName
   else
      put quote & the short name of scriptObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly
