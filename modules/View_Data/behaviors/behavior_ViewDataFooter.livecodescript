script "behavior_ViewDataFooter"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewDataFooter
type: behavior
version: 0.1


--> Working on
-
getprop footer_Title
   put the uOPN ["menu_Title"] of me into mTitle
   return mTitle
end footer_Title

setprop footer_Title mTitle
   if exists (stack mTitle) is false then
      return "Error, controller stack does not exists:" && mTitle
   end if
   --
   put the menu_IconArray of stack mTitle into mIconArray
   get mIconArray [1]["icon_name"]
   if it is empty then
      put "text" into sStyle
   else
      put "icons" into sStyle
   end if
   set the footer_Data [sStyle] of me to mIconArray -- not working with arrays
   --  
   set the uOPN ["menu_title"] of me to mTitle
   return mItemArray
end footer_Title

private command _DoFooter
   put the long id of me into fWidget
   put the line_Controller of me into mController
   if exists (mController) is false then
      put the title_Controller of me into mController
   end if
   
   # Get Hilite info
   put the hilitedItem of fWidget into iNum
   put the hilitedItemName of fWidget into iName
   --
   put the footer_ItemHkey [iNum] of me into hkey
   
   switch
      case the controlKey is "down"
         put the menu_Button of me into mButton
         menu_PopUp "Global | Data | Footer | Menu", mButton
         break
      case hKey is empty
         # Dispatch (line_Controller is default)
         dispatch "footer_HiliteChange" to mController with fWidget,iName,iNum
         if it is "unhandled" then
            breakpoint
            edit the script of mController
         end if
         break
      default
         hKey_Do hKey, fWidget
   end switch
end _DoFooter

private function _ItemNum numOrName
   if numOrName is a number then
      return numOrName
   else
      put the itemNames of me into iNames -- polylist 2,index,tree
      set the wholematches to true
      put itemOffset (numOrName, iNames) into iNum
      return iNum
   end if
end _ItemNum


--> Props
-
getprop footer_ItemLabel [nameOrNum]
   put _ItemNum (nameOrNum) into iNum
   --
   put the itemLabels of me into iLabels
   return item iNum of iLabels
end footer_ItemLabel

setprop footer_ItemLabel [nameOrNum] sLabel
   put _ItemNum (nameOrNum) into iNum
   --
   put the itemLabels of me into iLabels
   put sLabel into item iNum of iLabels
   set the itemLabels of me to iLabels
   return iLabels
end footer_ItemLabel

getprop footer_ItemLabels
   put the footer_View of me into footerView
   return the itemLabels of footerView
end footer_ItemLabels

setprop footer_ItemLabels [pStyle] iLabels
   put the footer_View of me into footerView
   --
   lock screen
   set the itemLabels of footerView to iLabels
   if pStyle is not empty then
      set the itemStyle of footerView to pStyle
   end if
   unlock screen
end footer_ItemLabels

getprop footer_ItemName [nameOrNum]
   put _ItemNum (nameOrNum) into iNum
   --
   put the itemNames of me into iNames
   return item iNum of iNames
end footer_ItemName

setprop footer_ItemName [nameOrNum] sName
   put _ItemNum (nameOrNum) into iNum
   --
   put the itemNames of me into iNames
   put sName into item iNum of iNames
   set the itemNames of me to iNames
   return iNames
end footer_ItemName

getprop footer_ItemIcon [nameOrNum]
   put _ItemNum (nameOrNum) into iNum
   --
   put the itemIcons of me into newItems
   return item iNum of newItems
end footer_ItemIcon

setprop footer_ItemIcon [nameOrNum] sIconName
   put _ItemNum (nameOrNum) into iNum
   --
   put the itemIcons of me into newItems
   put sIconName into item iNum of newItems
   set the itemIcons of me to newItems
   return newItems
end footer_ItemIcon

getprop footer_ItemHkey [nameOrNum]
   put _ItemNum (nameOrNum) into iNum
   --
   put the footer_Data of me into mItemArray
   put mItemArray [iNum]["hkey"] into hkey
   return hKey
end footer_ItemHkey

setprop footer_ItemHkey [nameOrNum] hKey
   put _ItemNum (nameOrNum) into iNum
   --
   put the footer_Data of me into fData
   put hkey into fData [iNum]["hkey"]
   -- set the footer_Data of me to mItemArray
   set the uOPN ["menu_ItemArray"] of me to fData
   
   return mItemArray
end footer_ItemHkey

getprop footer_ItemArray
   put the footer_View of me into footerView
   return the itemArray of footerView
end footer_ItemArray

setprop footer_ItemArray [pStyle] iArray
   -- bug: don't use "itemArray" for array name
   put the footer_View of me into footerView
   --
   lock screen
   set the itemArray of footerView to iArray
   if pStyle is not empty then
      set the itemStyle of footerView to pStyle
   end if
   unlock screen
end footer_ItemArray

getprop footer_Data
   put the uOPN ["menu_ItemArray"] of me into fData
   return fData
end footer_Data

setprop footer_Data [pStyle] fData
   put the footer_View of me into footerView
   set the uOPN ["menu_ItemArray"] of me to fData
   
   lock screen
   -- set the itemArray of footerView to fData -- bug
   -- set the footer_ItemArray [pStyle] of me to fData -- bug
   set the itemArray of me to empty
   --
   set the itemNames of me to _List (fData, "name")
   set the itemLabels of me to _List (fData, "label")
   set the itemIcons of me to _List (fData, "icon_name") 
   
   if pStyle is not empty then
      set the itemStyle of footerView to pStyle
   end if
   unlock screen
end footer_Data


--> Events
-
on hiliteChanged
   _DoFooter
end hiliteChanged


--> Deps
-
command hKey_Do hKey, pTarget, pValue
   if the optionKey is "Down" then
      _AskEdit hKey
      return empty
   end if
   
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   if exists (hObject) is false then
      return "Error, cannot find hObject:" && hKey
   end if
   
   put hName && "pTarget,pValue" into callCommand
   call callCommand of hObject
   return the result
end hKey_Do


--> Provate
-
private function _List mIconArray, kName
   repeat with iNum = 1 to item 2 of the extents of mIconArray
      put mIconArray [iNum][kName] & comma after listItems
   end repeat
   delete char -1 of listItems
   return listItems
end _List

private command _AskEdit hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put merge ("Edit script of the handler '[[hName]]'?") into sQuestion
   --
   put scriptEditor_GetTop() into stackObject
   lcw_Answer sQuestion, stackObject, hKey
   --
   hkey_Edit hKey
end _AskEdit

