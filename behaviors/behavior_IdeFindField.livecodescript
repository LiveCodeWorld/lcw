script "behavior_IdeFindField"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_IdeFindField
type: behavior


--> Events
-
on returnInField
   put the text of me into searchText
   put the number of items of searchText into numItems
   put item 2 of searchText is among the items of "c,f,g,s,m,pc,pf,pg,ps,pm" into isType
   
   switch
      case numItems = 1
         pass returnInField
      case numItems = 2 and isType is true 
         put hkey_Search (searchText) into foundHkey
         if foundHkey is empty then pass returnInField
         hkey_Edit foundHkey
         break
      case 4 and isType is true
         hkey_Edit searchText
         break
      default
         set the cursor to watch
         put hArray_ListShortKeys (searchText) into hKeys
         
         if the shiftkey is "Up" then
            put scriptEditor_Object() into scriptObject
            put rev_FormatHkeySearchResult (hKeys, scriptObject, searchText) into tFormattedResults
            rev_SetScriptEditorSearchResults tFormattedResults
         else
            display_HkeyIndex hKeys
         end if
   end switch
end returnInField
