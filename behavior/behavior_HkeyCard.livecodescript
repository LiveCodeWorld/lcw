script "behavior_DisplayHkeyCard"
--> MetaData
-
license: GPLv3
name: behavior_DisplayHkeyCard
type: behavior
version: 0.2

/*
This behavior is for the card "Display Hkey" of stack libOPN_Hkey

Don't use it as a library because it will muck up the menus globally.
*/


--> Menu | Props
-
getprop menu_Target [mTitlepath]
   -- Global | Handler | Menu
   put the displayed_Hkey of me into hKey
   return hKey
end menu_Target

-- getprop menu_ToolTitle
return "Global | Title | Controller | Menu"
end menu_ToolTitle

getprop menu_Version
   return 1
end menu_Version


--> Events
-
on closeField   
   put the short name of the target into fieldName
   switch fieldName
      case "Text"
         -- in danger of doing it twice (could save hash)
         put the displayed_Hkey of me into hKey
         put the displayed_HelpHtmltext of me into helpText
         put the displayed_HkeyVersion of me into versionName
         hkey_StoreHelp hKey, helpText, versionName
         break
      case "Script"
         break
      default
         -- opn_Notify fieldName, true
   end switch
   pass closeField
end closeField

on selectionChanged pHilitedIndex, pPreviouslyHilitedIndex
   if pHilitedIndex is empty then
      pass selectionChanged -- for non-datagrid selectionChanged messages
   else
      click_Handler pHilitedIndex, pPreviouslyHilitedIndex
   end if
   pass selectionChanged
end selectionChanged

on mouseDoubleUp 
   put the the short name of the target into shortName
   switch
      case shortName is among the items of "image,_View Background"
         set the cursor to watch
         put the hkey_ImageView of me into hkeyImageView
         set the visible_Status of hkeyImageView to false
         
         put the displayed_Hkey of the target into hKey
         if the display_ProjectHandlers of me is true then
            put project_HandlerMetadataFolder (hKey) into overlayFolder
         else
            put library_HkeyFolder (hKey, true) into overlayFolder
         end if
         
         put overlay_GetDefaultName (overlayFolder) into pOverlayName
         put empty into pStackLabel
         display_Overlay overlayFolder, pOverlayName -- , empty, pStackLabel, "fit inside frame"
         break
      case shortName is among the items of "_Text Field,Script"  
         put the record_Array of the target into recordArray
         put recordArray ["hKey"] into hKey
         if the display_ProjectHandlers of me is true then
            hKey_EditFoundHandler hKey
         else
            put library_FetchHandler (hKey)
         end if
         break
      default
         opn_Notify shortName
   end switch
end mouseDoubleUp

on linkClicked someLink
   put the clicktext into cText
   switch
      case someLink= cText
         put the displayed_Hkey of me into hKey
         put item 1 of hKey into hName
         put item 2 of hKey into hType
         put (word 1 of someLink = hName) and (hType is among the items of "c,m") into isCommand
         if word 1 of someLink is among the items of "get,put,answer,ask" or isCommand then
            replace "•" with CR in someLink
            do someLink
         else
            link_DictionaryLink someLink
         end if
         break
      default
         do someLink
   end switch
   pass linkClicked
end linkClicked

command link_DictionaryLink someLink
   put the displayed_Hkeys of me into displayedHkeys
   put line 1 of hkey_FindHandler (someLink) into hKey
   if hKey is among the lines of displayedHkeys then
      put the displayed_HelpHkey of me into pDisplayedHelpHKey
      lock screen
      display_HkeyHelp hKey, pDisplayedHelpHKey
      set the dg_SelectedHkey of this cd to hKey
      unlock screen
   else
      display_Hkey hKey
   end if
end link_DictionaryLink


--> Events | Stuff
-
function hkey_FindHandler hKey
   return hKey
   
   switch the number of items of hKey
      case 2
         -- let's look it up in the handler library
         break
      case 4
         -- let's look it up in the project library
         break
      default
         -- let's look it up in the handler library
         put hKey into handlerName
         
   end switch
end hkey_FindHandler

command click_Handler pHilitedIndex, pPreviouslyHilitedIndex
   put the dataGrid_View of me into dgView
   if pHilitedIndex is empty then put the dgHilitedIndex of dgView into pHilitedIndex
   
   put the dgDataOfIndex [pHilitedIndex] of dgView into recordArray
   put recordArray ["hkey"] into hKey
   
   if pPreviouslyHilitedIndex is empty then
      put empty into pDisplayedHelpHKey
   else
      put the dgDataOfIndex [pPreviouslyHilitedIndex] of dgView into recordArray
      put recordArray ["hkey"] into pDisplayedHelpHKey
   end if
   
   display_HkeyHelp hKey, pDisplayedHelpHKey
end click_Handler


--> Events | Custom
-
on overlay_MouseUp tObject
   put the node_Url of tObject into hKey
   put dg_FindLine (hKey) into newIndex
   
   put the dataGrid_View of me into dgView
   put the dgHilitedLine of dgView into previouslyHilitedIndex
   
   lock screen
   set the dgHilitedLine of dgView to newIndex
   click_Handler newIndex, previouslyHilitedIndex
   set the dg_SelectedHkey of this cd to hKey
   unlock screen
end overlay_MouseUp

on overlay_MouseDoubleUp tObject
   put the node_Url of tObject into hKey
   display_Hkey hKey
end overlay_MouseDoubleUp

getprop record_Views [hKeys]
   put the dataGrid_View of me into dgView
   repeat for each line hKey in hKeys
      dispatch "FindLine" to dgView with "hKey", hKey
      put the result into lineNum
      put the dgDataControlOfLine [lineNum] of dgView
      put dgView & CR after dgViews
   end repeat
   delete char -1 of dgViews
   return dgViews
end record_Views

setprop record_Colour [hKeys] someColour
   put the dataGrid_View of me into dgView
   repeat for each line hKey in hKeys
      dispatch "FindLine" to dgView with "hKey", hKey
      put the result into lineNum
      put the dgDataControlOfLine [lineNum] of dgView into recordView
      -- put the record_Array of recordView into recordArray
      if exists (recordView) is false then next repeat -- record not cached
      set the background_Colour of recordView to someColour
      put dgView & CR after dgViews
   end repeat
   delete char -1 of dgViews
   return dgViews
end record_Colour


--> Menu | Props
-
local LocalArray

getprop menu_Title
   -- menus should all be in the substack
   put the short name of the target into someName
   if the display_ProjectHandlers of me is true then
      switch someName
         case "Right Icon"
            return "Hkey | Project | Record | Menu"  -- "Hkey | Record | Menu" 
         case "Title"
            return "Hkey | Project | Menu" -- "Hkey | Menu"
         default
            pass menu_Title
      end switch
   else -- "long"
      switch someName
         case "Right Icon"
            return "Hkey | Library | Record | Menu"  -- "Hkey | Record | Short | Menu" 
         case "Title"
            return "Hkey | Library | Menu" -- "Hkey | Short | Menu"
         default
            pass menu_Title
      end switch
   end if
end menu_Title


--> Display
-
command display_HkeyHelp hKey, pDisplayedHelpHKey
   put the long id of me into displayCard
   put the display_ProjectHandlers of displayCard into displayProjectHandlers
   if displayProjectHandlers is true then
      display_ProjectHkeyHelp hKey, pDisplayedHelpHKey
   else
      display_HkeyLibraryHelp hKey, pDisplayedHelpHKey
   end if
end display_HkeyHelp

command display_ProjectHkeyHelp hKey, pDisplayedHelpHKey
   lock screen
   --
   put the long id of me into displayCard
   if pDisplayedHelpHKey is empty then put the displayed_HelpHkey of displayCard into pDisplayedHelpHKey
   
   if pDisplayedHelpHKey is not empty then  -- save any displayed help  
      put the displayed_HelpHtmltext of displayCard into displayedHandlerHelp
      project_StoreHandlerHelp pDisplayedHelpHKey, displayedHandlerHelp
   end if
   
   put project_FetchHandlerHelp (hkey) into handlerHelp
   -- for project help, we can take the library help for a handler if it is in the library!
   if handlerHelp is empty then
      put library_FetchHandlerHelp (hkey) into handlerHelp
   end if
   set the displayed_HelpHtmltext of displayCard to handlerHelp
   
   put the help_Field of me into helpField
   lock messages
   set the displayed_HelpHkey of helpField to hKey
   unlock messages
   
   put the hkey_ImageView of me into hkeyImageView
   put the overlay_View of hkeyImageView into overlayView
   set the selected_Hkeys of overlayView to hKey
   unlock screen
end display_ProjectHkeyHelp

command display_HkeyLibraryHelp hKey, pDisplayedHelpHKey
   lock screen
   --
   put the long id of me into displayCard
   if pDisplayedHelpHKey is empty then put the displayed_HelpHkey of displayCard into pDisplayedHelpHKey
   -- opn_Notify (hKey & CR & pDisplayedHelpHKey & CR & displayProjectHandlers), true
   put the display_ProjectHandlers of displayCard into displayProjectHandlers 
   
   if pDisplayedHelpHKey is not empty then  -- save any displayed help  
      put the displayed_HelpHtmltext of displayCard into displayedHandlerHelp
      -- hkey_StoreHelp pDisplayedHelpHKey, displayedHandlerHelp
      library_StoreHandlerHelp pDisplayedHelpHKey, displayedHandlerHelp
   end if
   
   -- if hKey is not pDisplayedHelpHKey then  -- only display when different (prevents displaying empty help when newly creating)
   put library_FetchHandlerHelp (hkey) into handlerHelp
   set the displayed_HelpHtmltext of displayCard to handlerHelp
   -- end if
   
   put the help_Field of me into helpField
   -- lock messages
   set the displayed_HelpHkey of helpField to hKey
   -- unlock messages
   -- put hKey into LocalArray ["displayed_HelpHkey"]
   
   put the hkey_OverlayView of me into overlayView
   if exists (overlayView) then set the selected_Hkeys of overlayView to hKey
   unlock screen
end display_HkeyLibraryHelp

-- command display_HiliteHkeyRecord hKey
put the dataGrid_View of me into dgView

-- put the dgDataOfIndex [pHilitedIndex] of dgView into recordArray
put recordArray ["hkey"] into hKey
put recordArray ["hkey"] into pDisplayedHelpHKey

display_HkeyHelp hKey
end display_HiliteHkeyRecord


--> Display | Props
-
getprop displayed_Hkeys
   put the dataGrid_View of me into dgView
   put the dgIndexes of dgView into sIndex
   
   put the dgdata of dgView into dataArray
   repeat for each item indexNum in sIndex
      put dataArray [indexNum]["hKey"] & CR after displayedHKeys
   end repeat
   delete char -1 of displayedHKeys
   return displayedHKeys
end displayed_Hkeys

setprop displayed_Hkeys [libraryOrProject] hKeys
   lock screen
   if libraryOrProject = "project" then
      set the display_ProjectHandlers of me to true
      put project_ConstructDisplayDataArray (hKeys) into dataArray
   else
      set the display_ProjectHandlers of me to false
      put library_ConstructDisplayDataArray (hKeys) into dataArray
   end if
   put line 1 of hKeys into hKey
   display_HkeyDataArray hKey, dataArray
   unlock screen
end displayed_Hkeys

getprop display_ProjectHandlers
   return the hkey_Type of me is not "short"
end display_ProjectHandlers

setprop display_ProjectHandlers [pWithDeps] someBoolean
   if someBoolean is true then
      if pWithDeps is not false then
         set the hkey_Type of me to "long"
      else
         set the hkey_Type of me to "no dependency index"
      end if
   else
      set the hkey_Type of me to "short"
   end if
end display_ProjectHandlers

getprop hkey_Type
   put the header_Colour of me into headerColour
   switch headerColour
      case "51,51,51"
         return "long"
      default -- case "83,85,133"
         return "short"
   end switch
end hkey_Type

setprop hkey_Type hkeyType
   switch hkeyType
      case "short"
         set the header_Colour of me to "83,85,133"
         break
      case "long"
         set the header_Colour of me to "51,51,51"
         break
      case "no dependency index"
         set the header_Colour of me to red
         break
   end switch
end hkey_Type


--> Field | HyperText | Menu
-
on menu_Link hyperField
   put hyperField
end menu_Link


--> Overlay
-
getprop overlay_Folder
   -- for hkeys this is the same as "library_HandlerFile"
   put the displayed_Hkey of me into hKey
   put library_HkeyFolder (hKey) into overlayFolder
   return overlayFolder
end overlay_Folder


--> Data
-
command dg_Refresh pHow
   put the datagrid_View of me into revDataGrid
   switch pHow
      case "ResetControl"
         send "ResetControl"  to revDataGrid in 0 ticks -- Resets the control by clearing out any data.
         return pHow
      case "ResetList" 
         send "ResetList"  to revDataGrid in 0 ticks -- Redraws the data grid data after having copied in fresh copies of any templates.
         return "ResetList"
      default -- case "RefreshList"
         send "RefreshList"  to revDataGrid in 0 ticks -- Redraws the data displayed in the data grid.
         return pHow
   end switch
end dg_Refresh

getprop dg_SelectedHkey
   put the dataGrid_View of me into dgView
   put the dgHilitedIndex of dgView into pHilitedIndex
   put the dgDataOfIndex [pHilitedIndex] of dgView into recordArray
   put recordArray ["hkey"] into hKey
   return pHilitedIndex
end dg_SelectedHkey

setprop dg_SelectedHkey hKey
   put the dataGrid_View of me into dgView
   dispatch "FindIndex" to dgView with "hKey", hKey
   put the result into theIndex
   
   -- lock screen
   set the dgHilitedIndex of dgView to theIndex
   set the dgFocus of dgView to true
   -- unlock screen
   return theIndex
end dg_SelectedHkey

getprop selected_Hkey
   put the dataGrid_View of me into dgView
   put the dgHilitedindex of dgView into pHilitedIndex
   put the dgDataOfIndex [pHilitedIndex] of dgView into recordArray
   put recordArray ["hkey"] into hKey
   return pHilitedIndex
end selected_Hkey

function dg_FindLine hKey
   put the dataGrid_View of me into dgView
   if the display_ProjectHandlers of me is false then
      put item 1 to 2 of hKey into hKey
   end if
   dispatch "FindLine" to dgView with "hKey", hKey
   put the result into newIndex
   return newIndex
end dg_FindLine

getprop dg_Index [hKey]
   if hKey is empty then
      put the dgHilitedIndex of the dataGrid_View of me into theIndex
   else
      dispatch "FindIndex" to the dataGrid_View of me with "hKey", hKey
      put the result into theIndex
   end if
   return theIndex
end dg_Index

on dg_FillInData recordArray, recordView
   -- for script title sections
   lock screen
   put recordArray ["hKey"] into hKey
   put recordArray ["isExpanded"] into isExpanded
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if isExpanded is true then
      -- put hkey_GetObjectHandler (hKey, false) into someHandler
      
      -- fetch live
      if exists (hObject) is false then
         set the hkey_Title of recordView to hKey
         if the display_ProjectHandlers of me is true then
            -- should this be hkey_GetHandler - anywhere from hierarchy ????
            put hkey_ExtractHandlerFromObject (hKey) into someHandler
         else
            put library_FetchHandler (hKey) into someHandler
         end if
         if someHandler is empty then put hKey & CR & CR & "Handler is missing" into someHandler
         set the record_Handler of recordView to someHandler
      else
         -- put the script_Handler [hKey] of hObject into someHandler
         try
            put the revAvailableHandlers of hObject into handlerTable
            script_HandlerFromTableOffsets hKey, handlerTable, startLineNum, endLineNum
            if startLineNum = 0 then
               -- look for private handler?
               put "P" before item 2 of hKey
               script_HandlerFromTableOffsets hKey, handlerTable, startLineNum, endLineNum
               if startLineNum = 0 then
                  set the record_Handler [startLineNum] of recordView to hKey
               else
                  put the script of hObject into someScript
                  put line startLineNum to endLineNum of someScript into someHandler
                  set the record_Handler [startLineNum] of recordView to someHandler
               end if
            else
               put the script of hObject into someScript
               put line startLineNum to endLineNum of someScript into someHandler
               set the record_Handler [startLineNum] of recordView to someHandler
            end if
         catch someError
            breakpoint
            -- set the hkey_Title of recordView to hKey  -- a locked stack
            set the record_Handler [startLineNum] of recordView to hKey
         end try
      end if
   else
      if exists (hObject) is false and the number of items of hKey = 4 then
         put CR & "  (handler is missing)" after hKey
      end if
      set the hkey_Title of recordView to hKey
   end if
   
   set the record_IsExpanded of recordView to isExpanded
   -- if hkey_IsInLibrary (hKey) then set the background_Colour of recordView to "red"
   unlock screen
end dg_FillInData


--> Layout | Options
-
getprop image_Visible
   put the visible_Status of the hkey_ImageView of me into someBoolean
   return someBoolean
end image_Visible

setprop image_Visible [pOverlayName] someBoolean
   if someBoolean is true then
      put the displayed_Hkey of me into hKey
      set the displayed_HkeyGraph [pOverlayName] of me to hKey
      put the result into imageFile
      return imageFile
   else
      lock screen
      set the visible_Status of the hkey_ImageView of me to someBoolean
      set the visible_Status of the description_Header of me to false
      unlock screen
   end if
end image_Visible

getprop displayed_ImageFile [pOverlayName]
   put the displayed_Hkey of me into hKey
   if the display_ProjectHandlers of me is true then
      put hkey_ProjectImageFile (hKey, pOverlayName) into imageFile
   else
      put hkey_LibraryImagetFile (hKey, pOverlayName) into imageFile
   end if
   return imageFile
end displayed_ImageFile

setprop displayed_HkeyGraph [pOverlayName] hKey 
   put the hkey_ImageView of me into hkeyImageView
   
   if the display_ProjectHandlers of me is true then
      -- put hkey_ProjectImageFile (hKey, pOverlayName) into imageFile
      put project_HandlerMetadataFolder (hKey) into overlayFolder
   else
      -- put hkey_LibraryImagetFile (hKey, pOverlayName) into imageFile
      put library_HkeyFolder (hKey, true) into overlayFolder
   end if
   if there is not a folder overlayFolder then return empty
   
   if pOverlayName is empty then put overlay_GetDefaultName (overlayFolder) into pOverlayName
   if pOverlayName is "default" then -- hack for now to delete the old "default" graph
      overlay_SetArray overlayFolder, empty, "default"
      put overlay_GetDefaultName (overlayFolder) into pOverlayName
   end if
   
   put pOverlayName & "." & "png" into shortFile
   put overlayFolder & shortFile into imageFile
   put there is a file imageFile into fileExists
   if fileExists is false then
      set the visible_Status of hkeyImageView to false
      return empty
   else
      lock screen
      set the visible_Status of hkeyImageView to true
      display_Overlay overlayFolder, pOverlayName, hkeyImageView, "fit inside frame"
      unlock screen
      return imageFile
   end if
end displayed_HkeyGraph


--> Displayed | Hkey
-
getprop displayed_HelpHkey
   put the help_Field of me into helpField
   lock messages
   put the displayed_HelpHkey of helpField into hKey
   unlock messages
   -- put LocalArray ["displayed_HelpHkey"] into hKey
   return hKey
end displayed_HelpHkey

setprop displayed_HelpHkey [pDisplayedHelpHKey] hKey
   put the help_Field of me into helpField
   lock messages
   set the displayed_HelpHkey of helpField to hKey
   unlock messages
   -- display_HkeyHelp hKey, pDisplayedHelpHKey
end displayed_HelpHkey

getprop displayed_ImageFile
   put the image_File of the hkey_ImageView of me into imageFile
   return imageFile
end displayed_ImageFile

setprop displayed_ImageFile imageFile
   set the image_File of the hkey_ImageView of me to imageFile
   return the result
end displayed_ImageFile

getprop displayed_Hkey
   put the displayed_Title of me into someTitle
   put line 2 of someTitle into hKey
   return hKey
end displayed_Hkey

setprop displayed_Hkey hKey
   put item 1 of hKey into hName
   put hName & CR & hKey into someTitle
   set the displayed_DescriptionTitle of me to hKey
   set the displayed_Title of me to someTitle
end displayed_Hkey

getprop displayed_Handler [pIndexNum]
   if pIndexNum is empty then put 1 into pIndexNum
   
   put the dataGrid_View of me into dgView
   put the dgDataOfIndex [ pIndexNum ] of dgView into recordArray
   put recordArray ["hKey"] into hKey
   
   if isProject is true then
      put hkey_ExtractHandlerFromObject (hKey) into someHandler
   else
      put library_FetchHandler (hKey) into someHandler
   end if
   return someHandler
end displayed_Handler

getprop displayed_Script
   put the dataGrid_View of me into dgView
   put the dgIndexes of dgView into sIndex
   
   put the dgdata of dgView into dataArray
   put the display_ProjectHandlers of me into isProject
   repeat for each item indexNum in sIndex
      put dataArray [indexNum]["hKey"] into hKey
      
      if isProject is true then
         put hkey_ExtractHandlerFromObject (hKey) into someHandler
      else
         put library_FetchHandler (hKey) into someHandler
      end if
      put someHandler & CR & CR after someScript
   end repeat
   delete char -2 to -1 of someScript
   return someScript
end displayed_Script
