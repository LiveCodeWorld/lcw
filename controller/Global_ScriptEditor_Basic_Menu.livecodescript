script "Global_ScriptEditor_Basic_Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Basic | Menu
type: controller
version: 0.1


local LocalArray


--> Menu | Props
-
on menu_Init
   put rev_ListEditedStackNames() into editedStacks
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
   put rev_ScriptObject() into scriptObject
   return scriptObject
end menu_Target


--> Global | ScriptEditor | Custom | Menu
-
on menu_Test
   put rev_GetScriptEditorHistoryObjects()
end menu_Test


--> Global | ScriptEditor | Basic | Menu
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
   ide_SaveEditedStacks editedStackName
end menu_SaveEditedStacks

on _
end _

on insert_MyCustomMenu
   return "Global | ScriptEditor | Custom | Menu"
end insert_MyCustomMenu


--> Global | ScriptEditor | Basic | Menu | Props
-
getprop edited_StackNames
   put LocalArray ["editedStacks"] into editedStacks
   if editedStacks is empty then
      return empty
   else
      return editedStacks & ",-,Save All"
   end if
end edited_StackNames



--> Global | ScriptEditor | Basic | Menu | Disabled
-


--> Deps
-
function rev_ListEditedStackNames pType
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
end rev_ListEditedStackNames

getprop recent_Objects
   put rev_GetScriptEditorHistoryObjects() into historyObjects
   objects_MakeFriendly historyObjects, orderedFriendlyObjects, friendlyArray
   put friendlyArray into LocalArray ["friendlyArray"]
   return orderedFriendlyObjects
end recent_Objects

function rev_GetScriptEditorHistoryObjects pEditorNum
   put rev_HistoryButton (pEditorNum) into historyButton
   put value ("seHistoryGet()", historyButton) into someObjects
   return someObjects
end rev_GetScriptEditorHistoryObjects

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
