script "lib_Display"
--> MetaData
-
license: GPLv3
name: lib_Display
type: library
version: 0.4

/*
Here we gather handlers that display things.

Displaying stuff, that is taking data from a model, processing it (with a controller),
and then laying it out in a display (view) is not the job of a library,
but while creating libraries we often find the need to do some generic display code,
either for testing, or because it is useful.

We use this library to pull out any display code from other libraries into one place,
so that there is no view oriented code in the other libraries.

You can "view" this library as contaminated :)
*/


--> Display | Events
-
/*
These handlers handle events from display views that are created from the code in this library.
They do not have to be here, as you can change their location by setting the "event_Target" property of the display_View.
*/

command mouse_EditObjectScript treeView, scriptObject
   if the optionKey is "Down" then breakpoint
   
   edit the script of scriptObject
end mouse_EditObjectScript

command mDoubleUp_EditOldMenuScript targetObject, globalMenuCardName
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   edit the script of card globalMenuCardName of stack longStackFile
end mDoubleUp_EditOldMenuScript

on mDoubleUp_EditMenuScript arrayView, mControllerOrTable
   if exists (mControllerOrTable) is true then
      put mControllerOrTable into mController
      edit the script of mControllerOrTable
   else
      put mControllerOrTable
   end if
end mDoubleUp_EditMenuScript

on mDoubleUp_HkeyLine displayView, hKeyLine
   hkey_Edit hKeyLine
end mDoubleUp_HkeyLine


--> Working on
-
command display_Array someArray, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pMouseDoubleUpCommand, pCommandObject
   display_InvisibleArray someArray, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pMouseDoubleUpCommand, pCommandObject
   put the result into displayView 
   put token -1 of displayView into cloneStackName
   
   -- show and go
   show stack cloneStackName
   go to stack cloneStackName
   return displayView
end display_Array

command display_Lines someIndex, pSomeTitle, pMouseDoubleUpCommand, pStackLabel, pPalette
   -- simplified version of display_Index
   local pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pDragCommand
   
   put pSomeTitle into pDisplayTitle
   if pStackLabel is empty then put space into pStackLabel
   put comma & pStackLabel after pDisplayTitle
   
   display_Index someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put the result into indexView
   
   set the field_Style of indexView to "click"
   put script_CallingObject() into callingObject
   set the event_Target of indexView to callingObject
   return indexView
   
   -- after displaying you can...
   -- set the title_Menu of displayView to "Global | Test | Menu"
   -- set the line_Menu of displayView to "Global | Test | Line | Menu"
end display_Lines

command display_Index someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   -- replace comma with CR in someIndex
   put _GetLastIndexDisplayStackRect () into oRect
   --
   display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put the result into displayView 
   put token -1 of displayView into cloneStackName
   --
   put _GetNewIndexDisplayStackRect (oRect, displayView) into newRect
   set the rect of stack cloneStackName to newRect --- this is not working in latest dp
   revIDEEnsureOnscreen cloneStackName
   --
   show stack cloneStackName
   go to stack cloneStackName
   return displayView
end display_Index


--> Atom
-
command atom_DisplayText someText, pFileExtension, pUseBinary
   put the tempname into someFile
   if pFileExtension is not empty then
      put "." & pFileExtension after someFile
   end if
   if pUseBinary is true then
      put someText into url ("binfile:" & someFile)
   else
      put someText into url ("file:" & someFile)
   end if
   --
   atom_DisplayFile someFile
   put the result into launchSuccess
   return launchSuccess
end atom_DisplayText

command atom_DisplayFile someFile
   -- not sure why
   -- launch someFile with "Atom" does not work
   
   launch someFile with "/Applications/Atom.app" -- "Atom"
   put the result into launchSuccess
   return launchSuccess
end atom_DisplayFile


--> Display
-
command display_ActiveMenuArray
   global gLCW
   
   put gLCW ["activeMenuArray"] into activeMenuArray
   -- put "Recursion:" && pMenuTitle & ",menu_CheckRecursionOnExtract" into someTitle
   display_Array activeMenuArray, "gLCW ['activeMenuArray']"
end display_ActiveMenuArray

command display_Menus
   put menu_GetGlobalArray() into globalMenuArray
   put "mDoubleUp_EditMenuScript" into doubleCommand
   display_Array globalMenuArray, "menu_GetGlobalArray(),Global Menus", "Global | Menu | Global | Menu", empty, empty, doubleCommand
   
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   put the cardnames of stack longStackFile into globalMenuCardNames
   sort globalMenuCardNames
   
   put "" into titleMenu
   put "Global | Display | MenuIndex | Line | Menu" into lineMenu
   
   put "mDoubleUp_EditOldMenuScript" into doubleCommand
   put "" into dragCommand
   
   put "Old Global Menus,libOPN_Menus" into displayTitle
   display_Index globalMenuCardNames, displayTitle, titleMenu, lineMenu, empty, doubleCommand, dragCommand
   put the result into displayView
   set the multiple_Hilites of displayView to false
   
   go to stack longStackFile
end display_Menus

command display_RecentExports pHowLong, pIndexView
   -- we should also check which exports are different from the objects script using "script_IsDifferent"
   
   if pHowLong is empty then put 20 into pHowLong
   put word 1 of pHowLong into someMin
   put 60*someMin into someSec
   put spotlight_ListRecentlyExportedObjects (someSec) into rObjects
   
   if exists (pIndexView) is false then
      put merge ("In last [[someMin]] minutes,Changes") into someTitle
      put empty into mUp
      put "mouse_EditObjectScript" into mDoubeUp
      put "Global | Script | Changes | Menu" into lineMenuTitle
      display_Index rObjects, someTitle, "Global | Script | Changes | Menu", lineMenuTitle, mUp, mDoubeUp
      return the result
   else
      set the view_Index of pIndexView to rObjects
      return pIndexView
   end if
end display_RecentExports

command display_HkeyLines hkeyLines, someTitle
   local mTitle, mLineTitle, mUp
   display_Index hkeyLines, someTitle, mTitle, mLineTitle, mUp, "mDoubleUp_HkeyLine"
   put the result into indexView
   set the multiple_Hilites of indexView to false
end display_HkeyLines


--> Display
-
command display_Files filePaths, pFolderToStrip, pMouseDoubleUpHandler, pTitleMenu, pTitle
   put empty into pPathFilter
   put file_ConstructFolderArray (filePaths, pPathFilter, pFolderToStrip) into pathArray
   if pathArray is not an array then
      answer "I cannot find this handler anywhere!"
      exit to top
   end if

   put script_CallingObject() into pCommandObject
   display_Array pathArray, pTitle, pTitleMenu, empty, pMouseDoubleUpHandler, pMouseDoubleUpHandler, pCommandObject
   put the result into treeWidget
   set the search_Folder of treeWidget to pFolderToStrip
   return treeWidget
end display_Files

command display_ScriptTemplate templateName
   put scaffold_GetFile (templateName) into someFile
   display_TextFile someFile, templateName, "Global | Script | Template | Menu", "Script Template"
   put the result into textDisplayView
   return textDisplayView
end display_ScriptTemplate

command display_TextFile someFile, pDisplayTitle, pMenuTitle, pStackName
   local pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand

   if pMenuTitle is empty then put "Global | Display | File | Menu" into pMenuTitle
   put "file:" & someFile into someUrl
   put url someUrl into someText

   put pDisplayTitle,pStackName into displayTitle
   display_Index someText, displayTitle, pMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   put the result into displayView

   set the field_Style of displayView to "text"
   set the menu_Title of displayView to pMenuTitle
   set the displayed_File of displayView to someFile
   return displayView
end display_TextFile

command display_GlobalValue gName
   put global_GetValue (gName) into gValue
   if gValue is an array then
      put "Global:" && gName into someTitle
      display_Array gValue, someTitle, "Global | Pref | Menu"
   else
      put gValue
   end if
end display_GlobalValue

command display_Text textOrUrl, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   switch
      case pDisplayTitle is empty 
         put "Display,Text" into pDisplayTitle
      case textOrUrl begins with "file:///"
         -- this is how browsers display a file
         delete char 6 to 7 of textOrUrl
      case textOrUrl begins with "file:"
      case textOrUrl begins with "binfile:"
      case textOrUrl begins with "http:"
      case textOrUrl begins with "https:"
         put url textOrUrl into someText
         break
      case char 1 of textOrUrl = "/"
         -- assume it is a file path
         -- this is for lazy convenience (separate out to "display_File")
         put url ("file:" & textOrUrl) into someText
         break
      case pDisplayTitle is "atom" 
         put textOrUrl into someText
         atom_DisplayText someText
         return the result
      default
         put textOrUrl into someText
   end switch
   
   display_Index someText, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   put the result into indexView
   set the field_Style of indexView to "text"
   return indexView
end display_Text

command display_Json jsonReply, pDisplayTitle, pMouseDoubleUpCommand
   put json_ToArray (jsonReply) into jsonArray
   switch
      case pDisplayTitle is "atom"
         atom_DisplayText jsonReply, "json"
         return empty
      case jsonArray is an array
         local pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pCommandObject
         display_Array jsonArray, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pMouseDoubleUpCommand, pCommandObject
         break
      case dafs
         display_Lines jsonReply, pDisplayTitle
         break
   end switch
   put the result into displayView
   return displayView
end display_Json

command display_InvisibleArray someArray, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pMouseDoubleUpCommand, pCommandObject
   put "View|Tree|Widget with Title" into viewName
   
   -- new feature for specifying widget and stack label titles using a comma
   if pDisplayTitle is empty then put "Array" into pDisplayTitle
   put word 1 to -1 of item 1 of pDisplayTitle into widgetDisplayTitle
   put word 1 to -1 of item 2 of pDisplayTitle into displayStackLabel
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Array"
   put the result into cloneStackName
   
   -- set basic data
   put pTreeMenuTitle into menuArray ["title"]
   put pLineMenuTitle into menuArray ["line"]
   
   if pCommandObject is empty then
      put script_CallingObject (2) into pCommandObject
   end if
   put pInspectCommand into eventArray ["mouseUp"]
   put pMouseDoubleUpCommand into eventArray ["mouseDoubleUp"]
   put pCommandObject into eventArray ["eventTarget"]
   
   put _displayView (cloneStackName) into displayView
   set the displayed_Data of displayView to someArray
   set the view_MenuArray of displayView to menuArray
   set the view_EventArray of displayView to eventArray
   
   -- custom stuff
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to "random"
   put the result into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   
   set the style of stack cloneStackName to "palette"
   
   if line 1 of keys (someArray) is a number then
      set the tree_SortType of displayView to "numeric"
   end if
   
   -- set the display
   set the label of stack cloneStackName to displayStackLabel
   set the title_Text of displayView to widgetDisplayTitle
   
   return displayView
end display_InvisibleArray
   
command display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put "View|Index|Simple" into viewName
   
   -- new feature for specifying widget and stack label titles using a comma
   _setTitles widgetDisplayTitle, displayStackLabel, pDisplayTitle, "Index"
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Index"
   put the result into cloneStackName
   
   -- don't rely on this. It works only for handlers at the level of "display_Index"
   -- best practice is to "set the event_Target of indexView to script_CallingObject()" after you call the display handler you write
   put script_CallingObject (2) into eventArray ["eventTarget"]
   
   -- set basic data  
   put pMouseUpCommand into eventArray ["mouseUp"]
   put pMouseDoubleUpCommand into eventArray ["mouseDoubleUp"]
   put pDragCommand into eventArray ["dragCommand"]
   
   put pTreeMenuTitle into menuArray ["title"]
   put pLineMenuTitle into menuArray ["line"]
   
   put _displayView (cloneStackName) into displayView
   set the view_Index of displayView to someIndex
   set the view_MenuArray of displayView to menuArray
   set the view_EventArray of displayView to eventArray
   
   -- set the geometry
   -- revIdeEnsureOnscreen cloneStackName -- we use our own version?
   
   -- set the display
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to "random"
   put the result into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   
   if pPalette is true then set the style of stack cloneStackName to "palette"
   set the label of stack cloneStackName to displayStackLabel
   set the title_Text of displayView to widgetDisplayTitle
   set the multiple_Hilites of displayView to false -- the most common default
   
   return displayView
end display_InvisibleIndex


--> Deps
-
command stack_CloneInvisible stackNameToClone, pCloneName, pDestroyBoolean
   if exists (stack stackNameToClone) is false then return empty
   if pCloneName is empty then put stackNameToClone into pCloneName
   
   put stack_ConstructNewCloneName (pCloneName) into newStackName
   clone invisible stack stackNameToClone as newStackName
   put it into clonedStack
   if pDestroyBoolean is not false then
      set the destroyStack of clonedStack to true
      set the destroyWindow of clonedStack to true
   end if
   return newStackName -- used
end stack_CloneInvisible

command stack_Clone stackNameToClone, pDestroyBoolean, pCloneName
   if exists (stack stackNameToClone) is false then return empty
   if pCloneName is empty then put stackNameToClone into pCloneName
   
   stack_CloneInvisible stackNameToClone
   put the result into clonedStackName
   
   stack_SetToMainScreen clonedStackName
   set the visible of stack clonedStackName to true
   
   put the name of stack clonedStackName into clonedStack
   return clonedStack
end stack_Clone


--> Private
-
private function script_CallingObject pNum
   if pNum is empty then put 1 into pNum
   put (pNum + 2) * -1 into lineNum
   get the executioncontexts
   put item 1 of line lineNum of it into callingObject
   return callingObject
end script_CallingObject

private function display_ListIndexStackNames
   put the openstacks into indexStackNames
   filter indexStackNames with "Display Index *"
   sort indexStackNames by word -1 of each
   return indexStackNames
end display_ListIndexStackNames

private function _GetLastIndexDisplayStackRect
   -- put system_TopTarget() into topTarget
   -- put the stack_Name of topTarget into sourceStackName
   put line -1 of display_ListIndexStackNames() into sourceStackName
   if sourceStackName is empty then
      return empty
   else
      put the rect of stack sourceStackName into pRect
   end if
   return pRect   
end _GetLastIndexDisplayStackRect

private function _GetNewIndexDisplayStackRect oRect, displayView
   if oRect is not a rect then
      -- put 13,41,225,190 into pRect
      put 13 into oLeft
      put 41 into oBottom
   else
      put item 1 of oRect into oLeft
      put item 4 of oRect into oBottom
   end if
   
   put the formatted_Rect of displayView into fRect
   put item 3 of fRect into newWidth
   put item 4 of fRect into newHeight
   
   put the screen_Rect of displayView into displayScreenRect
   put item 4 of displayScreenRect into screenBottom
   put item 3 of displayScreenRect - item 1 of displayScreenRect - 60 into maxScreenWidth
   put screenBottom - item 2 of displayScreenRect - 60 into maxScreenHeight
   
   put min (newWidth, maxScreenWidth) into newWidth
   put min (newHeight, maxScreenHeight) into newHeight
   
   put 20 into tileBarHeight
   put oLeft into newLeft
   put tileBarHeight + oBottom into newTop
   put newLeft + newWidth into newRight
   put newTop + newHeight into newBottom
   
   -- if newBottom > screenBottom then -- here we could tile it across the screen
   
   return newLeft,newTop,newRight,newBottom
end _GetNewIndexDisplayStackRect
   
private function _displayView cloneStackName
   -- was "view_GetTemplateControl" and "view_GetTemplateObject"
   -- put view_GetTemplateControl (cloneStackName) into displayView
   if exists (control 1 of cd 1 of stack cloneStackName) is false then
      breakpoint
      return empty
   end if
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   return displayView
end _displayView

private command _setTitles @widgetDisplayTitle, @displayStackLabel, pDisplayTitle, pDefault
   if pDisplayTitle is empty then
      put pDefault into widgetDisplayTitle
      put empty into displayStackLabel
   else
      put word 1 to -1 of item 1 of pDisplayTitle into widgetDisplayTitle
      put word 1 to -1 of item 2 of pDisplayTitle into displayStackLabel
   end if
end _setTitles
