script "lib_Display"
--> MetaData
-
license: GPLv3
name: lib_Display
type: library
version: 0.3

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


--> Working On
-
command display_Array someArray, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pCommandObject
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
      put script_CallingObject() into pCommandObject
   end if
   put pMouseUpCommand into eventArray ["mouseUp"]
   put pMouseDoubleUpCommand into eventArray ["mouseDoubleUp"]
   put pCommandObject into eventArray ["eventTarget"]
   
   view_SetCloneData cloneStackName, someArray, menuArray, eventArray
   put the result into displayView
   
   -- custom stuff
   set the title_Colour of displayView to "random"
   set the style of stack cloneStackName to "palette"
   
   if line 1 of keys (someArray) is a number then
      set the tree_SortType of displayView to "numeric"
   end if
   
   -- show and go
   view_CloneShow cloneStackName, widgetDisplayTitle, displayStackLabel
   
   return displayView
end display_Array

command display_ProjectStacks
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   
   put project_GetCurrentName() into projectName
   put projectName & ",Project" into displayTitle
   display_Index stackNames, displayTitle, "Global | Project | Menu", "Global | Project | Line | Menu", empty, "project_GoToStack"
   put the result into displayView
   set the multiple_Hilites of displayView to false
   return displayView
end display_ProjectStacks

command display_LoadedStacks
   put revLoadedStacks ("application") into stackNames
   sort stackNames
   display_Index stackNames, "Project", "Global | Project | Menu", "Global | Project | Line | Menu", empty, "project_GoToStack"
   put the result into displayView
   
   put project_FetchValue ("openStacks") into stackNames
   set the multiple_Hilites of displayView to true
   set the selected_Index of displayView to stackNames
end display_LoadedStacks

command display_Menus
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   put the cardnames of stack longStackFile into globalMenuCardNames
   sort globalMenuCardNames
   
   put "" into titleMenu
   put "" into lineMenu
   
   put "opnMenus_EditScript" into upCommand
   put "" into doubleCommand
   put "" into dragCommand
   
   put "Old Global Menus,libOPN_Menus" into displayTitle
   display_Index globalMenuCardNames, displayTitle, titleMenu, lineMenu, upCommand, doubleCommand, dragCommand
   put the result into displayView
   set the multiple_Hilites of displayView to false
end display_Menus

command display_Behaviors
   put behavior_ListNames() into bNames
   put hArray_ListViewBehaviorNames() into vbNames
   put vbNames & CR & "-" & CR & bNames into bIndex
   
   put "doDrag" into dragCommand
   put empty into upCommand
   put empty into doubleUpCommand
   
   put "Global | Behavior | Display | Menu" into titleMenu
   put "Global | Behavior | Display | Line | Menu" into lineMenu
   
   display_Index bIndex, "Behaviors", titleMenu, lineMenu, upCommand, doubleUpCommand, dragCommand
   put the result into displayView
   set the multiple_Hilites of displayView to false
end display_Behaviors


--> Display | Lines
-
command display_ScriptTemplate templateName
   put library_ScriptTemplateFolder (templateName) into someFile   
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

command display_Lines someIndex, pDisplayTitle, pMenuTitle, pStackName
   -- just here for compatability
   -- may want to switch to display_Text
   local pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   
   put pDisplayTitle,pStackName into displayTitle
   display_Index someIndex, displayTitle, pMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
end display_Lines

command display_Index someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   put "View|Index|Simple" into viewName
   -- replace comma with CR in someIndex
   
   -- new feature for specifying widget and stack label titles using a comma
   _setTitles widgetDisplayTitle, displayStackLabel, pDisplayTitle, "Index"
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Index"
   put the result into cloneStackName
   
   -- set basic data  
   put script_CallingObject() into eventArray ["eventTarget"]
   put pMouseUpCommand into eventArray ["mouseUp"]
   put pMouseDoubleUpCommand into eventArray ["mouseDoubleUp"]
   put pDragCommand into eventArray ["dragCommand"]
   
   put pTreeMenuTitle into menuArray ["title"]
   put pLineMenuTitle into menuArray ["line"]
   
   view_SetCloneData cloneStackName, someIndex, menuArray, eventArray
   put the result into displayView
   
   -- custom stuff
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to "random"
   set the style of stack cloneStackName to "palette"
   
   -- show and go
   view_CloneShow cloneStackName, widgetDisplayTitle, displayStackLabel
   
   return displayView
end display_Index


--> Display | Text
-
command display_Text someText, pDisplayTitle, pMenuTitle, pStackName, pMinWidth, pTextType, pStackStyle, pCardMargin, pStackRect
   -- component:  View|Display|Text|Basic
   -- ignoreCall:  view_TextWrap,s
   -- ignoreCall:  menu_Title,s
   -- ignoreCall:  body_TextFont,s
   if pStackStyle is empty then put "palette" into pStackStyle
   view_CloneStack "View|Display|Text|Basic", pCardMargin, pStackRect, pStackStyle, true
   put the result into displayView
   put the stack_Name of displayView into stackName
   
   display_SetText someText, pDisplayTitle, pTextType, displayView
   set the label of stack stackName to pDisplayTitle
   setDisplayStackRect displayView, stackName
   if pMenuTitle is not empty then set the menu_Title of displayView to pMenuTitle
   if pTextFont is not empty then set the body_TextFont of displayView to pTextFont
   set the view_TextWrap of displayView to true
   show stack stackName
   return displayView
end display_Text

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

command display_HTML someHTML, pDisplayTitle, pMenuTitle
   put "View|Display|Text|Basic" into viewName
   _setTitles widgetDisplayTitle, displayStackLabel, pDisplayTitle, "HTML"
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display HTML"
   put the result into cloneStackName
   set the destroyStack of stack cloneStackName to true
   set the destroyWindow of stack cloneStackName to true
   
   -- set basic data  
   put _displayView (cloneStackName) into displayView
   -- set the view_HtmlText of displayView to someHTML
   set the view_Utf8 of displayView to someHTML
   set the menu_Title of displayView to pMenuTitle
   
   -- custom stuff
   -- setDisplayStackRect displayView, cloneStackName
   set the view_TextWrap of displayView to true
   set the style of stack cloneStackName to "palette"
   
   -- show and go
   view_CloneShow cloneStackName, widgetDisplayTitle, displayStackLabel
   return displayView
end display_HTML


--> Deps
-
command stack_CloneInvisible stackNameToClone, pCloneName
   if exists (stack stackNameToClone) is false then return empty
   if pCloneName is empty then put stackNameToClone into pCloneName
   
   put stack_ConstructNewCloneName (pCloneName) into newStackName
   clone invisible stack stackNameToClone as newStackName
   put it into clonedStack
   return newStackName
end stack_CloneInvisible

command stack_Clone stackNameToClone, pDestroyBoolean, pCloneName
   if exists (stack stackNameToClone) is false then return empty
   if pCloneName is empty then put stackNameToClone into pCloneName
   
   put stack_ConstructNewCloneName (pCloneName) into newStackName
   clone stack stackNameToClone as newStackName
   put it into clonedStack
   if pDestroyBoolean is not false then
      set the destroyStack of clonedStack to true
      set the destroyWindow of clonedStack to true
   end if
   return clonedStack
end stack_Clone

command view_SetCloneData cloneStackName, pArray, pMenuArray, pEventArray
   put _displayView (cloneStackName) into displayView
   --  set the data
   set the displayed_Data of displayView to pArray
   set the view_MenuArray of displayView to pMenuArray
   set the view_EventArray of displayView to pEventArray
   
   return displayView
end view_SetCloneData

command view_CloneShow cloneStackName, pDisplayTitle, pStackLabel, pDisplayView
   set the label of stack cloneStackName to pStackLabel
   
   -- set the display
   if pDisplayTitle is not empty then
      if pDisplayView is empty then
         put view_GetTemplateControl (cloneStackName) into pDisplayView
      end if
      set the title_Text of pDisplayView to pDisplayTitle
   end if
   
   -- show and go
   show stack cloneStackName
   go to stack cloneStackName
   return the result
end view_CloneShow


--> Display | Event Handlers
-
/*
These handlers handle events from display views that are created from the code in this library.
They do not have to be here, as you can change their location by setting the "event_Target" property of the display_View.
*/

command project_RemoveOpenStack stackNames
   put project_FetchValue ("openStacks") into projectStackNames
   set the wholematches to true
   repeat for each line stackName in stackNames
      put lineoffset (stackName, projectStackNames) into lineNum
      delete line lineNum of projectStackNames
   end repeat
   project_SaveValue "openStacks", projectStackNames
end project_RemoveOpenStack

command project_GoToStack targetObject, stackName
   if exists (stack stackName) is false then
      put stackName
      project_RemoveOpenStack stackName
      display_LoadedStacks
      answer warning merge ("Cannot locate stack '[[stackName]]'")
      exit to top
   end if
   
   if the scriptonly of stack stackName is true then
      edit the script of stack stackName
   else
      go to stack stackName
   end if
end project_GoToStack

command display_ObjectHkeyArrayHandler treeWidget, someValue, pathItems
   put 1 into hNum
   put item 1 of pathItems into hObject
   get item 2 of pathItems 
   set the itemdelimiter to "_"
   put item 1 to -2 of it into hName
   put item -1 of it into hType
   put hName,hType,hObject,hNum into hKey
   put hKey
   
   hkey_Edit hKey
end display_ObjectHkeyArrayHandler

command display_HkeyArrayHandler treeWidget, someValue, pathItems
   put item 1 of pathItems into hKey
   replace slash with comma in hKey
   put hKey
   hkey_Edit hKey
end display_HkeyArrayHandler

command opnMenus_EditScript targetObject, globalMenuCardName
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   edit the script of card globalMenuCardName of stack longStackFile
end opnMenus_EditScript

command opnScripts_EditScript targetObject, globalMenuCardName
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Scripts.rev" into longStackFile
   edit the script of card globalMenuCardName of stack "libOPN_Scripts|OPN Stack Menus" of stack longStackFile
end opnScripts_EditScript


--> Private
-
private function _displayView cloneStackName
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


--> Deps
-
function view_GetTemplateControl viewName
   -- see older "view_GetTemplateObject"
   
   if exists (stack viewName) is false then return empty
   if exists (control 1 of card 1 of stack viewName) is false then return empty
   put the long id of control 1 of card 1 of stack viewName into templateControl
   return templateControl
end view_GetTemplateControl
