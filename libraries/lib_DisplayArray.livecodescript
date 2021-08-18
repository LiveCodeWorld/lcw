script "lib_DisplayArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayArray
type: library
version: 0.1

/*Some help*/


--> Working on
-

--> Display | Tools
-
command display_Tools someData, pTitle, pToolPath, pStackLabel, pProjectName, pPalette, pTopLeft, pFoldedArray
   # Display data depending on ducktyping of content
   display_Data someData, pTitle, pStackLabel, "", pPalette, pTopLeft, pFoldedArray
   put the result into displayView
   
   # Set menus and mouse_DoubleUp
   set the tool_Menus [pProjectName] of displayView to pToolPath
   return displayView
end display_Tools

command display_SetToolMenus menuBit, displayView, pProjectName
   -- usually called by the tool_Menus of displayView
   dispatch "ask_CreateToolMenus" with menuBit,pProjectName
   --
   put "Global |" && menuBit && "| Menu" into titleMenu
   put "Global |" && menuBit && "| Line | Menu" into lineMenu
   --
   replace "|" with empty in menuBit
   replace space with empty in menuBit
   put "mDoubleUp_" & menuBit into pDoubleUp
   --
   set the title_Menu of displayView to titleMenu
   set the line_Menu of displayView to lineMenu
   set the mouse_DoubleUp of displayView to pDoubleUp
   --
   put menu_GetGlobalController (titleMenu)  into mController
   if exists (mController) then
      set the mouse_Target of displayView to mController
   end if
end display_SetToolMenus

command ask_CreateToolMenus menuBit, pProjectName, pDoubleUp
   put "Global |" && menuBit && "| Menu" into titleMenu
   put "Global |" && menuBit && "| Line | Menu" into lineMenu
   --
   if pDoubleUp is empty then
      replace "|" with empty in menuBit
      replace space with empty in menuBit
      put "mDoubleUp_" & menuBit into pDoubleUp
   end if
   --
   if there is a stack pProjectName then
      put the name of stack pProjectName into libObject
   else
      put debug_GetCallingObject(2) into libObject
   end if
   --
   ask_CreateMenuFromObject titleMenu, libObject
   ask_CreateMenuFromObject lineMenu, libObject
   ask_CreateMouseDoubleUpHandler pDoubleUp, libObject
end ask_CreateToolMenus

command ask_CreateMouseDoubleUpHandler mDoubleUp, titleController
   put "M" && mDoubleUp into shortHKey
   -- put the script_HandlerExists [shortHKey] of libObject into handlerExists
   put the found_Hkey [shortHKey] of titleController is not empty into handlerExists
   if handlerExists is true then return empty
   
   put "on" && mDoubleUp into mDoubleUpHandler
   put space & "displayView, someLine" after mDoubleUpHandler
   put CR & "    put the title_Text of displayView into someTitle" after mDoubleUpHandler
   put CR & "    return displayView" after mDoubleUpHandler
   put CR & "end" && mDoubleUp after mDoubleUpHandler
   --
   display_Handler mDoubleUp, mDoubleUpHandler, "DoubleUp Handler"
   put the result into indexView
   return indexView
end ask_CreateMouseDoubleUpHandler


--> Display | Data
-
command display_Data someContent, pTitle, pStackLabel, pDisplayView, pPalette, pTopLeft, pFoldedArray
   lock screen
   if exists (pDisplayView) is false then
      if someContent is an array then
         put display_FindView (pStackLabel, pTitle, "Display Array") into pDisplayView
      else
         put display_FindView (pStackLabel, pTitle, "Display Index") into pDisplayView
      end if
   end if
   
   if someContent is an array then -- display an array
      display_Array someContent, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
      put the result into pDisplayView
   else
      if exists (pDisplayView) then
         set the displayed_Index [pTitle] of pDisplayView to someContent
         if pStackLabel is not empty then
            put the stack_Name of pDisplayView into stackName
            set the label of stack stackName to pStackLabel
         end if
      else
         display_Lines someContent, pTitle, empty, pStackLabel, pPalette, pTopLeft
         put the result into pDisplayView
      end if
   end if
   unlock screen
   --
   object_GoTo pDisplayView
   return pDisplayView
end display_Data


--> Display | Array
-
command display_Array sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   if exists (pDisplayView) is true then
      -- this default assumes we do not want to change the folded state if the stack already is open
      put empty into pFoldedArray
   else
      put display_FindView (pStackLabel, pTitle, "Display Array") into pDisplayView
      if exists (pDisplayView) is true then
         -- this default assumes we do not want to change the folded state if the stack already is open
         put empty into pFoldedArray
      end if
   end if
   --
   display_InvisibleArray sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   put the result into displayView
   --
   put the stack_Name of displayView into stackName
   show stack stackName
   return displayView
end display_Array

command display_InvisibleArray sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pTopLeft, pPalette
   if exists (pDisplayView) then
      set the displayed_Array [pTitle] of pDisplayView to sArray
      if pFoldedArray is an array then set the fold_State of pDisplayView to pFoldedArray
      if pStackLabel is not empty then
         put the stack_Name of pDisplayView into stackName
         set the label of stack stackName to pStackLabel
      end if
   else
      _CreateInvisibleData sArray, pTitle, pStackLabel, pFoldedArray, pPalette
      put the result into pDisplayView
   end if
   return pDisplayView
end display_InvisibleArray


--> Display | FindView
-
function display_ViewExists displayStackLabel, pDisplayViewTitle
   put display_FindView (displayStackLabel, pDisplayViewTitle) into displayView
   put exists (displayView) into displayViewExists
   return displayViewExists
end display_ViewExists

function display_FindView displayStackLabel, pDisplayViewTitle, pTypes
   -- Looks for Display Array, and Display Index views depending on pTypes
   if pTypes is empty then put "Display Index,Display Array" into pTypes
   
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      get word 1 to 2 of dStackName
      if it is not among the items of pTypes then next repeat
      if the label of stack dStackName = displayStackLabel then
         put the long id of group 1 of stack dStackName into displayView
         if pDisplayViewTitle is empty then
            return displayView
         else if the title_Text of displayView = pDisplayViewTitle then
            return displayView
         end if
      end if
   end repeat
   return empty
end display_FindView


--> Private
-
private command _CreateInvisibleData someArray, pDisplayTitle, pStackLabel, pFoldedArray, pLocOrRect, pPalette
   put "View|Tree|Widget with Title" into viewName
   if pDisplayTitle is empty then put "Array" into pDisplayTitle
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Array"
   put the result into cloneStackName
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   --
   set the displayed_Data of displayView to someArray
   if pFoldedArray is an array then
      -- sensitive to capitalisation
      set the fold_State of displayView to pFoldedArray
   end if
   
   -- custom stuff
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to "random"
   put the result into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   --
   if line 1 of keys (someArray) is a number then
      set the tree_SortType of displayView to "numeric"
   end if
   --
   set the title_Text of displayView to pDisplayTitle
   if pStackLabel is not empty then
      set the label of stack cloneStackName to pStackLabel
   end if
   --
   stack_Position cloneStackName, pLocOrRect
   --
   stack_SetStyle cloneStackName, pPalette
   --
   return displayView
end _CreateInvisibleData

private command stack_SetStyle cloneStackName, pPalette
   switch pPalette
      case "system"
         set the systemWindow of stack cloneStackName to true
         break
      case false
         break
         -- case empty
         -- case true
      default
         set the style of stack cloneStackName to "palette"
   end switch
end stack_SetStyle
