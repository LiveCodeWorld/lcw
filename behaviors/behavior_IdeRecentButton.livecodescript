script "behavior_IdeRecentButton"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_IdeRecentButton
type: behavior

/*
This behavior alters the menu of the Livecode History Button menu in the revScriptEditor.
*/

--> Variables
-

--> Events
-
on mouseDown pMenuButton
   if the optionKey is "down" then pass mouseDown
   --
   switch pMenuButton
      case 3
         pass mouseDown
      default         
         put ide_GetMenuTitle ("Recent") into mTitle
         menu_GlobalPopUp mTitle
   end switch
end mouseDown

getprop menu_Target
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target

on dragEnter
   set the dragAction to "link"
   pass dragEnter
end dragEnter

on dragDrop
   put the dragData into dData
   put the dragData ["text"] into droppedURL
   --
   set the itemdelimiter to slash
   put item -2 of droppedURL into lastWikiDomain
   get item -1 of droppedURL
   set the itemdelimiter to "."
   put item 1 of it into pSlug
   --
   put "handler." & platform_LivecodeDomain() into handlerDomain
   switch
      case lastWikiDomain = handlerDomain and droppedURL ends with ".json"
      case lastWikiDomain = handlerDomain and droppedURL ends with ".html"
         put fedwiki_FetchHandlerMetadata (lastWikiDomain, pSlug) into metaArray
         handler_DeconstructMetaData metaArray, hName, hType, hObject, isChecked
         put the result into hKey
         --
         hkey_Edit hKey
         break
      case lastWikiDomain = handlerDomain
         put fedwiki_FetchHandlerMetadata (lastWikiDomain, pSlug)
         handler_DeconstructMetaData metaArray, hName, hType, hObject, isChecked
         put the result into hKey
         --
         hkey_Edit hKey
         break
      default
         put the keys of the dragData into droppedKeys
         put droppedKeys & CR & droppedURL & CR & the dragData ["image"]
         --
         display_Data dData, "dragData"
   end switch
end dragDrop

command handler_DeconstructMetaData metaArray, @hName, @hType, @hObject, @isChecked
   put metaArray ["Checked"] into isChecked
   --
   put metaArray ["Name"] into hName
   put metaArray ["Type"] into hType
   put metaArray ["Where"] into hObject
   --
   put hkey_Construct (hName, hType, hObject) into hKey
   return hKey
end handler_DeconstructMetaData

function fedwiki_FetchHandlerMetadata wikiDomain, pSlug
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   --
   put pageArray ["title"] into hName
   put pageArray_GetItemText (pageArray, "da8cf69872f38050") into metaArray
   split metaArray with CR and ": "
   --
   put hName into metaArray ["Name"]
   --
   return metaArray
end fedwiki_FetchHandlerMetadata

function fedwiki_GetLastLineupDomain someURL
   set the itemdelimiter to slash
   repeat with itemNum = the number of items of someURL down to 1
      -- put -1 * itemNum into 
   end repeat
end fedwiki_GetLastLineupDomain
