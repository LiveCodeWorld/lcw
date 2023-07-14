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
function indexArray_GetNumbered indexArray, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pNameKey] into numArray [indexNum]
   end repeat
   return numArray
end indexArray_GetNumbered

function indexArray_Names indexArray, pIndexKey
   if pIndexKey is empty then put "name" into pIndexKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pIndexKey] into sLine
      put sLine & CR after sLines
   end repeat
   delete char -1 of sLines
   return sLines
end indexArray_Names

command array_AddToIndex newLines, someKey, @someArray
   -- if the number of lines of keys(someArray) > 5 and someKey contains "form_IsRed" then breakpoint
   put someArray [someKey] into someIndex
   line_AddToIndex newLines, someIndex
   put word 1 to -1 of someIndex into someArray [someKey]
   return the number of lines of someIndex
end array_AddToIndex


--> Array | Index
-
command array_IndexMove @sArray, fromNum, toNum
   put sArray [fromNum] into itemArray
   array_IndexDelete sArray, fromNum
   array_IndexInsert sArray, toNum, itemArray
   return itemArray
end array_IndexMove

command array_IndexInsert @sArray, intoNum, itemArray
   put item 2 of the extents of sArray into maxItem
   
   -- move items below intoNum down 1
   repeat with itemNumToMove = maxItem down to intoNum
      put itemNumToMove + 1 into itemNumDestination
      put sArray [itemNumToMove] into sArray [itemNumDestination]
   end repeat
   
   -- now insert itemArray into item intoNum of storyArray
   put itemArray into sArray [intoNum]
end array_IndexInsert

function array_IndexFind sArray, sKey, sValue
   repeat with itemNum = 1 to item 2 of the extents of sArray
      put sArray [itemNum][sKey] into foundKey
      if foundKey = sValue then
         return itemNum
      end if
   end repeat
   return 0
end array_IndexFind

command array_IndexDelete @sArray, itemNumToDelete
   put sArray [ItemNumToDelete] into deletedItemArray
   put item 2 of the extents of sArray into maxItem
   if maxItem is not a number then return empty
   repeat with itemNumToMove = (itemNumToDelete + 1) to maxItem
      put itemNumToMove - 1 into itemNumDestination
      put sArray [itemNumToMove] into sArray [itemNumDestination]
   end repeat
   delete variable sArray [maxItem]
   return deletedItemArray
end array_IndexDelete

command array_IndexAddToEnd @sArray, itemArray
   put item 2 of the extents of sArray into maxItem
   add 1 to maxItem
   put itemArray into sArray [maxItem]
   return maxItem
end array_IndexAddToEnd


