script "behavior_DataTree"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_DataTree
type: behavior
version: 0.5

--> Variables
-
local LocalArray


--> Working on
-
private function _treeWidget
   return the long id of me
end _treeWidget

getprop doubleClick_Message
   return the uOPN ["doubleClick_Message"] of me
end doubleClick_Message

setprop doubleClick_Message sMessage
   set the uOPN ["doubleClick_Message"] of me to sMessage
end doubleClick_Message

on actionDoubleClick pPathToNode
   if the optionKey is "Down" then breakpoint
   put the doubleClick_Message of me into mDoubleUp
   if mDoubleUp is empty then pass actionDoubleClick
   
   put the doubleClick_Controller of me into mController
   put the selected_Path of me into sPath
   put the long id of me into tObject
   
   dispatch mDoubleUp to mController with tObject,sPath
   if it is "unhandled" then
      breakpoint
      edit the script of mController
      put mDoubleUp
   end if
end actionDoubleClick


--> Events
-
on actionInspect pPath
   put the displayed_Array of me into sArray
   split pPath with comma
   put sArray [pPath] into sValue
   --
   put the mouse_Up of me into mUpCommand
   if mUpCommand is empty then
      put sValue
      pass actionInspect
   else
      put the long id of me into treeView
      put the click_Controller of me into mTarget
      dispatch mUpCommand to mTarget with treeView,sValue
   end if
end actionInspect

on hiliteChanged
   -- hack - cant stop the flicker when selecting line that is already selected
   -- called twice due to "set the hilitedElement"
   -- lock messages makes no difference
   if LocalArray ["just set hilitedElement"] is true then
      put false into LocalArray ["just set hilitedElement"]
      return empty
   end if
   
   put _treeWidget() into treeWidget
   put the hilitedElement of treeWidget into pathItems
   if pathItems is empty then
      put LocalArray ["previousHilitedElement"] into pathItems
      set the hilitedElement of treeWidget to pathItems
      put true into LocalArray ["just set hilitedElement"]
   else
      put pathItems into LocalArray ["previousHilitedElement"]
      put false into LocalArray ["just set hilitedElement"]
   end if
   
   if the controlKey is "Down" then
      put the line_Menu of me into mTitle
      put the menu_Button of me into mButton
      mArray_PopUp mTitle, mButton
   else
      -- _displaySelectedValue treeWidget
      put the selected_Value of treeWidget into selectedValue
      dispatch "tree_HilightChanged" to me with selectedValue
   end if
end hiliteChanged


--> Props
-
getprop chars_ToTrim
   put the charsToTrimFromKey of _treeWidget() into padNum
   return padNum
end chars_ToTrim

setprop chars_ToTrim padNum
   put _TreeWidget() into treeWidget
   set the charsToTrimFromKey of treeWidget to padNum
   return treeWidget
end chars_ToTrim

getprop trim_Num
   get the charsToTrimFromKey of _treeWidget()
   return it
end trim_Num

setprop trim_Num sNum
   set the charsToTrimFromKey of _treeWidget() to sNum
end trim_Num

getprop max_LineNum
   put the displayed_Index of me into dLines
   return the number of lines of dLines
end max_LineNum


--> Expanded
-
getprop expanded_Paths
   put the foldState of _treeWidget() into foldedArray
   repeat for each key someKey in foldedArray
      if foldedArray [someKey]["folded"] is false then
         put someKey & comma after ePaths
      end if 
   end repeat
   delete char -1 of ePaths
   return ePaths
end expanded_Paths

setprop expanded_Paths [pAddState] ePaths
   put display_ConstructFoldState (ePaths) into fArray
   --
   repeat for each item someKey in ePaths
      put false into fArray [someKey]["folded"]
   end repeat
   --
   set the fold_State [pAddState] of me to fArray
   return fArray
end expanded_Paths

getprop fold_State
   put the foldState of _treeWidget() into foldedArray
   return foldedArray 
end fold_State

setprop fold_State [pAddState] foldedArray
   -- sensitive to capitalisation
   put _treeWidget() into tWidget
   --
   if pAddState is true then
      get the foldState of tWidget
      union foldedArray with it
   end if
   --
   -- put the autoFoldStateReset of tWidget
   set the foldState of tWidget to foldedArray
   return the result
end fold_State


--> Props | Show
=
getprop show_Separator
   put _treeWidget() into treeWidget
   return the showSeparator of treeWidget
end show_Separator

setprop show_Separator sBoolean
   put _treeWidget() into treeWidget
   set the showSeparator of treeWidget to sBoolean
   return treeWidget
end show_Separator

getprop show_Values
   put _treeWidget() into treeWidget
   return the showValues of treeWidget
end show_Values

setprop show_Values sBoolean
   put _treeWidget() into treeWidget
   set the showValues of treeWidget to sBoolean
   return treeWidget
end show_Values

getprop show_Numbers
   put _treeWidget() into treeWidget
   put the charsToTrimFromKey of treeWidget into sNum
   return sNum = 0
end show_Numbers

setprop show_Numbers sBoolean
   put _treeWidget() into treeWidget
   
   lock screen
   if sBoolean is true then
      set the charsToTrimFromKey of treeWidget to 0
      set the separatorRatio of treeWidget to 0.3
   else
      set the charsToTrimFromKey of treeWidget to 2
      set the separatorRatio of treeWidget to 0
   end if
   unlock screen
end show_Numbers


--> Props | Tree
-
getprop tree_IsIndex
   return LocalArray ["isIndex"] is true
end tree_IsIndex

getprop tree_SortType
   put _treeWidget() into treeWidget
   put the sortType of treeWidget into treeSortType
   return treeSortType
end tree_SortType

setprop tree_SortType treeSortType
   put _treeWidget() into treeWidget
   set the sortType of treeWidget to treeSortType
   return treeWidget
end tree_SortType

getprop tree_SortTypes
   return "text,numeric"
end tree_SortTypes


--> Props | Top
-
setprop deleted_Path somePath
   tree_DeletePath somePath
end deleted_Path

setprop deleted_Line somePath
   tree_DeletePath somePath
end deleted_Line


--> Props | Hilited
-
getprop hilited_Element
   return the selected_Path of me
end hilited_Element

setprop hilited_Element commaPath
   set the selected_Path of me to commaPath
end hilited_Element

getprop hilited_Line
   return the selected_LineNum of me
end hilited_Line

setprop hilited_Line lineNum
   set the hilited_Element of me to lineNum
end hilited_Line


--> Selected
-
getprop selected_TopData [sPath]
   -- returns the topKey and not just the contents of the array
   if sPath is empty then
      _SetTop topKey, aData
      put aData [topKey] into topData [topKey]
   else
      put the arrayData of _TreeWidget() into aData
      split sPath with comma
      put aData [sPath] into topData
   end if
   return topData
end selected_TopData

getprop selected_LineNumber
   return the selected_LineNum of me
end selected_LineNumber

setprop selected_LineNumber lineNum
   set the selected_LineNum of me to lineNum
end selected_LineNumber

getprop selected_LineNum
   -- just top-level lines and assume
   put the selected_Line of me into topLine
   
   set the wholematches to true
   put _SortedTopKeys() into topKeys
   put lineoffset (topLine, topKeys) into topLineNum
   
   return topLineNum
end selected_LineNum

setprop selected_LineNum textOrNumber
   if textOrNumber is a number then
      breakpoint -- fix: not sure how to handle this
   end if
   set the hilited_Element of me to lineNum
end selected_LineNum

getprop selected_Array
   put _treeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   return selectedValue
end selected_Array

getprop selected_Path
   put _treeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   if char -1 of commaPath is comma then delete char -1 of commaPath
   return commaPath
end selected_Path

setprop selected_Path commaPath
   put _treeWidget() into treeWidget
   set the hilitedElement of treeWidget to commaPath
   return treeWidget
end selected_Path

getprop selected_Line
   put _treeWidget() into treeWidget
   --
   put the hilitedElement of treeWidget into commaPath
   put the pathDelimiter of treeWidget into pDelim
   --
   set the itemdelimiter to pDelim
   put item -1 of commaPath into sLine
   return sLine
end selected_Line

setprop selected_Line commaPath
   put _treeWidget() into treeWidget
   set the scrollHilitedElementIntoView of treeWidget to true
   set the hilitedElement of treeWidget to commaPath
   --
   put item 1 of commaPath into topLine
   set the wholematches to true
   put _SortedTopKeys() into topKeys
   put lineoffset (topLine, topKeys) into topLineNum
   --
   return topLineNum -- only works for top lines
end selected_Line

getprop selected_Value
   put _treeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   put item -1 of commaKeys into lastComma
   
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   if selectedValue is empty then
      return lastComma
   else
      return selectedValue
   end if
end selected_Value


--> Props | Selected
-
getprop top_Key
   return _GetTopKey()
end top_Key

getprop top_Line [pathItemNum]
   put _treeWidget() into treeWidget
   if pathItemNum is empty then put 1 into pathItemNum
   --
   put the hilitedElement of treeWidget into commaPath
   put item pathItemNum of commaPath into topLine
   return topLine
end top_Line

getprop top_Lines
   put _treeWidget() into treeWidget
   --
   put the arrayData of treeWidget into someData
   --
   put keys (someData) into topLines
   if the sortType of treeWidget is "text" then
      if the sortOrder of treeWidget is "ascending" then
         sort ascending lines of topLines
      else
         sort descending lines of topLines
      end if
   else
      sort numeric lines of topLines
   end if
   return topLines
end top_Lines

getprop top_LineKeys
   -- sorts alphabetically the keys
   -- assumes the display does the same?
   
   put the top_Data of me into topArray
   put the keys of topArray into topKeys
   sort topKeys
   return topKeys
end top_LineKeys

getprop top_Data [pathNum]
   -- put the selected_TopData of me into topData
   put _treeWidget() into treeWidget
   --
   put the arrayData of treeWidget into aData
   put the hilitedElement of treeWidget into commaPath
   if pathNum is a number then
      -- subtract 1 from pathNum
      put item 1 to pathNum of commaPath into topPath
      split topPath with comma
      put aData [topPath] into topData
   else
      put item 1 of commaPath into topKey
      put aData [topKey] into topData [topKey]
   end if
   return topData
end top_Data

getprop top_Array [pKey]
   -- selected_TopArray
   _SetTop topKey, aData
   if pKey is empty then
      return aData [topKey]
   else
      return aData [topKey][pKey]
   end if
end top_Array

setprop top_Array [pPath] sArray
   put _GetTopKey() into topKey
   tree_SetArray sArray, topKey
   --
   put the result into arrayData
   return arrayData
end top_Array

setprop tree_Array [pPath] sArray
   tree_SetArray sArray, pPath
   --
   put the result into arrayData
   return arrayData
end tree_Array


--> Props | Parent
-
getprop parent_Array [someKey]
   put _treeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   if the number of items of commaKeys = 1 then
      return the displayed_Array of me
   end if
   --
   delete item -1 of commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into pArray
   --
   if someKey is empty then
      return pArray
   else
      return pArray [someKey]
   end if
end parent_Array


--> Model
-
getprop displayed_Data
   if LocalArray ["isIndex"] is true then
      return the displayed_Index of me
   else
      put the arrayData of _treeWidget() into treeData
      return treeData
   end if
end displayed_Data

setprop displayed_Data [someTitle] sData
   lock screen
   if sData is an array then
      set the arrayData of _treeWidget() to sData
      set the show_Values of me to true
      set the show_Numbers of me to true
      put false into LocalArray ["isIndex"]
      --
      if someTitle is not empty then
         set the title_Text of me to someTitle
      end if
   else
      set the displayed_Index [someTitle] of me to sData
   end if
   unlock screen
end displayed_Data

setprop displayed_Index [someTitle] someIndex
   lock screen
   -- unsorts someIndex
   repeat for each line someLine in someIndex
      put empty into someArray [someLine]
   end repeat
   --
   set the arrayData of _treeWidget() to someArray
   set the show_Values of me to false
   set the show_Numbers of me to true
   --
   if someTitle is not empty then
      -- set the stack_Title of me to someTitle
      set the title_Text of me to someTitle
   end if
   unlock screen
   put true into LocalArray ["isIndex"]
end displayed_Index

getprop displayed_Index
   put the arrayData of _treeWidget() into someArray
   put keys (someArray) into someIndex
   sort lines of someIndex
   return someIndex
end displayed_Index

getprop displayed_Array [pathItems]
   -- compatibility with old treeView
   put the displayed_Data of me into someArray
   if pathItems is empty then return someArray
   
   split pathItems with comma
   put someArray [pathItems] into someValue
   return someValue
end displayed_Array

setprop displayed_Array [someTitle] someArray
   -- compatibility with old treeView
   set the displayed_Data [someTitle] of me to someArray
end displayed_Array


--> ViewData | Model
-
getprop view_Data [someKey]
   -- put LocalArray ["view_Data"] into viewData
   put the view_Data of me into viewData
   if someKey is empty then return viewData
   return viewData [someKey]
end view_Data

setprop view_Data [someKey] someData   
   if someKey is empty then
      set the view_Data of me to someData
   else
      put the view_Data of me into viewData
      put someData into viewData [someKey]
      set the view_Data of me to viewData
   end if
end view_Data


--> Model | ArrayIndex
-
getprop index_Array
   put the view_Data of me into indexArray
   return indexArray
end index_Array

setprop index_Array [pIndexKey] indexArray
   put indexArray_List (indexArray, pIndexKey) into sLines
   -- 
   set the displayed_Index of me to sLines
   set the view_Data of me to indexArray
   --
   return sLines
end index_Array


--> Private
-
private function _GetTopKey
   put _treeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   put item 1 of commaPath into topKey
   return topKey
end _GetTopKey

private command _SetTop @topKey, @aData
   put _treeWidget() into treeWidget
   put the arrayData of treeWidget into aData
   put the hilitedElement of treeWidget into commaPath
   --
   put item 1 of commaPath into topKey
   return commaPath
end _SetTop

private command tree_DeletePath somePath
   put _treeWidget() into treeWidget
   --
   put the arrayData of treeWidget into treeData
   treeData_Delete treeData, somePath
   put the result into deletedData
   set the arrayData of treeWidget to treeData
   --
   return deletedData
end tree_DeletePath


--> TreeData
-
private command treeData_Delete @treeData, somePath
   split somePath by comma
   put treeData [somePath] into deletedData
   delete variable treeData [somePath]
   return deletedData
end treeData_Delete

function _SortedTopKeys
   put the displayed_Data of me into myData
   put keys (myData) into topKeys
   
   put _treeWidget() into treeWidget
   put the sortOrder of treeWidget into sOrder
   put the sortType of treeWidget into sType
   
   switch sType
      case "numeric"
         if sOrder = "ascending" then
            sort numeric ascending topKeys
         else
            sort numeric descending topKeys
         end if
         break
      default
         if sOrder = "ascending" then
            sort ascending topKeys
         else
            sort descending topKeys
         end if
   end switch
   return topKeys
end _SortedTopKeys
