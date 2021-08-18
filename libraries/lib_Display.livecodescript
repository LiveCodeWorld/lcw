script "lib_Display"
--> MetaData
-
copyright: David Bovill
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


--> Display | Ask
-
command display_SetMenu displayView, gMenuTitle, pMenuProp
   if not (gMenuTitle begins with "Global | ") then 
      put "Global | " before gMenuTitle
   end if
   if not (gMenuTitle ends with " | Menu") then 
      put  "| Menu" after gMenuTitle
   end if
   --
   if pMenuProp is empty then put "title_Menu" into pMenuProp
   --
   set the pMenuProp of displayView to gMenuTitle
   put debug_GetCallingObject(1) into libObject
   ask_CreateMenuFromObject gMenuTitle, libObject
   --
   return libObject
end display_SetMenu

command display_SetInteractions displayView, menuBit, pDoubleUp
   put "Global |" && menuBit && "| Menu" into titleMenu
   put "Global |" && menuBit && "| Line | Menu" into lineMenu
   --
   set the title_Menu of displayView to titleMenu
   set the line_Menu of displayView to lineMenu
   --
   put debug_GetCallingObject(1) into libObject
   ask_CreateMenuFromObject titleMenu, libObject
   ask_CreateMenuFromObject lineMenu, libObject
   --
   set the mouse_DoubleUp of displayView to pDoubleUp
   put menu_GetGlobalController (titleMenu) into titleController
   if pDoubleUp is empty then return displayView
   
   if exists (titleController) then
      set the mouse_Target of displayView to titleController
      ask_CreateMouseDoubleUpHandler pDoubleUp, titleController
   end if
   return displayView
end display_SetInteractions


--> Props
-
getprop view_StackRect [lastStackRect]
   put the long id of the target into newViewObject
   put the formatted_Rect of newViewObject into fRect
   put the screen_Rect of newViewObject into displayScreenRect
   --
   if lastStackRect is empty then
      put stack_GetLastRect() into lastStackRect
   end if
   --
   put display_GetNewStackRect (lastStackRect, fRect, displayScreenRect) into newRect
   return newRect
end view_StackRect

getprop display_BelowRect [fRect]
   put the long id of the target into tObject
   --
   if fRect is empty then
      put the formatted_Rect of tObject into fRect
   end if
   put the rect of tObject into oRect
   put the screen_Rect of tObject into displayScreenRect
   --
   put display_GetNewStackRect (oRect, fRect, displayScreenRect) into newStackRect
   return newStackRect
end display_BelowRect

getprop stack_IsDisplay
   put the stack_Name of the target into stackName
   switch
      case word 1 to 2 of stackName is not among the items of "Display Index,Display Array"
      case exists (control 1 of card 1 of stack stackName) is false
         return false
      default
         put the view_Name of control 1 of card 1 of stack stackName into viewName
         --
         put "View|Tree|Widget with Title,View|Index|Simple" into displayViewNames
         if viewName is among the items of displayViewNames then
            return true
         else
            return false
         end if
   end switch
end stack_IsDisplay

getprop stack_BelowRect [fRect]
   put the long id of the target into tObject
   put the stack_Name of the target into stackName
   --
   put the rect of stack stackName into oRect
   put the screen_Rect of tObject into displayScreenRect
   --
   if fRect is empty then
      put the formatted_Rect of tObject into fRect
      if fRect is empty then put the rect of tObject into fRect
   end if
   --
   put display_GetNewStackRect (oRect, fRect, displayScreenRect) into newStackRect
   return newStackRect
end stack_BelowRect


--> Display | Exists
-
function display_GetObject tObject
   -- a utility function to allow general listing of a script object
   -- whether directly from the script editor or an index or array dispayView
   
   put the display_View of tObject into displayView
   put the stack_Name of tObject into stackName
   switch
      case word 1 of stackName = "revNewScriptEditor"
         -- revNewScriptEditor 1
         put scriptEditor_Object() into sObject
         return sObject         
         break
      default
         put the displayed_Object of displayView into sObject
         if exists (sObject) is false then return empty
         return sObject
   end switch
end display_GetObject


--> Display | Specialised
-
command display_Index someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette, pTopLeft
   -- phase out and use "display_Lines" instead
   put empty into oRect
   --
   display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put the result into displayView 
   put token -1 of displayView into cloneStackName
   --
   put the view_StackRect [oRect] of displayView into newRect
   stack_Position cloneStackName, newRect
   --
   show stack cloneStackName
   go to stack cloneStackName
   return displayView
end display_Index

function stack_GetLastRect
   put line -1 of display_ListIndexStackNames() into lastIndexStackName
   if lastIndexStackName is empty then
      put stack_GetTop (true) into stackName 
      if exists (stack stackName) is false then return empty
      put the rect of stack stackName into pRect
   else
      put the rect of stack lastIndexStackName into pRect
   end if
   return pRect   
end stack_GetLastRect

function stack_GetTop pWithoutDisplay
   put the openstacks into stackList
   --
   if pWithoutDisplay is not false then
      filter stackList without "Display*"
   end if
   --
   filter stackList without "rev*"
   filter stackList without "Message Box"
   filter stackList without "com.*"
   filter stackList without "Global |*"
   sort stackList
   put line 1 of stackList into stackName
   return stackName
end stack_GetTop

function display_ListIndexStackNames
   put the openstacks into indexStackNames
   filter indexStackNames with "Display Index *"
   sort indexStackNames by word -1 of each
   return indexStackNames
end display_ListIndexStackNames

command stack_ShowAndGo viewObject, cloneStackName, pStackLabel, pStackStyle, pLocORRect
   if pStackStyle is empty then put "toplevel" into pStackStyle
   set the stack_Style of stack cloneStackName to pStackStyle
   if pStackLabel is not empty then set the label of stack cloneStackName to pStackLabel
   --
   stack_Position cloneStackName, pLocOrRect
   dispatch "LayoutControl" to viewObject
   --
   show stack cloneStackName
   return pStackLabel
end stack_ShowAndGo

command stack_Position stackName, pLocOrRect
   switch
      case pLocOrRect = "click"
      case pLocOrRect = "mouse"
         -- put globalLoc (the mouseloc) into mGlobalLoc
         put the screenmouseloc into mGlobalLoc
         set the topLeft of stack stackName to mGlobalLoc
         break
      case pLocOrRect is a point
         set the topLeft of stack stackName to pLocOrRect
         break
      case pLocOrRect is a rect
         set the rect of stack stackName to pLocOrRect
         break
      default
         revIDEEnsureOnscreen stackName
   end switch
end stack_Position

function display_GetNewStackRect oStackRect, fRect, displayScreenRect
   if oStackRect is not a rect then
      put 13 into oLeft
      put 41 into oBottom
   else
      put item 1 of oStackRect into oLeft
      put item 4 of oStackRect into oBottom
   end if
   
   put item 3 of fRect into newWidth
   put item 4 of fRect into newHeight
   
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
end display_GetNewStackRect

function display_ConstructFoldState ePaths
   repeat for each item someKey in ePaths
      put false into foldedArray [someKey]["folded"]
   end repeat
   return foldedArray
end display_ConstructFoldState


--> Display | Events
-
/*
These handlers handle events from display views that are created from the code in this library.
They do not have to be here, as you can change their location by setting the "mouse_Target" property of the display_View.
*/

on mDoubleUp_LocateDisplayView treeWidget, displayView, pathItems
   object_GoTo displayView, true
   --
   put the clickloc into sLoc
   put the globalLoc of sLoc into gLoc
   put the stack_Name of displayView into stackName
   --
   set the topleft of stack stackName to gLoc
end mDoubleUp_LocateDisplayView

command mouse_EditObjectScript treeView, scriptObject
   if the optionKey is "Down" then breakpoint
   if exists (scriptObject) then
      edit the script of scriptObject
   end if
end mouse_EditObjectScript

command mDoubleUp_EditOldMenuScript targetObject, globalMenuCardName
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   edit the script of card globalMenuCardName of stack longStackFile
end mDoubleUp_EditOldMenuScript

on mDoubleUp_HkeyLine displayView, hKeyLine
   hkey_Edit hKeyLine
end mDoubleUp_HkeyLine

on mDouble_EditStack displayView, stackName
   edit the script of stack stackName
end mDouble_EditStack


--> Display | Edited
-
command display_EditedStacks
   put stack_ListEditedNames() into stackNames
   display_Data stackNames, "Stacks", "Edited"
   put the result into displayView
   display_SetInteractions displayView, "Edited | Tree", "mDouble_EditStack"
   return displayView
end display_EditedStacks


--> Display | Handler | Exports
-
command display_RecentExports pSinceMin, pIndexView, pDontFilter
   if pSinceMin is empty then
      put 60*60 into someMin
   else
      put word 1 of pSinceMin into someMin
   end if
   --
   put merge ("In last [[someMin]] minutes") into someTitle
   --
   put 60 * someMin into someSec
   put spotlight_ListRecentlyExportedObjects (someSec) into scriptObjects
   if pDontFilter is not true then
      put "Unsaved in" into word 1 of someTitle
      put script_FilterChangedIndex (scriptObjects) into scriptObjects
   else
      put "Modified in" into word 1 of someTitle
   end if
   
   display_Data scriptObjects, "Script Changes", "Script Changes"
   put the result into displayView
   display_SetInteractions displayView, "Script | Changes", "mouse_EditObjectScript"
   return displayView
end display_RecentExports

command display_HkeyLines hkeyLines, someTitle
   local mTitle, mLineTitle, mUp
   display_Index hkeyLines, someTitle, mTitle, mLineTitle, mUp, "mDoubleUp_HkeyLine"
   put the result into indexView
   set the multiple_Hilites of indexView to false
end display_HkeyLines


--> Display | Text
-
command display_Text textOrUrl, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   switch
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

command display_ListDataViews
   put display_FindStackNameArray (empty, empty, true) into displayViewArray
   --
   display_Data displayViewArray, "Views", "Find Displays"
   put the result into displayView
   display_SetInteractions displayView, "Display | View", "mDoubleUp_LocateDisplayView"
   --
   return displayView
end display_ListDataViews

command display_Handler hName, someHandler, stackLabel
   -- display_Text
   display_Data someHandler, hName, stackLabel
   put the result into indexView
   set the field_Style of indexView to "text"
   return indexView
end display_Handler


--> Display | Data | Older
-
command display_Lines someIndex, pTitle, pDoubleUp, pStackLabel, pPalette, pTopLeft
   local pTitleMenu, pLineMenu, pMouseUp, pDragCommand
   
   if pStackLabel is empty then
      put space into pStackLabel
   else
      put comma & pStackLabel after pTitle
   end if
   --
   display_Index someIndex, pTitle, pTitleMenu, pLineMenu, pMouseUp, pDoubleUp, pDragCommand, pPalette, pTopLeft
   put the result into indexView
   --
   set the field_Style of indexView to "click"
   --
   put debug_GetCallingObject() into callingObject
   set the mouse_Target of indexView to callingObject
   --
   return indexView
   -- after displaying you can...
   -- set the title_Menu of displayView to "Global | Test | Menu"
   -- set the line_Menu of displayView to "Global | Test | Line | Menu"
end display_Lines


--> Display | Utilities
-
function display_ListStackNames pSearchStackLabel, pSearchViewTitle
   put display_FindStackNameArray (pSearchStackLabel, pSearchViewTitle) into displayViewArray
   --
   put keys (displayViewArray) into displayStackNames
   sort displayStackNames
   return displayStackNames
end display_ListStackNames

function display_ListViews pSearchStackLabel, pSearchViewTitle
   put display_FindStackNameArray (pSearchStackLabel, pSearchViewTitle) into displayViewArray
   repeat for each key stackLabel in displayViewArray
      put displayViewArray [stackLabel]["displayView"] into dView
      put dView & CR after displayViews
   end repeat
   delete char -1 of displayViews
   return displayViews
end display_ListViews

function display_FindStackNameArray pSearchStackLabel, pSearchViewTitle, pPretty
   -- looks for Dispay Array, and Display Index views
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      get word 1 to 2 of dStackName
      if it is not among the items of "Display Index,Display Array" then next repeat
      
      put the long id of group 1 of stack dStackName into displayView
      --
      put the title_text of displayView into titleText
      put the label of stack dStackName into stackLabel
      
      -- skip unless the following conditions are met
      if pSearchStackLabel is empty then
         put displayView into displayViewArray [dStackName]["displayView"]
         put stackLabel into displayViewArray [dStackName]["stackLabel"]
         put titleText into displayViewArray [dStackName]["titleText"]
      else if stackLabel = pSearchStackLabel then
         if pSearchViewTitle is empty then
            put displayView into displayViewArray [dStackName]["displayView"]
            put stackLabel into displayViewArray [dStackName]["stackLabel"]
            put titleText into displayViewArray [dStackName]["titleText"]
         else if titleText = pSearchViewTitle then
            put displayView into displayViewArray [dStackName]["displayView"]
            put stackLabel into displayViewArray [dStackName]["stackLabel"]
            put titleText into displayViewArray [dStackName]["titleText"]
         end if
      end if
   end repeat
   --
   if pPretty is true then
      put _MakeStackNameArrayPretty (displayViewArray) into prettyArray
      return prettyArray
   else
      return displayViewArray
   end if
end display_FindStackNameArray

command display_Spin someLine, pIndexView, pLineColour
   set the cursor to busy
   if exists (pIndexView) is false then
      set the cursor to busy
      return 0
   end if
   
   # Spin (works with index and array display views)
   lock screen
   set the selected_Line of pIndexView to someLine
   put the result into lineNum
   --
   switch pLineColour
      case "delete"
         set the deleted_Line of pIndexView to lineNum
         break
      case empty
         break
      default
         set the line_Colour [lineNum] of pIndexView to pLineColour
   end switch
   unlock screen
   return lineNum
end display_Spin


--> Display
-
command display_Files filePaths, pFolderToStrip, pMouseDoubleUpHandler, pTitleMenu, pTitle
   put empty into pPathFilter
   put file_ConstructFolderArray (filePaths, pPathFilter, pFolderToStrip) into pathArray
   if pathArray is not an array then
      answer "I cannot find this handler anywhere!"
      exit to top
   end if
   
   put debug_GetCallingObject() into pCommandObject
   display_Array pathArray, pTitle
   put the result into displayView
   set the title_Menu of displayView to pTitleMenu
   set the mouse_DoubleUp of displayView to pMouseDoubleUpHandler
   set the mouse_Target of displayView to pCommandObject
   --   
   set the search_Folder of displayView to pFolderToStrip
   return displayView
end display_Files

command display_TextFile someFile, pDisplayTitle, pMenuTitle, pStackName
   local pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   
   if pMenuTitle is empty then put "Global | Display | File | Menu" into pMenuTitle
   put "file:" & someFile into someUrl
   put url someUrl into someText
   
   put pDisplayTitle,pStackName into displayTitle
   display_Index someText, displayTitle, pMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, true
   put the result into displayView
   --
   put the stack_Name of displayView into stackName
   -- set the cantmodify of stack stackName to true
   --
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

command display_JsonRPC rpcURL, pDisplayTitle, pMouseDoubleUpCommand
   -- put url rpcURL into jsonReply
   put jsonrpc_GET (rpcURL) into jsonReply 
   display_Json jsonReply, pDisplayTitle, pMouseDoubleUpCommand
   return the result
end display_JsonRPC

command display_Json jsonReply, pDisplayTitle, pMouseDoubleUpCommand
   put json_ToArray (jsonReply) into jsonArray
   switch
      case pDisplayTitle is "atom"
         atom_DisplayText jsonReply, "json"
         return empty
      case jsonArray is an array
         local pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pCommandObject
         display_Array jsonArray, pDisplayTitle
         put the result into displayView
         set the title_Menu of displayView to pTreeMenuTitle
         set the line_Menu of displayView to pLineMenuTitle
         set the mouse_DoubleUp of displayView to pMouseDoubleUpCommand
         set the mouse_Target of displayView to pCommandObject
         break
      default
         display_Lines jsonReply, pDisplayTitle
         break
   end switch
   put the result into displayView
   return displayView
end display_Json

command display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put "View|Index|Simple" into viewName
   
   -- new feature for specifying widget and stack label titles using a comma
   _setTitles widgetDisplayTitle, displayStackLabel, pDisplayTitle, "Index"
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Index"
   put the result into cloneStackName
   
   -- don't rely on this. It works only for handlers at the level of "display_Index"
   -- best practice is to "set the mouse_Target of indexView to debug_GetCallingObject()" after you call the display handler you write
   put debug_GetCallingObject (2) into eventArray ["eventTarget"]
   
   -- set basic data  
   put pMouseUpCommand into eventArray ["mouseUp"]
   put pMouseDoubleUpCommand into eventArray ["mouseDoubleUp"]
   put pDragCommand into eventArray ["dragCommand"]
   
   put pTreeMenuTitle into menuArray ["title"]
   put pLineMenuTitle into menuArray ["line"]
   
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   --
   if someIndex is an array then
      set the displayed_Array of displayView to someIndex
   else
      set the view_Index of displayView to someIndex
   end if
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
   
   set the label of stack cloneStackName to displayStackLabel
   set the title_Text of displayView to widgetDisplayTitle
   set the multiple_Hilites of displayView to false -- the most common default
   --
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
   --
   return displayView
end display_InvisibleIndex


--> Deps
-
function colour_GetDarkOrLight someColour
   put colour_RgbToHSV (someColour) into someHSV
   put item 3 of someHSV into howDark
   if howDark > 66 then
      return "10,10,10"
   else
      return "204,204,204"
   end if
end colour_GetDarkOrLight

function colour_RgbToHSV rgbColour
   -- was "rgb_2HSV"
   if rgbColour is not a color then return empty
   
   local maxv, minv, diff, s, rc, gc, bc, h
   
   put item 1 of rgbColour into r
   put item 2 of rgbColour into g
   put item 3 of rgbColour into b
   
   set the numberformat to "0.###############"
   put r / 255 into r
   put g / 255 into g
   put b / 255 into b
   put max(r,g,b) into maxv
   put min(r,g,b) into minv
   put maxv - minv into diff
   if maxv <> 0 and diff <> 0 then
      put diff / maxv into s
      put (maxv - r) / diff into rc
      put (maxv - g) / diff into gc
      put (maxv - b) / diff into bc
      if r = maxv then put bc - gc into h
      else if g = maxv then put 2 + rc - bc into h
      else if b = maxv then put 4 + gc - rc into h
      multiply h by 60
      if h < 0 then
         add 360 to h
      end if
   else
      put 0 into s
      put 0 into h
   end if
   return round(h),round(s * 100),round(maxv * 100)
end colour_RgbToHSV


--> Private
-
private function script_FilterChangedIndex scriptObjects
   repeat for each line scriptObject in scriptObjects
      set the cursor to busy
      if the script_IsDifferent of scriptObject is true then
         put scriptObject & CR after changedScriptObjects
      end if
   end repeat
   delete char -1 of changedScriptObjects
   return changedScriptObjects
end script_FilterChangedIndex

private function _MakeStackNameArrayPretty displayViewArray
   repeat for each key dStackName in displayViewArray
      put displayViewArray [dStackName]["stackLabel"] into stackLabel
      if word 1 to -1 of stackLabel is empty then
         put "Space" into stackLabel
      end if
      put displayViewArray [dStackName]["displayView"] into displayView
      put displayViewArray [dStackName]["titleText"] into titleText
      --
      put displayView into prettyArray [stackLabel][titleText]
   end repeat
   return prettyArray
end _MakeStackNameArrayPretty

private function debug_GetCallingObject pNum
   if pNum is empty then put 1 into pNum
   put (pNum + 2) * -1 into lineNum
   get the executioncontexts
   put item 1 of line lineNum of it into callingObject
   return callingObject
end debug_GetCallingObject

private command _setTitles @widgetDisplayTitle, @displayStackLabel, pDisplayTitle, pDefault
   if pDisplayTitle is empty then
      put pDefault into widgetDisplayTitle
      put empty into displayStackLabel
   else
      put word 1 to -1 of item 1 of pDisplayTitle into widgetDisplayTitle
      put word 1 to -1 of item 2 of pDisplayTitle into displayStackLabel
   end if
end _setTitles
