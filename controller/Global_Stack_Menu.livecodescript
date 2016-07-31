script "Global_Stack_Menu"
--> MetaData
-
license: GPLv3
name: Global_Stack_Menu
type: controller
version: 0.3

local LocalArray

/*
Some basic tools for manipulating stacks, and windows. 
*/


--> Currently working On
-


--> Global | Stack | Menu
-
on menu_SnapCard scriptObject
   put the card_Object of scriptObject into cardObject
   if exists (cardObject) is false then
      answer warning "No card for this script object!"
      exit to top
   end if
   
   wireframe_SnapAndExport cardObject, false
   put the result into imageFile
   display_Image imageFile
   -- set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
   finder_Reveal imageFile
end menu_SnapCard

on menu_SnapStack scriptObject
   put the stack_Object of scriptObject into stackObject
   put the wireframe_StackSnap of stackObject into somePNG
   
   put somePNG into image 1 of cd 1 of stack "Test Wireframe Image"
   
   put the short name of stackObject into stackName
   replace quote with empty in stackName
   replace space with "-" in stackName
   put "stack_" & stackName & ".png" into shortFile
   
   localhost_SavePng somePNG, shortFile
   put the result into imageFile
   finder_Reveal imageFile
end menu_SnapStack

on menu_SnapImage scriptObject
   wireframe_SnapAndExport scriptObject, true
   put the result into imageFile
   set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
   finder_Reveal imageFile
end menu_SnapImage

on _
end _

on menu_SaveStack scriptObject
   put the stack_Object of scriptObject into stackObject
   save stackObject
   opn_Notify "Saved" && stackObject
end menu_SaveStack

on menu_RevertStack scriptObject
   put the stack_Object of scriptObject into stackObject
   put the effective filename of stackObject into someFile
   put git_GetLastRevision (someFile, 0)
end menu_RevertStack

on _
end _

on menu_PlaceOnMainScreen mTarget, someName
   switch someName
      case "LiveCode Dictionary"
         stack_SetToMainScreen "revDictionary"
         go to stack "revDictionary"
         break
      case "Script Editors"
         put the openstacks into stackNames
         filter stackNames with "revNewScriptEditor *"
         repeat for each line stackName in stackNames
            stack_SetToMainScreen stackName
         end repeat
         break
      case "All open stacks"
         stack_SetToMainScreen
         break
      default
         stack_SetToMainScreen someName
   end switch
end menu_PlaceOnMainScreen

on _
end _

on menu_RevealStack mTarget
   put the stack_Name of mTarget into stackName
   stack_RevealInFinder stackName
end menu_RevealStack

on menu_RenameStack mTarget
   put the stack_Object of mTarget into stackObject
   put the short name of stackObject into oldName
   
   stack_Rename oldName
   -- save stackObject
   -- opn_Notify "Saved" && stackObject
end menu_RenameStack

on menu_FixStackBehaviors mTarget
   local searchArray
   put the stack_Name of mTarget into stackName
   search_Stack stackName, "behavior", searchArray
   put keys(searchArray) into foundBehaviors
   repeat for each line foundBehavior in foundBehaviors
      put searchArray [foundBehavior] into objectsWithBehavior
      repeat for each line someObject in objectsWithBehavior
         set the cursor to busy
         if exists(someObject) is false then
            -- should not be possible
            breakpoint
            put searchArray [foundBehavior] into displayArray ["impossible error"][foundBehavior]
            next repeat
         end if
         
         if exists (foundBehavior) is false then
            -- probably not in stackfiles
            put searchArray [foundBehavior] into displayArray ["behavior does not exist"][foundBehavior]
            next repeat
         end if
         
         set the behavior of someObject to foundBehavior
         put searchArray [foundBehavior] into displayArray ["good behavior"][foundBehavior]
      end repeat
   end repeat
   
   display_Array displayArray, ("Behaviors of stack" && kwote(stackName))
end menu_FixStackBehaviors

on _
end _

on menu_StackStyle scriptObject, stackStyle
   put the stack_Object of scriptObject into stackObject
   set the style of stackObject to stackStyle
end menu_StackStyle

on menu_StackResizable scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
   set the resizable of stackObject to someBoolean
end menu_StackResizable

on menu_StackTitleStyle scriptObject, stackTitleStyle
   put the stack_Object of scriptObject into stackObject
   set the stack_TitleStyle of stackObject to stackTitleStyle
end menu_StackTitleStyle

on _
end _

on menu_GoToStack scriptObject
   put the stack_Object of scriptObject into stackObject
   go to stackObject
   if the result is not empty then beep
end menu_GoToStack

on menu_AlreadyKnown scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
   set the stack_IsKnown of stackObject to someBoolean
end menu_AlreadyKnown

on _
end _

on menu_RevealStack scriptObject
   put the stack_Object of scriptObject into stackObject
   put the filename of stackObject into someFile
   if there is a file someFile then
      finder_Reveal someFile
   else
      beep
   end if
end menu_RevealStack

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Stack | Menu | Props
-
getprop record_Card
   return LocalArray ["isRecoring"] is true
end record_Card

getprop stack_Resizable [scriptObject]
   put the stack_Object of scriptObject into stackObject
   put the resizable of stackObject into someBoolean
   return someBoolean
end stack_Resizable

getprop some_Name [mTarget]
   put the stack_Name of mTarget into someName
   return someName
end some_Name

getprop some_Names [mTarget]
   put the openstacks into stackNames
   -- filter stackNames without "rev*"
   sort stackNames
   return stackNames
   
   return someNames & ",-," & "LiveCode Dictionary,All open stacks"
end some_Names

getprop stack_Style [mTarget]
   if exists(mTarget) is false then return empty
   put the stack_Object of mTarget into stackObject
   return the style of stackObject
end stack_Style

getprop stack_Styles
   return "topLevel,modeless,modal,palette"
end stack_Styles

getprop already_Known [stackObject]
   if exists(stackObject) is false then return empty
   return the stack_IsKnown of stackObject
end already_Known


--> Global | Stack | Menu | Disabled
-
getprop disabled_SpotlightFileInfo [stackObject]
   return the platform is not "MacOS"
end disabled_SpotlightFileInfo


--> Dev | Menu
-
on menu_RecordCard scriptObject, someBoolean
   put scriptObject into LocalArray ["scriptObject"]
   put someBoolean into LocalArray ["isRecoring"]
   export_SnapShot
end menu_RecordCard

on menu_SpotlightFileInfo scriptObject
   put the stack_Object of scriptObject into stackObject
    put the filename of stackObject into someFile
    put spotlight_GetFileInfo (someFile) into stackInfo
    display_Lines stackInfo, "Spotlight file info for" && stackObject
end menu_SpotlightFileInfo

on _
end _

on menu_GitRename scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
   put the short name of stackObject into oldName
   
   set the itemdelimiter to "/"
   put the filename of stack oldName into oldFile
   put item -1 of oldFile into oldShortFile
  
   put oldFile into newFile
   put oldName & ".rev" into newShortFile
   
   put merge("What do you want to rename this stack '[[oldShortFile]]' to?") into someQuestion
   put opn_Ask (someQuestion, newShortFile) into newShortFile
   put newShortFile into item -1 of newFile
    
   git_RenameFile oldFile, newFile
   -- rename file fromFile to toFile
   return newFile
end menu_GitRename

on menu_DeleteFile scriptObject
   put the stack_Object of scriptObject into stackObject
   stack_DeleteFile stackObject
end menu_DeleteFile     


--> Menu | Props
-

--> Deps
-
command export_SnapShot
   put LocalArray ["scriptObject"] into scriptObject
   put LocalArray ["isRecoring"] into isRecoring
   
   if isRecoring is true then
      -- wireframe_SnapAndExport scriptObject, false - card changes we still record the card
      put the wireframe_StackSnap of scriptObject into somePNG
      
      set the text of image 1 of cd 1 of stack "Test Wireframe Image" to somePNG
      /*
      put the result into imageFile
      set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
      put filename
      */
      
      send "export_SnapShot" to me in 2 seconds
   end if
end export_SnapShot
