script "model_HandlerLibrary"
--> MetaData
-
license: GPLv3
name: model_HandlerLibrary
type: model
version: 0.6


--> Handler Library | Props
-
getprop handler_Help [shortHkey]
   put item 1 to 2 of shortHkey into hKey
   put the rugged_ID of the target into item 3 of hKey
   put 1 into item 4 of hKey
   return project_FetchHandlerHelp (hKey)
end handler_Help

setprop handler_Help [shortHkey] helpHtml
   put the rugged_ID of the target into rObject
   
   put item 1 to 2 of shortHkey into hKey
   put rObject into item 3 of hKey
   put 1 into item 4 of hKey
   
   put the script_Hkeys of rObject into availableHkeys
   set the wholematches to true
   if hKey is not among the lines of availableHkeys then return empty
   
   project_StoreHandlerHelp hKey, helpHtml
   put the result into helpFile
   return helpFile
end handler_Help


--> Handler Library | Help | Model
-
function library_FetchHandlerHelp shortHkey
   -- should not create a folder if there is no help
   put library_HandlerFile (shortHkey, "help.html", true) into someFile
   if someFile is empty then return empty
   put url ("binfile:" & someFile) into someHelp
   hack_UpdateBinFile someHelp, someFile -- hack for old binary file endings?
   return someHelp
end library_FetchHandlerHelp

command library_StoreHandlerHelp shortHkey, someHelp, pAskSave
   put library_HandlerFile (shortHkey, "help.html", false) into someFile
   put url ("binfile:" & someFile) into oldHelp
   if oldHelp = "<p></p>" then put empty into oldHelp
   if word 1 to -1 of oldHelp = word 1 to -1 of someHelp then return empty
   
   if oldHelp = someHelp then
      return empty
   end if
   
   if pAskSave is not false then
      -- opn_Notify someHelp
      put merge ("Are you sure you want to save the new help for [[shortHkey]]?") into someQuestion
      answer someQuestion with "Cancel" or "OK"
      if it is "Cancel" then return empty
   end if
   
   if someHelp is empty or someHelp is "<p></p>" then
      delete file someFile
      return empty
   else
      put someHelp into url ("binfile:" & someFile)
      return someFile
   end if
end library_StoreHandlerHelp


--> Handler Library | Model
-
command library_AddHkey hKey, pHandler, pForceAdd
   if pHandler is empty then
      put hkey_ExtractHandlerFromObject (hKey) into pHandler
   end if
   if word 1 of pHandler = "private" then delete word 1 of pHandler
   put library_FetchHandler (hKey) into libraryHandler
   
   put libraryHandler = pHandler into isExported
   if (isExported is true and pForceAdd is not true) then return false
   
   put item 1 to 2 of hKey into shortHKey
   
   library_StoreHandler shortHKey, pHandler
   
   -- sure this could be much faster !
   put handler_ConstructCallArray (pHandler) into handlerMetadata
   
   put handlerMetadata ["sha1"] into handlerHash
   -- put sha1_Hash (someHandler) into handlerHash
   
   hkey_AddToKeyWordArray handlerMetadata, hKey, handlerHash
   
   put handlerMetadata ["hKeyCalls"] into hKeyCalls
   library_StoreHkeyCalls shortHKey, hKeyCalls
   
   put library_FetchHandlerDatabaseArray () into hkeyData
   put hkeyData [shortHKey] into shortHkeyArray
   union handlerMetadata with shortHkeyArray
   put handlerMetadata into hkeyData [shortHKey]
   library_StoreHandlerDatabaseArray hKeyData
   
   return shortHkeyArray -- was returning hKeyData
end library_AddHkey

command library_ExportAllHandlersFromObject scriptObject, pForceAdd
   put the script_Hkeys of scriptObject into hKeys
   library_AddHkeys hKeys, false, pForceAdd
end library_ExportAllHandlersFromObject

command library_AddHkeys hKeys, pDontNotify, pForceAdd
   repeat for each line hKey in hKeys
      set the cursor to busy
      library_AddHkey hKey, empty, pForceAdd
      if the result is false then
         put item 1 to 2 of hKey into shortHkey
         put merge ("Handler '[[shortHkey]]' was already in the handler library!") into someComment
      else
         put item 1 to 2 of hKey into shortHkey
         put merge ("Added handler '[[shortHkey]]' to the handler library!") into someComment
      end if
      if pDontNotify is not true then
         opn_Notify someComment
      end if
   end repeat   
end library_AddHkeys

function library_HkeyToPublicShortHkey hKey
   -- change private handler to public one for library
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if char 1 of hType = "p" then delete char 1 of hType
   put hName,hType into shortHKey
   return shortHKey
end library_HkeyToPublicShortHkey

function library_FetchHkeyHash hKey
   put library_FetchHandlerMetadata (hKey) into metadataArray
   put metadataArray ["sha1"] into handlerHash
   return handlerHash
end library_FetchHkeyHash

command library_DeleteHkey hKey
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   
   put library_FetchHandlerDatabaseArray () into hkeyData
   delete variable hkeyData [shortHKey]
   library_StoreHandlerDatabaseArray hkeyData
   
   hkey_DeleteFolder shortHKey
end library_DeleteHkey

function library_ListForgetHkeys
   put library_FetchForgetArray() into allwaysFilterHkeyArray
   return keys (allwaysFilterHkeyArray)
end library_ListForgetHkeys

function library_FetchForgetArray
   put library_GetHandlerDatabaseMetadata() into dbMetaData
   put dbMetaData ["allwaysFilterHkeyArray"] into allwaysFilterHkeyArray
   return allwaysFilterHkeyArray
end library_FetchForgetArray

command library_ForgetHkey hKey, someBoolean
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   put library_GetHandlerDatabaseMetadata() into dbMetaData
   if someBoolean is false then
      delete variable dbMetaData ["allwaysFilterHkeyArray"][shortHkey]
   else
      put empty into dbMetaData ["allwaysFilterHkeyArray"][shortHkey]
   end if
   library_SetHandlerDatabaseMetadata dbMetaData
end library_ForgetHkey

function library_HandlerParents shortHkey
   put library_FetchHandlerDatabaseArray() into wholeLibraryArray
   
   repeat for each key testShortHkey in wholeLibraryArray
      put wholeLibraryArray [testShortHkey]["hKeyCalls"] into hKeyCalls
      repeat for each line hKeyCall in hKeyCalls
         set the cursor to busy
         if item 1 to 2 of hKeyCall = item 1 to 2 of shortHkey then
            put testShortHkey & CR after parentHkeys
         end if
      end repeat
   end repeat
   delete char -1 of parentHkeys
   return parentHkeys
end library_HandlerParents

function library_FetchHandler shortHkey
   put library_HandlerFile (shortHkey, "script.txt", false) into someFile
   put url ("binfile:" & someFile) into someHandler
   hack_UpdateBinFile someHandler, someFile
   return someHandler
end library_FetchHandler

command library_StoreHandler shortHkey, @someHandler
   put library_HandlerFile (shortHkey, "script.txt", false) into someFile
   if someHandler is empty then
      delete file someFile
      return empty
   else
      if word 1 of someHandler = "private" then delete word 1 of someHandler
      put someHandler into url ("binfile:" & someFile)
      return someFile
   end if
end library_StoreHandler

command library_DeleteHandlerFolder shortHkey
   put library_HkeyFolder (shortHkey) into hkeyFolder
   revDeleteFolder hkeyFolder
end library_DeleteHandlerFolder

function library_FetchHandlerMetadata hKey
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   put library_FetchHandlerDatabaseArray() into hKeyData
   return hKeyData [shortHkey]
end library_FetchHandlerMetadata

command library_StoreHandlerMetadata hKey, handlerMetadata
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   put library_FetchHandlerDatabaseArray() into hKeyData
   put handlerMetadata into hKeyData [shortHkey]
   library_StoreHandlerDatabaseArray hkeyData
end library_StoreHandlerMetadata

function library_GetHandlerDatabaseMetadata
   put library_FetchHandlerDatabaseArray() into handlerDatabaseArray
   put handlerDatabaseArray ["metadata"] into dbMetaData
   return dbMetaData
end library_GetHandlerDatabaseMetadata

command library_SetHandlerDatabaseMetadata dbMetaData
   put library_FetchHandlerDatabaseArray() into handlerDatabaseArray
   put dbMetaData into handlerDatabaseArray ["metadata"]
   library_StoreHandlerDatabaseArray handlerDatabaseArray
   return handlerDatabaseArray
end library_SetHandlerDatabaseMetadata

function library_FetchHandlerDatabaseArray
   put library_FetchArray ("Hkey_Library") into handlerDatabaseArray
   return handlerDatabaseArray
end library_FetchHandlerDatabaseArray

command library_StoreHandlerDatabaseArray handlerDatabaseArray
   library_StoreArray "Hkey_Library", handlerDatabaseArray
end library_StoreHandlerDatabaseArray

function library_ListHkeys pListHow
   if char 1 of pListHow = "d" then
      put library_FetchHandlerDatabaseArray() into hKeyData
      put keys (hKeyData) into shortHkeys
      sort lines of shortHkeys by item 1 of each
   else
      return library_ListHkeysFromFolders()
   end if
   return shortHkeys
end library_ListHkeys

function library_ListHkeysFromFolders
   put the defaultfolder into oFolder
   put library_HandlerFolder() into someFolder
   set the defaultfolder to someFolder
   put the folders into shortFolders
   set the defaultfolder to oFolder
   
   set the itemdelimiter to "_"
   repeat for each line shortFolder in shortFolders
      if char 1 of shortFolder = "." then next repeat
      put item -1 of shortFolder into hType
      put item 1 to -2 of shortFolder into hName
      put hName,hType & CR after shortHkeys
   end repeat
   delete char -1 of shortHkeys
   
   return shortHkeys
end library_ListHkeysFromFolders

command library_TidyHanderDatabaseArray pDontAsk
   -- users may delelte folders manually
   -- folders may be empty, or without a hander
   -- let's remove any entries that do not have corresponding folders
   
   put library_FetchHandlerDatabaseArray() into hKeyData
   
   put the defaultfolder into oFolder
   put library_HandlerFolder() into handlersFolder
   set the defaultfolder to handlersFolder
   put the folders into shortFolders
   set the defaultfolder to oFolder
   
   set the itemdelimiter to "_"
   repeat for each line shortFolder in shortFolders
      set the cursor to busy
      if char 1 of shortFolder = "." then next repeat
      
      put item -1 of shortFolder into hType
      put item 1 to -2 of shortFolder into hName
      put hName,hType into shortHkey
      
      put handlersFolder & shortFolder into shortHkeyFolder
      put shortHkeyFolder & "/script.txt" into handlerFile
      put url ("file:" & handlerFile) into someHandler
      
      put not (hType is among the chars of "cfmgs" and the number of chars of hType = 1) into typeIsNotOK
      
      if typeIsNotOK or word 1 to -1 of someHandler is empty then -- could check it has handler in it?
         if pDontAsk is true then
            put "Deleting folder" && kwote(shortFolder) && "as it has no handler (or it's is incorrect)." into someComment
            opn_Notify someComment
            
            revDeleteFolder shortHkeyFolder
            put the result into someError
         else
            put "Folder" && kwote(shortFolder) && "has no handler (or it's is incorrect). Is it OK to delete it?" into someQuestion
            answer warning someQuestion with "No" or "OK"
            if it is not "No" then
               revDeleteFolder shortHkeyFolder
               put the result into someError
            end if
         end if
         next repeat
      end if
      
      -- OK add to new clean index  
      put hKeyData [shortHkey] into oldArray
      if oldArray is not an array then
         put "Metadata has not been indexed for" && kwote(shortFolder) && "Recreating from handler." into someComment
         opn_Notify someComment
         
         put handler_ConstructMetadataArray (shortHkey, someHandler) into handlerMetadata
         if handlerMetadata ["dontSave"] is true then next repeat
         
         put handlerMetadata ["hKeyCalls"] into hKeyCalls
         library_StoreHkeyCalls shortHkey, hKeyCalls
         
         put handlerMetadata into goodHKeyData [shortHKey]
      else
         -- let's store old metadata in goodHKeyData
         put hKeyData [shortHkey] into goodHKeyData [shortHkey]
      end if
   end repeat
   
   library_StoreHandlerDatabaseArray goodHKeyData
end library_TidyHanderDatabaseArray
