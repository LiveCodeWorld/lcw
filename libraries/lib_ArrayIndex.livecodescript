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
command display_IndexArray indexArray, pTitle, pStackLabel, pOrdered, pNameKey, pDisplayView
   -- see lib_ArrayIndex
   if pOrdered is true then
      put indexArray_GetNumbered (indexArray, pNameKey) into nArray
      display_Data nArray, pTitle, pStackLabel, pDisplayView
      put the result into displayView
      set the show_Numbers of displayView to false
      set the show_Separator of displayView to true
   else
      put indexArray_Names (indexArray, pNameKey) into sLines
      display_Data sLines, pTitle, pStackLabel, pDisplayView
      put the result into displayView
   end if
   --
   set the view_Data of displayView to indexArray
   return displayView
end display_IndexArray


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

function indexArray_GetNumbered indexArray, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pNameKey] into numArray [indexNum]
   end repeat
   return numArray
end indexArray_GetNumbered

function indexArray_Names indexArray, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pNameKey] into sLine
      put sLine & CR after sLines
   end repeat
   delete char -1 of sLines
   return sLines
end indexArray_Names

command indexArray_Add newLines, someKey, @someArray
   -- if the number of lines of keys(someArray) > 5 and someKey contains "form_IsRed" then breakpoint
   put someArray [someKey] into someIndex
   line_AddToIndex newLines, someIndex
   put word 1 to -1 of someIndex into someArray [someKey]
   return the number of lines of someIndex
end indexArray_Add


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
