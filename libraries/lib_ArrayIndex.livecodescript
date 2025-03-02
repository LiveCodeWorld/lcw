script "lib_ArrayIndex"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ArrayIndex
type: library
version: 0.1

/*Some help*/


--> Working on
-

--> Display
-
command display_IndexArray indexArray, pTitle, pStackLabel, pOrdered, pNameKey, pPadNum, pDisplayView
   switch
      case pOrdered is true
         put indexArray_GetNumbered (indexArray, pNameKey) into nArray
         display_Data nArray, pTitle, pStackLabel, pDisplayView
         put the result into dView
         --
         set the show_Numbers of dView to false
         set the show_Separator of dView to true
         break
      case pPadNum is a number
         put indexArray_ConstructNameArray (indexArray, pNameKey, pPadNum) into nameArray
         --
         if exists (pDisplayView) then
            put pDisplayView into dView
            --
            set the displayed_Data [pTitle] of dView to nameArray
            set the chars_ToTrim of dView to pPadNum
            set the tree_SortType of dView to "numeric"
            --
            if pStackLabel is not empty then
               put the stack_Name of dView into stackName
               set the label of stack stackName to pStackLabel
            end if
         else
            display_CloneInvisible pTitle, pStackLabel
            put the result into dView
            --
            set the tree_SortType of dView to "numeric"
            set the displayed_Data of dView to nameArray
            set the chars_ToTrim of dView to pPadNum
            
            put the stack_Name of dView into stackName
            -- stack_SetStyle stackName, pPalette
            -- stack_Position stackName, pLocOrRect
            show stack stackName
         end if
         break
      default
         # Ordered Index
         put indexArray_List (indexArray, pNameKey) into sLines
         display_Data sLines, pTitle, pStackLabel, pDisplayView
         put the result into dView
         
         # Utility Dictionary
         put indexArray_ConstructNameArray (indexArray, pNameKey) into nameArray
         set the displayed_Data [pTitle] of dView to nameArray
   end switch
   --
   set the view_Data of dView to indexArray
   return dView
end display_IndexArray


--> IndexArray | Transform
-
function indexArray_FilterWithout indexArray, sKey, sValue
   put 1 into newItemNum
   repeat with itemNum = 1 to item 2 of the extents of indexArray
      put indexArray [itemNum] into itemArray
      if itemArray [sKey] = sValue then
         put itemArray into filterArray [newItemNum]
         add 1 to newItemNum
      end if
   end repeat
   return filterArray
end indexArray_FilterWithout

function indexArray_ToJson indexArray
   local jsonBit
   repeat with itemNum = 1 to item 2 of the extents of indexArray
      put indexArray [itemNum] into itemArray
      put JSONExport (itemArray) into itemJSON
      put itemJSON & comma & CR after jsonBit
   end repeat
   delete char -2 to -1 of jsonBit
   return jsonBit
end indexArray_ToJson

function indexArray_ConstructNameArray indexArray, pNameKey, pPadNum
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum] into itemArray
      put itemArray [pNameKey] into sNameValue
      --
      if pPadNum is a number then
         number_PadLeft indexNum, pPadNum
         put indexNum && sNameValue into sTitle
      else
         put sNameValue into sTitle
      end if
      --
      put itemArray into nameArray [sTitle]
   end repeat
   return nameArray
end indexArray_ConstructNameArray

function indexArray_GetNumbered indexArray, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pNameKey] into numArray [indexNum]
   end repeat
   return numArray
end indexArray_GetNumbered


--> IndexArray
-
function indexArray_GetNamed indexArray, sName, sKey, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   --
   put indexArray_Find (indexArray, pNameKey, sName) into indexNum
   put indexArray [indexNum][sKey] into sValue
   --
   return sValue
end indexArray_GetNamed

command indexArray_SetNamed @indexArray, sName, sKey, sValue, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   --
   put indexArray_Find (indexArray, pNameKey, sName) into indexNum
   put sValue into indexArray [indexNum][sKey]
   --
   return indexNum
end indexArray_SetNamed

function indexArray_List indexArray, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pNameKey] into sLine
      put sLine & CR after sLines
   end repeat
   delete char -1 of sLines
   return sLines
end indexArray_List

command indexArray_Add newLines, someKey, @someArray
   -- if the number of lines of keys(someArray) > 5 and someKey contains "form_IsRed" then breakpoint
   put someArray [someKey] into someIndex
   line_AddToIndex newLines, someIndex
   put word 1 to -1 of someIndex into someArray [someKey]
   return the number of lines of someIndex
end indexArray_Add

command indexArray_AddIndexArray @indexArray, otherIndexArray
   put item 2 of the extents of indexArray into maxItem
   repeat with indexNum = 1 to item 2 of the extents of otherIndexArray
      add 1 to maxItem
      put otherIndexArray [indexNum] into indexArray [maxItem]
   end repeat
   return indexArray
end indexArray_AddIndexArray

--> Array | Index
-
command indexArray_Move @sArray, fromNum, toNum
   put sArray [fromNum] into itemArray
   indexArray_Delete sArray, fromNum
   indexArray_Insert sArray, toNum, itemArray
   return itemArray
end indexArray_Move

command indexArray_Insert @sArray, intoNum, itemArray
   put item 2 of the extents of sArray into maxItem
   
   -- move items below intoNum down 1
   repeat with itemNumToMove = maxItem down to intoNum
      put itemNumToMove + 1 into itemNumDestination
      put sArray [itemNumToMove] into sArray [itemNumDestination]
   end repeat
   
   -- now insert itemArray into item intoNum of storyArray
   put itemArray into sArray [intoNum]
end indexArray_Insert

function indexArray_FindArray sArray, sKey, sValue
   repeat with itemNum = 1 to item 2 of the extents of sArray
      put sArray [itemNum][sKey] into foundKey
      if foundKey = sValue then
         return sArray [itemNum]
      end if
   end repeat
   return empty
end indexArray_FindArray

function indexArray_FindContains sArray, sKey, sValue
   repeat with itemNum = 1 to item 2 of the extents of sArray
      put sArray [itemNum][sKey] into foundKey
      if foundKey contains sValue then
         return itemNum
      end if
   end repeat
   return 0
end indexArray_FindContains

function indexArray_FindEndsWith sArray, sKey, sValue
   repeat with itemNum = 1 to item 2 of the extents of sArray
      put sArray [itemNum][sKey] into foundKey
      if foundKey ends with sValue then
         return itemNum
      end if
   end repeat
   return 0
end indexArray_FindEndsWith

function indexArray_Find sArray, sKey, sValue
   repeat with itemNum = 1 to item 2 of the extents of sArray
      put sArray [itemNum][sKey] into foundKey
      if foundKey = sValue then
         return itemNum
      end if
   end repeat
   return 0
end indexArray_Find

command indexArray_Delete @sArray, itemNumToDelete
   put sArray [ItemNumToDelete] into deletedItemArray
   put item 2 of the extents of sArray into maxItem
   if maxItem is not a number then return empty
   repeat with itemNumToMove = (itemNumToDelete + 1) to maxItem
      put itemNumToMove - 1 into itemNumDestination
      put sArray [itemNumToMove] into sArray [itemNumDestination]
   end repeat
   delete variable sArray [maxItem]
   return deletedItemArray
end indexArray_Delete

command indexArray_AddToEnd @sArray, itemArray
   put item 2 of the extents of sArray into maxItem
   add 1 to maxItem
   put itemArray into sArray [maxItem]
   return maxItem
end indexArray_AddToEnd
