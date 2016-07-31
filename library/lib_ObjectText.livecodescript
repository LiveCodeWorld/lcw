script "lib_ObjectText"
--> MetaData
-
license: GPLv3
name: lib_ObjectText
type: library
version: 0.1


--> Props
-
getprop meta_MainStackArray [pLinkToViews]
   -- reconstruct if from maniest and folders
   local stackArray, hArray
   put the textStack_Folder [true] of the target into mainStackFolder
   if there is not a folder mainStackFolder then return empty
   put stackArray_FetchFromFolder (mainStackFolder) into mainStackArray
   return mainStackArray
end meta_MainStackArray

getprop object_MetaArray [pLinkToViews]
   -- was "mainStack_Array"
   -- Also construct hArray live as we loop through all the objects collecting info
   local hArray
   put the main_Stack of the target into mainStackObject
   put mainstack_ConstructMetaArray (mainStackObject, hArray, pLinkToViews, false) into metaArray
   return metaArray
end object_MetaArray

getprop object_PropertyText
   local objectPropArray, hArray, pExportHandlers, pDontDiff, pForceIndexHandlerCalls
   local revPropText, someScript, objectText, objectHtml, metadataArray, customArray, someImage
   object_GetPropertyArrays nestedObject, objectPropArray, hArray, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   
   object_DeconstructPropertyArray revPropertyArray, revPropText, someScript, objectText, objectHtml, customArray, someImage
   put rev_PropertyArrayToText (revPropertyArray) into revPropText
   return revPropText
end object_PropertyText

getprop object_DefaultPropArray
   put the long id of the target into someObject
   switch word 1 of someObject
      case "stack"
         reset the templateStack
         put the properties of the templateStack into defaultArray
         break
      case "card"
         reset the templateCard
         put the properties of the templateCard into defaultArray
         break
      case "group"
         reset the templateGroup
         put the properties of the templateGroup into defaultArray
         break
      case "button"
         reset the templateButton
         put the properties of the templateButton into defaultArray
         break
      case "field"
         reset the templateField
         put the properties of the templateField into defaultArray
         break
      case "graphic"
         -- see strokeradient = "none" bug
         reset the templateGraphic
         put the properties of the templateGraphic into defaultArray
         break
      case "scrollbar"
         reset the templateScrollbar
         put the properties of the templateScrollbar into defaultArray
         break
      case "player"
         reset the templatePlayer
         put the properties of the templatePlayer into defaultArray
         break
      case "image"
         reset the templateImage
         put the properties of the templateImage into defaultArray
         break
      case "videoclip"
         reset the templateVideoClip
         put the properties of the templateVideoClip into defaultArray
         break
      case "audioclip"
         reset the templateAudioClip
         put the properties of the templateAudioClip into defaultArray
         break
   end switch
   
   return defaultArray
end object_DefaultPropArray

getprop stackArray_Version
   return 1.0
end stackArray_Version

getprop stack_Array [pLinkToViews]
   put the stack_Object of the target into stackObject
   
   local stackArray, stackPropertyArray, hArray, pExportHandlers, pDontDiff, pForceIndexHandlerCalls
   stack_GetPropertArrays stackObject, stackArray, hArray, pLinkToViews, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   put the stack_Object of the target into stackObject
   return stackArray
end stack_Array

getprop stack_PropertArrays [pLinkToViews]
   local pExportHandlers, pDontDiff, pForceIndexHandlerCalls
   
   put the stack_Object of the target into stackObject
   put the stackArray_Version of me into stackArray ["manifest"]["version"]
   
   put the short name of stackObject into stackName
   put stackName into stackArray ["manifest"]["name"]
   put the mobile_Name of stackObject into stackArray ["manifest"]["object"]
   
   object_GetPropertyArrays stackObject, stackPropertyArray, hArray, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   
   put stackPropertyArray into stackArray ["objects"]["stack"]
   put the stack_RelativeFile of stackObject into stackArray ["manifest"]["filename"]
   
   set the wholematches to true
   put the cardids of stackObject into someCardIDs
   put the number of lines of someCardIDs into cardMaxNum
   repeat with cardNum = 1 to cardMaxNum
      set the cursor to busy
      put the long id of card cardNum of stackObject into cardObject
      objectArray_AddCard cardObject, stackArray, hArray, pLinkToViews, cardNum, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   end repeat
   
   -- don't now max number of duplicated background objects until end
   -- so problem with scenario of only one bg for xml reconversion comaptability of key naming
   -- as there should be a line "if maxBgNum = 1 then put "bg" into bgArrayKey
   -- have to fix at end of stack parsing
   put stackArray ["manifest"]["backgrounds"] into backgroundsArray
   if the number of lines of keys(backgroundsArray) = 1 then
      put backgroundsArray ["bg[1]"] into stackArray ["manifest"]["backgrounds"]["bg"]
      delete local stackArray ["manifest"]["backgrounds"]["bg[1]"]
   end if
   
   put the number of videoClips of stackObject into maxVclipNum
   repeat with clipNum = 1 to maxVclipNum
      put the object_PropertyArray of videoClip clipNum of stackObject into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of videoClip clipNum of stackObject into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxVclipNum = 1 then
         put "videoclip" into clipArrayKey
      else
         put "videoclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["videoclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["videoclips"][clipArrayKey]["name"]
   end repeat
   
   put the number of audioClips of stackObject into maxAclipNum
   repeat with clipNum = 1 to maxAclipNum
      put the object_PropertyArray of audioClip clipNum of stackObject into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of audioClip clipNum of stackObject into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxAclipNum = 1 then
         put "audioclip" into clipArrayKey
      else
         put "audioclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["audioclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["audioclips"][clipArrayKey]["name"]
   end repeat
   
   put stackArray into propArray ["stackArray"]
   put hArray into propArray ["hArray"]
   return propArray
end stack_PropertArrays

getprop mainstack_ExportArray
   put the textStack_Folder of the target into mainStackFolder
   put mainStackArray_FetchFromFolder (mainStackFolder) into mainStackArray
   return mainStackArray
end mainstack_ExportArray

getprop object_Array [pVersionNum]
   local manifestArray, objectsArray, pExportHandlers, pDontDiff, pForceIndexHandlerCalls
   put the long id of the target into targetObject
   if pVersionNum is empty then put 0.5 into pVersionNum
   
   objectArray_AddControl targetObject, manifestArray, objectsArray, hArray, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   
   put manifestArray into objectArray ["manifest"]
   put objectsArray into objectArray ["objects"]
   put pVersionNum into objectArray ["manifest"]["version"]
   -- put the short name of targetObject into objectArray ["manifest"]["name"]
   -- put the mobile_Name of targetObject into objectArray ["manifest"]["object"]
   
   return objectArray
end object_Array


--> Props | Get and Set
-
getprop object_MainStackArray [pLinkToViews]
   -- was "mainStack_Array"
   -- Also construct hArray live as we loop through all the objects collecting info
   local hArray
   put the main_Stack of the target into mainStackObject
   put mainstack_ConstructMetaArray (mainStackObject, hArray, pLinkToViews, false) into metaArray
   return metaArray ["mainStackArray"]
end object_MainStackArray

setprop object_MainStackArray [pRename] mainStackArray
   -- was "mainStack_Array"
   put the stack_Name of the target into mainStackName
   
   set the stack_Array [pRename] of the target to mainStackArray
   
   put mainStackArray ["objects"]["substacks"] into sArray
   repeat for each key subStackName in sArray
      put sArray [subStackName] into subStackArray
      put mainStackArray ["manifest"]["substacks"][subStackName] into subStackArray ["manifest"]
      
      create invisible stack subStackName in stack mainStackName
      set the stack_Array [pRename] of stack subStackName of stack mainStackName to subStackArray
   end repeat
   return mainStackArray
end object_MainStackArray

getprop object_PropertyArray [pDontDiff]
   local objectPropArray, hArray, pExportHandlers, pForceIndexHandlerCalls
   put the long id of the target into targetObject
   object_GetPropertyArrays targetObject, objectPropArray, hArray, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   return objectPropArray
end object_PropertyArray

setprop object_PropertyArray [stripID] objectPropArray
   put the long id of the target into targetObject
   if objectPropArray is not an array then return targetObject
   
   lock screen 
   put objectPropArray ["rev"] into revPropertyArray
   
   put objectPropArray ["script"] into someScript
   if someScript is not empty then set the script of targetObject to someScript
   put objectPropArray ["custom"] into customArray
   if customArray is an array then set the custom_PropertyArray of targetObject to customArray
   
   switch word 1 of targetObject
      case "stack" 
         set the style of targetObject to objectPropArray ["style"]
         break
      case "field" 
         put objectPropArray ["htmlText"] into objectHtml   
         if objectHtml is not empty then put objectHtml into revPropertyArray ["htmlText"]
         break
      case "button" 
         put objectPropArray ["text"] into objectText
         if objectText is not empty then put objectText into revPropertyArray ["text"]
         break
      case "image"
         put objectPropArray ["image"] into someImage
         if someImage is not empty then
            set the fileName of targetObject to empty
            set the text of targetObject to someImage
         end if
         break
   end switch
   
   if revPropertyArray is an array then
      set the rev_PropertyArray [stripID] of targetObject to revPropertyArray
      put the result into targetObject -- id may have changed
   end if
   
   unlock screen
   return targetObject
end object_PropertyArray

getprop custom_PropertyArray [pClean]
   put the customPropertySet of the target into oSetName
   set the customPropertySet of the target to empty
   get the customProperties of the target
   if it is an array then put it into customArray ["default"]
   repeat for each line setName in the customPropertySets of the target
      put the customProperties [setName] of the target into customArray [setName]
   end repeat
   set the customPropertySet of the target to oSetName
   if pClean is not false then objectArray_CleanGeneral customArray
   return customArray
end custom_PropertyArray

setprop custom_PropertyArray customArray
   put the customPropertySet of the target into oSetName
   set the customPropertySet of the target to empty
   set the customProperties of the target to customArray ["default"]
   repeat for each key setName in customArray
      set the customProperties [setName] of the target to customArray [setName]
   end repeat
   set the customPropertySet of the target to oSetName
end custom_PropertyArray

getprop rev_PropertyArray [dontDiff]
   put the long id of the target into targetObject
   put the properties of targetObject into revPropertyArray
   
   if dontDiff is not true then
      put the object_DefaultPropArray of the target into defaultPropArray
      repeat for each key propName in defaultPropArray
         if defaultPropArray [propName] = revPropertyArray [propName] then
            delete local revPropertyArray [propName]
         end if
      end repeat
   end if
   
   switch word 1 of targetObject
      case "field"
         put the htmltext of targetObject into revPropertyArray ["htmlText"] -- a stupid RunRev bug!!!
         break
      case "button"
         put the hilite of targetObject into revPropertyArray ["hilited"] -- a stupid RunRev bug!!!
         break
   end switch
   
   -- delete local revPropertyArray ["defaultButton"] -- should not be in the properties as read only
   object_AddMissingArrays revPropertyArray, targetObject
   return revPropertyArray
end rev_PropertyArray

setprop rev_PropertyArray [stripID] revPropertyArray
   put the long id of the target into targetObject
   
   -- put the object_DefaultPropArray of targetObject into defaultPropArray
   -- union revPropertyArray with defaultPropArray -- no need just set up template to default before creating.
   
   put revPropertyArray ["id"] into newID
   if stripID is true then delete local revPropertyArray ["id"]
   
   set the properties of targetObject to revPropertyArray
   
   if stripID is not true and word 1 of targetObject is not "stack" then -- id may have changed so reset targetObject
      if newID is a number then
         put newID into word 3 of targetObject
         if exists(targetObject) is false then breakPoint -- should exists!
      end if
   end if
   
   switch word 1 of targetObject
      case "field"
         set the htmltext of targetObject to revPropertyArray ["htmlText"] -- a stupid RunRev bug!!!
         break
      case "button"
         set the hilite of targetObject to revPropertyArray ["hilited"] -- a stupid RunRev bug!!!
         break
   end switch
   
   rev_SetMissing revPropertyArray, targetObject -- should not be needed RunRev bug !!!
   
   return targetObject
end rev_PropertyArray


--> Mainstack | Array
-
function mainstack_ConstructMetaArray mainStackObject, pHarray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   -- this will also construct hArray if pref_GetValue ("add object to hArray on export") is true
   -- basically a walkArray with added metaArray ["mainStackArray"] key
   
   local mainStackArray, subStackArray
   try
      -- put hArray ["handlerHashArray"] into oldHandlerHashArray
      put false into pStripStackRects
      put the stackArray_Version of me into stackArrayVersion
      
      stack_GetPropertArrays mainStackObject, mainStackArray, pHarray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
      if pStripStackRects is true then delete local mainStackArray ["objects"]["stack"]["rev"]["rect"] -- lets strip the stack rects
   catch e
      breakpoint
   end try
   
   put the short name of stack mainStackObject into mainStackName
   put the substacks of mainStackObject into subStackNames
   repeat for each line subStackName in subStackNames
      try
         -- put the long name of stack subStackName of mainStackObject into subStackObject -- LiveCode bug does not work (returns mainstack)
         -- put the long id of stack subStackName of mainStackObject into subStackObject -- LiveCode bug does not work (returns mainstack)
         put the long id of stack subStackName of stack mainStackName into subStackObject
         -- put revRuggedID (subStackObject) into subStackObject
         
         put empty into subStackArray
         stack_GetPropertArrays subStackObject, subStackArray, pHarray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
         delete variable subStackArray ["manifest"]["version"]
         put subStackArray ["manifest"] into mainStackArray ["manifest"]["substacks"][subStackName]
         delete variable subStackArray ["manifest"]
         
         if pStripStackRects is true then delete local subStackArray ["objects"]["stack"]["rev"]["rect"] -- lets strip the stack rects
         put subStackArray into mainStackArray ["objects"]["substacks"][subStackName]
      catch e
         breakpoint
      end try
   end repeat
   
   -- put harray_ConstructHkeyArray (pHarray) into hKeyArray
   -- put hKeyArray into metaArray ["hKeyArray"]
   
   put mainStackArray into metaArray ["mainStackArray"]
   put pHarray into metaArray ["hArray"]
   put the mainStack_Hash of mainStackObject into mainstackHash
   put mainstackHash into metaArray ["mainStackArray"]["manifest"]["sha1"]
   put mainstackHash into metaArray ["hArray"]["metadata"]["sha1"]
   return metaArray
end mainstack_ConstructMetaArray

function object_ConvertAbbreviated aObject
   replace " id " with "_" in aObject
   return aObject
end object_ConvertAbbreviated

command stack_GetPropertArrays stackObject, @stackArray, @hArray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   put the stackArray_Version of me into stackArray ["manifest"]["version"]
   
   put the short name of stackObject into stackName
   put stackName into stackArray ["manifest"]["name"]
   put revRuggedID (stackObject) into stackArray ["manifest"]["object"]
   put the effective filename of stackObject into someFile
   file_SetHomeRelative someFile
   put someFile into stackArray ["manifest"]["filename"]
   
   object_GetPropertyArrays stackObject, stackPropertyArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   put stackPropertyArray into stackArray ["objects"]["stack"]
   
   set the wholematches to true
   put the cardids of stackObject into someCardIDs
   put the number of lines of someCardIDs into cardMaxNum
   repeat with cardNum = 1 to cardMaxNum
      set the cursor to busy
      put the long id of card cardNum of stackObject into cardObject
      objectArray_AddCard cardObject, stackArray, hArray, pLinkToViews, cardNum, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   end repeat
   
   -- don't now max number of duplicated background objects until end
   -- so problem with scenario of only one bg for xml reconversion comaptability of key naming
   -- as there should be a line "if maxBgNum = 1 then put "bg" into bgArrayKey
   -- have to fix at end of stack parsing
   put stackArray ["manifest"]["backgrounds"] into backgroundsArray
   if the number of lines of keys(backgroundsArray) = 1 then
      put backgroundsArray ["bg[1]"] into stackArray ["manifest"]["backgrounds"]["bg"]
      delete local stackArray ["manifest"]["backgrounds"]["bg[1]"]
   end if
   
   put the number of videoClips of stackObject into maxVclipNum
   repeat with clipNum = 1 to maxVclipNum
      put the object_PropertyArray of videoClip clipNum of stackObject into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of videoClip clipNum of stackObject into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxVclipNum = 1 then
         put "videoclip" into clipArrayKey
      else
         put "videoclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["videoclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["videoclips"][clipArrayKey]["name"]
   end repeat
   
   put the number of audioClips of stackObject into maxAclipNum
   repeat with clipNum = 1 to maxAclipNum
      put the object_PropertyArray of audioClip clipNum of stackObject into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of audioClip clipNum of stackObject into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxAclipNum = 1 then
         put "audioclip" into clipArrayKey
      else
         put "audioclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["audioclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["audioclips"][clipArrayKey]["name"]
   end repeat
end stack_GetPropertArrays

setprop stack_Array [pRename] stackArray
   local newCreationArray
   lock screen
   set the relayerGroupedControls to false -- required otherwize setting layers moves objects out of groups = hack
   
   put the stack_Object of the target into stackNameObject
   set the defaultstack to stackNameObject
   
   if pRename is not false then
      put stackNameObject into stackArray ["manifest"]["object"]
      put the short name of stackNameObject into stackArray ["manifest"]["name"]
   end if
   
   put stackArray ["objects"]["stack"] into stackPropertyArray
   set the object_PropertyArray of stackNameObject to stackPropertyArray
   
   put stackArray ["manifest"]["cards"] into allCdsArray
   if allCdsArray is an array then
      put the number of lines of keys (allCdsArray) into numberOfCards
      put 1 into cardNum
      repeat with cardNum = 1 to numberOfCards
         card_CreateFromArray cardNum, stackArray, newCreationArray
         if cardNum = numberOfCards then exit repeat
         
         -- now loop again
         create card
         repeat for each line bgID in the groupIDs of this card
            -- if there are any bg behavior grps, remove them and let the objectProp set them back if needed
            remove group id bgID from this cd
         end repeat
      end repeat
   else
      -- lazy zero manifest (objects only array)
      put stackArray ["objects"] into oArray
      repeat for each key aFolder in oArray
         if aFolder = "stack" then next repeat
         put oArray [aFolder] into objectPropertyArray
         put aFolder into aObject
         replace "_" with " id " in aObject
         
         object_Create aObject, empty, objectPropertyArray
      end repeat
   end if
   
   -- interestingly filename is not in the properties of a stack
   put manifestArray ["filename"] into someFile
   if someFile is not empty then set the filename of stackNameObject to someFile
   
   put 1 into clipNum
   repeat for each element clipArray in stackArray ["manifest"]["videoclips"]
      put clipArray ["object"] into aObject
      put aObject into aFolder
      replace " id " with "_" in aFolder
      put stackArray ["objects"][aFolder]["rev"] into revPropertyArray
      put stackArray ["objects"][aFolder]["videoclip"] into clipData
      if clipData is empty then next repeat
      
      put the tempname into someFile
      put clipData into url ("binfile:" & someFile)
      -- create videoClip -- does not work for videoClips
      import videoClip from file someFile
      -- put the result into createdObject -- RunRev bug it or the result does not give the createdObject
      
      delete local revPropertyArray ["layer"]
      set the rev_PropertyArray of videoClip clipNum to revPropertyArray
      add 1 to clipNum
   end repeat
   
   put 1 into clipNum
   repeat for each element clipArray in stackArray ["manifest"]["audioClips"]
      put clipArray ["object"] into aObject
      put aObject into aFolder
      replace " id " with "_" in aFolder
      put stackArray ["objects"][aFolder]["rev"] into revPropertyArray
      put stackArray ["objects"][aFolder]["audioclip"] into clipData
      if clipData is empty then next repeat
      
      put the tempname into someFile
      put clipData into url ("binfile:" & someFile)
      -- create audioClip -- does not work for videoClips
      import audioClip from file someFile
      -- put the result into createdObject -- RunRev bug it or the result does not give the createdObject
      
      delete local revPropertyArray ["layer"]
      set the rev_PropertyArray of audioClip clipNum to revPropertyArray
      add 1 to clipNum
   end repeat
   unlock screen
   return manifestArray
end stack_Array


--> Card | Create
-
command card_CreateFromArray cardNum, stackArray, @newCreationArray   
   -- put the long id of cd cardNum into cardObject
   put the long id of this cd into cardObject
   
   -- put stackArray ["manifest"]["cards"][cardNum] into cardArray -- a lot simpler!
   if cardNum = empty then
      put "card" into cardArrayKey
   else
      put "card[" & cardNum & "]" into cardArrayKey
   end if
   put stackArray ["manifest"]["cards"][cardArrayKey] into cardArray
   
   put cardArray ["object"] into aCard
   put stackArray ["objects"] into objectsArray
   
   put object_ConvertAbbreviated (aCard) into aFolder
   put objectsArray [aFolder] into objectPropArray
   
   set the object_PropertyArray of cardObject to objectPropArray
   
   put cardArray ["controls"] into controlArray
   -- put item 2 of the extents of controlArray into maxIndexNum
   put the number of lines of keys(controlArray) into maxIndexNum
   put 1 into groupNum
   repeat with indexNum = 1 to maxIndexNum
      if maxIndexNum = 1 then
         put "index" into indexNumKey
      else
         put "index[" & indexNum & "]" into indexNumKey
      end if
      put controlArray [indexNumKey]["object"] into aControl
      
      put word 3 of aControl into aControlID
      if aControl is among the keys of newCreationArray then
         -- it must be a background
         if aControlID is among the lines of the groupIDs of this card then
            breakpoint -- should never be true
         else
            set lockmessages to true
            place background id aControlID onto this cd
            set lockmessages to false
         end if
      else
         put controlArray [indexNumKey]["owner"] into cOwner
         object_Create aControl, cOwner
         put the result into createdObject
         
         put object_ConvertAbbreviated (aControl) into cFolder
         put objectsArray [cFolder] into objectPropArray
         delete local objectPropArray ["rev"]["layer"] -- layers can cause problems (hack)
         put objectPropArray into newCreationArray [aControl]
         
         set the object_PropertyArray of createdObject to objectPropArray
      end if
   end repeat
   
   -- now add variable content
   put cardArray ["variable"] into vArray
   repeat for each key eNum in vArray
      put vArray [eNum]["object"] into vObject
      switch word 1 of vObject
         case "field"
            set the htmltext of vObject to vArray [eNum]["html"]
            break
         case "button"
            set the hilite of vObject to vArray [eNum]["hilite"]
            break
      end switch
   end repeat
   
   return true
   
   -- this bit does not get the rect right ???
   -- now set group props (after all content is set)
   repeat with gNum = (groupNum - 1) down to 1
      put groupPropArray [gNum]["object"] into aGroup
      put groupPropArray [gNum]["propArray"] into objectPropArray
      set the object_PropertyArray of aGroup to objectPropArray
   end repeat
end card_CreateFromArray


--> Stack | Export
-
function mainStackArray_FetchFromFolder mainStackFolder, pUseCustomFolders
   -- should work for mainstack folder of substack folders
   folder_Format mainStackFolder
   put stack_FetchManifestArray (mainStackFolder) into manifestArray
   put manifestArray into mainStackArray ["manifest"]
   
   put mainStackFolder & "objects/" into objectsFolder
   put the directory into originalDirectory
   set the directory to objectsFolder
   put the folders into shortFolders  
   put false into hasSubStacks
   repeat for each line shortFolder in shortFolders
      switch
         case char 1 of shortFolder = "." 
            next repeat
         case shortFolder = "substacks"
            put true into hasSubStacks
            next repeat
         default
            put objectsFolder & shortFolder & "/" into objectFolder
            put object_ConstructArrayFromFolder (objectFolder, pUseCustomFolders) into objectArray
            put objectArray into objectsArray [shortFolder]
      end switch
   end repeat
   
   if hasSubStacks is true then
      put objectsFolder & "substacks/" into subStackRoot
      set the directory to subStackRoot
      put the folders into shortSubStackFolders  
      repeat for each line shortSubStackFolder in shortSubStackFolders
         if char 1 of shortSubStackFolder = "." then next repeat
         put subStackRoot & shortSubStackFolder & "/" into subStackFolder
         put stackArray_FetchFromFolder (subStackFolder, pUseCustomFolders) into subStackArray
         put subStackArray into objectsArray ["substacks"][shortSubStackFolder]
      end repeat
   end if
   put objectsArray into mainStackArray ["objects"]
   set the directory to originalDirectory
   return mainStackArray
end mainStackArray_FetchFromFolder

function stackArray_FetchFromFolder textStackFolder, pUseCustomFolders
   folder_Format stackFolder
   put stack_FetchManifestArray (textStackFolder) into manifestArray
   put manifestArray into stackArray ["manifest"]
   
   put textStackFolder & "data/objects/" into objectsFolder
   -- if pDontCreate is false then folder_CreateNested objectsFolder
   if there is not a folder objectsFolder then return empty -- should always be there!
   
   put the directory into originalDirectory
   set the directory to objectsFolder
   put the folders into shortFolders
   
   repeat for each line shortFolder in shortFolders
      switch
         case char 1 of shortFolder = "." 
            next repeat
         case shortFolder = "substacks"
            put objectsFolder & "substacks/" into substacksFolder
            set the directory to substacksFolder
            put the folders into shortSubstackFolders
            repeat for each line substackName in shortSubstackFolders
               switch
                  case char 1 of substackName = "." 
                     next repeat
                  default
                     put substacksFolder & substackName & "/" into substackFolder
                     set the directory to substackFolder
                     put the folders into shortSubstackObjectFolders
                     repeat for each line shortSubstackObjectFolder in shortSubstackObjectFolders
                        switch
                           case char 1 of shortSubstackObjectFolder = "." 
                              next repeat
                           default
                              put substackFolder & shortSubstackObjectFolder & "/" into substackObjectFolder
                              put object_ConstructArrayFromFolder (substackObjectFolder, pUseCustomFolders) into substackObjectArray
                              put substackObjectArray into objectsArray ["substacks"][substackName]["objects"][shortSubstackObjectFolder]
                        end switch
                     end repeat
               end switch
            end repeat
            next repeat
         default
            put objectsFolder & "/" & shortFolder & "/" into objectFolder
            put object_ConstructArrayFromFolder (objectFolder, pUseCustomFolders) into objectArray
            put objectArray into objectsArray [shortFolder]
      end switch
   end repeat
   
   put objectsArray into stackArray ["objects"]
   set the directory to originalDirectory
   return stackArray
end stackArray_FetchFromFolder


--> Object | Array
-
command objectArray_AddCard cardObject, @stackArray, @hArray, pLinkToViews, pCardNum, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   local objectPropArray
   if pCardNum is empty then
      put "card" into cardArrayKey
   else
      put "card[" & pCardNum & "]" into cardArrayKey
   end if
   
   put the abbreviated id of cardObject into abbreviatedID
   put abbreviatedID into stackArray ["manifest"]["cards"][cardArrayKey]["object"]
   -- put pCardNum into stackArray ["manifest"]["cards"][cardArrayKey]["layer"] -- stored already with rev array
   
   -- just for readability
   put the short name of cardObject into cardName
   put cardName into stackArray ["manifest"]["cards"][cardArrayKey]["name"]
   
   object_GetPropertyArrays cardObject, objectPropArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   
   put object_ConvertAbbreviated (abbreviatedID) into aFolderName
   put objectPropArray into stackArray ["objects"][aFolderName]
   
   put the number of controls in cardObject into controlMaxNum
   put 1 into controlNum
   put 0 into indexNum -- the order in the index of things to create
   repeat controlMaxNum
      try
         set the cursor to busy
         add 1 to indexNum
         if controlMaxNum = 1 then
            put "index" into indexArrayKey
         else
            put "index[" & indexNum & "]" into indexArrayKey
         end if
         
         put the long id of control controlNum of cardObject into someObject
         put the abbreviated id of someObject into abbreviatedID
         put abbreviatedID into stackArray ["manifest"]["cards"][cardArrayKey]["controls"][indexArrayKey]["object"]
         put indexNum into stackArray ["manifest"]["cards"][cardArrayKey]["controls"][indexArrayKey]["create_order"] -- not same as rev layer (so need to store for XML)
         
         -- just for readability
         put the short name of someObject into objectName
         put objectName into stackArray ["manifest"]["cards"][cardArrayKey]["controls"][indexArrayKey]["name"]
         
         put object_ConvertAbbreviated (abbreviatedID) into aFolderName
         put stackArray ["objects"][aFolderName] into indexedObjectPropArray
         if indexedObjectPropArray is an array then
            -- it must be a background that has already been indexed
            -- even if the backgroundbehavior is false? = old bug that is fixed now I think!
            put the number of controls of someObject into skipNum
            objectArray_AddClonedBackgroundToCard someObject, abbreviatedID, stackArray, cardObject
            put the result into bgNum
            put true into stackArray ["manifest"]["cards"][cardArrayKey]["controls"][indexArrayKey]["is_background"]
            
            -- if there are any variable background elements
            put stackArray_GetVariableElements (abbreviatedID, stackArray) into vElements
            put the number of lines of vElements into eMaxNum
            repeat with eNum = 1 to eMaxNum
               if eMaxNum = 1 then
                  put "element" into elementArrayKey -- to be equivalent to xml import script
               else
                  put "element[" & eNum & "]" into elementArrayKey
               end if
               put line eNum of vElements into someLine -- onCardObject
               
               put token 3 of someLine into controlID
               if exists (control id controlID of cardObject) is false then
                  breakpoint
                  next repeat
               end if
               
               put the long id of control id controlID of cardObject into onCardObject
               
               put onCardObject into stackArray ["manifest"]["cards"][cardArrayKey]["variable"][elementArrayKey]["object"]
               switch word 1 of onCardObject
                  case "field"
                     put the htmlText of onCardObject into stackArray ["manifest"]["cards"][cardArrayKey]["variable"][elementArrayKey]["html"]
                     break
                  case "button"
                     put the hilite of onCardObject into stackArray ["manifest"]["cards"][cardArrayKey]["variable"][elementArrayKey]["hilite"]
                     break
               end switch
            end repeat
            
            add skipNum to controlNum
         else
            -- it's a new control to be indexed
            object_GetPropertyArrays someObject, objectPropArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
            
            put objectPropArray into stackArray ["objects"][aFolderName]
            put the abbreviated id of the owner of someObject into abbreviatedOwner
            put abbreviatedOwner into stackArray ["manifest"]["cards"][cardArrayKey]["controls"][indexArrayKey]["owner"]
            
            if pLinkToViews is not false then
               put the view_Name of someObject into vName
               if vName is not empty then
                  -- it is a view or datagrid
                  -- so reference the view
                  put vName into stackArray ["objects"][aFolderName]["view"]
                  
                  -- and store it's initial properties (already stored above?)
                  
                  -- then skip it's inner controls
                  put the number of controls of someObject into skipNum
                  add skipNum to controlNum
               end if
            end if
         end if
         
         add 1 to controlNum
         if controlNum > controlMaxNum then exit repeat
      catch e
         breakpoint
         -- put the mobile_Name of control controlNum of cardObject
      end try
   end repeat
end objectArray_AddCard

command objectArray_AddClonedBackgroundToCard someObject, abbreviatedID, @stackArray, cardObject
   -- not tidying first long entry in manifest, as create scripts can create it using that
   -- only second and later cases need to use a pointer to place a background
   -- could tidy this at the very end, as info is stored with background section
   
   local bgManifestArray, bgObjectsArray
   
   -- let's check to see if it has already been added
   put 1 into newBgNum
   repeat for each element bgArray in stackArray ["manifest"]["backgrounds"]
      if abbreviatedID = bgArray ["object"] then return empty -- already indexed
      add 1 to newBgNum
   end repeat
   
   -- let's add it
   -- don't now max number of duplicated background objects until end
   -- so problem with scenario of only one bg for xml reconversion comaptability of key naming
   -- as there should be a line "if maxBgNum = 1 then put "bg" into bgArrayKey
   -- have to fix at end of stack parsing
   put "bg[" & newBgNum & "]" into bgArrayKey 
   
   -- if it is not on a card and a group then get an error (need bg not group)
   put abbreviatedID into stackArray ["manifest"]["backgrounds"][bgArrayKey]["object"]
   put newBgNum into stackArray ["manifest"]["backgrounds"][bgArrayKey]["bg_num"] -- hope it is the same as bg someNum of stack (ie not layer on card)
   
   -- just for readability
   put the short name of someObject into objectName
   put objectName into stackArray ["manifest"]["backgrounds"][bgArrayKey]["name"]
   
   put the number of controls in someObject into maxNum
   put 1 into controlNum
   put empty into variableElements
   repeat maxNum
      set the cursor to busy
      if maxNum = 1 then
         put "control" into controlArrayKey -- to be equivalent to xml import script
      else
         put "control[" & controlNum & "]" into controlArrayKey
      end if
      put the long id of control controlNum of someObject into nestedObject
      
      put the abbreviated id of nestedObject into aNestedObject
      put aNestedObject into stackArray ["manifest"]["backgrounds"][bgArrayKey]["controls"][controlArrayKey]["object"]
      put controlNum into stackArray ["manifest"]["backgrounds"][bgArrayKey]["controls"][controlArrayKey]["group_layer"] -- not same as card layer - control gLayer of group x
      
      -- just for readability
      put the short name of nestedObject into objectName
      put objectName into stackArray ["manifest"]["backgrounds"][bgArrayKey]["controls"][controlArrayKey]["name"]
      
      put objectsArray [aNestedObject] into indexedObjectPropArray
      if indexedObjectPropArray is an array then
         breakPoint --- should be impossible as it is not a toplevel background
         -- it is a background that has already been indexed (even if the backgroundbehavior is false!)
         put the number of controls of nestedObject into skipNum
         add skipNum to controlNum
      else
         put the abbreviated id of the owner of nestedObject into abbreviatedOwner
         put abbreviatedOwner into stackArray ["manifest"]["backgrounds"][bgArrayKey]["controls"][controlArrayKey]["owner"]
      end if
      
      switch word 1 of aNestedObject
         case "field"
            if the sharedText of nestedObject is false then
               put aNestedObject && "of" && the abbreviated id of cardObject & CR after variableElements
            end if
            break
         case "button"
            if the sharedHilite of nestedObject is false then
               put aNestedObject && "of" && the abbreviated id of cardObject & CR after variableElements
            end if
            break
      end switch
      
      add 1 to controlNum
      if controlNum > maxNum then exit repeat
   end repeat
   delete char -1 of variableElements
   put variableElements into stackArray ["manifest"]["backgrounds"][bgArrayKey]["variable_elements"]
   
   return newBgNum
end objectArray_AddClonedBackgroundToCard

function stackArray_GetVariableElements aBackground, stackArray
   put stackArray_GetBackgroundArray (aBackground, stackArray) into bgArray
   put bgArray ["variable_elements"] into vElements
   return vElements
end stackArray_GetVariableElements

function stackArray_GetBackgroundArray aBackground, stackArray
   repeat for each element bgArray in stackArray ["manifest"]["backgrounds"]
      if aBackground = bgArray ["object"] then return bgArray
   end repeat
   return empty
end stackArray_GetBackgroundArray

command objectArray_AddControl someObject, @manifestArray, @objectsArray, @hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   local objectPropArray
   put the abbreviated id of someObject into abbreviatedID
   put abbreviatedID into manifestArray ["object"]
   
   -- just for readability
   put the short name of someObject into someName
   put someName into manifestArray ["name"]
   
   object_GetPropertyArrays someObject, objectPropArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   
   put object_ConvertAbbreviated (abbreviatedID) into aFolderName
   put objectPropArray into objectsArray [aFolderName]
   
   put the number of controls in someObject into maxNum
   put 1 into controlNum
   repeat maxNum
      set the cursor to busy
      put "control[" & controlNum & "]" into cKey
      put the long id of control controlNum of someObject into nestedObject
      put the abbreviated id of nestedObject into abbreviatedID
      put abbreviatedID into manifestArray ["controls"][cKey]["object"]
      
      -- just for readability
      put the short name of nestedObject into objectName
      put objectName into manifestArray ["controls"][cKey]["name"]
      
      put object_ConvertAbbreviated (abbreviatedID) into nestedFolderName
      put objectsArray [nestedFolderName] into indexedObjectPropArray
      if indexedObjectPropArray is an array then
         -- it is a background that has already been indexed (even if the backgroundbehavior is false!)
         put the number of controls of nestedObject into skipNum
         add skipNum to controlNum
      else
         object_GetPropertyArrays nestedObject, objectPropArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
         
         put objectPropArray into objectsArray [nestedFolderName]
         
         put the abbreviated id of the owner of nestedObject into abbreviatedOwner
         put abbreviatedOwner into manifestArray ["controls"][cKey]["owner"]
         -- put abbreviatedOwner into objectsArray [nestedFolderName]
      end if
      add 1 to controlNum
      if controlNum > maxNum then exit repeat
   end repeat
end objectArray_AddControl


--> Object | Create
-
command object_Create someObject, pOwner, pObjectPropArray
   put pObjectPropArray ["view"] into vName
   if vName is not empty then
      if word 1 of pOwner is empty then
         put the long id of this card into pOwner
      end if
      
      view_InsertFromPath vName, pOwner
      put the result into createdObject
      
      delete local pObjectPropArray ["rev"]["layer"] -- layers can cause problems (hack)
      set the object_PropertyArray of createdObject to pObjectPropArray
   else
      set lockmessages to true
      if word 1 of pOwner = "card" or pOwner is empty then
         switch word 1 of someObject
            case "field"
               create field
               break
            case "button"
               create button
               break
            case "graphic"
               create graphic
               break
            case "image"
               create image
               break
            case "player"
               create player
               break
            case "group"
               create group
               break
            case "scrollbar"
               create scrollbar
               break
         end switch
      else
         switch word 1 of someObject
            case "field"
               create field in pOwner
               break
            case "button"
               create button in pOwner
               break
            case "graphic"
               create graphic in pOwner
               break
            case "image"
               create image in pOwner
               break
            case "player"
               create player in pOwner
               break
            case "group"
               create group in pOwner
               break
            case "scrollbar"
               create scrollbar in pOwner
               break
         end switch
      end if
      put it into createdObject  
      set lockmessages to false
      
      if pObjectPropArray is an array then
         delete local pObjectPropArray ["rev"]["layer"] -- layers can cause problems (hack)
         set the object_PropertyArray of createdObject to pObjectPropArray
      end if
      return createdObject
   end if
end object_Create


--> Meta | Utils
-
function object_ConstructArrayFromFolder objectFolder, pUseCustomFolders
   if pUseCustomFolders is empty then
      put meta_GetCustomArrayFile (objectFolder) into someFile
      put there is not a file someFile into pUseCustomFolders
   end if
   
   put object_FetchRevPropText (objectFolder) into revPropText
   put rev_PropertyTextToArray (revPropText) into revPropertyArray 
   put revPropertyArray into objectPropArray ["rev"]
   
   put object_FetchMetaText (objectFolder) into objectText
   if objectText is not empty then put objectText into objectPropArray ["text"]
   
   put object_FetchMetaHtml (objectFolder) into objectHtml
   if objectHtml is not empty then put objectHtml into objectPropArray ["htmlText"]
   
   put object_FetchScript (objectFolder) into someScript
   if someScript is not empty then put someScript into objectPropArray ["script"]
   
   put object_FetchMetaImage (objectFolder) into someImage  -- no idea what type of image it is (but don't use imagedata) ???
   if someImage is not empty then put someImage into objectPropArray ["image"]
   
   put object_FetchCustomArray (objectFolder, pUseCustomFolders) into customArray
   if customArray is an array then put customArray into objectPropArray ["custom"]
   
   return objectPropArray
end object_ConstructArrayFromFolder


--> Object | Property
-   
command object_DeconstructPropertyArray objectPropArray, @revPropertyArray, @someScript, @objectText, @objectHtml, @customArray, @someImage
   -- object_DeconstructPropertyArray objectPropArray, revPropText, someScript, objectText, objectHtml, metadataArray, customArray, someImage
   
   put objectPropArray ["rev"] into revPropertyArray
   put objectPropArray ["text"] into objectText
   put objectPropArray ["htmlText"] into objectHtml   
   put objectPropArray ["script"] into someScript
   put objectPropArray ["image"] into someImage
   put objectPropArray ["custom"] into customArray
end object_DeconstructPropertyArray

command objectArray_TempClean @customArray
   -- strip some old Constellation stuff for now
   delete local customArray ["default"]["cConsLastHandlerName"]
   delete local customArray ["default"]["cConsLastHandlerScroll"]
   
   delete local customArray ["cConsLast"]
end objectArray_TempClean

command objectArray_CleanGeneral @customArray
   objectArray_TempClean customArray
   
   delete local customArray ["cREVGeneral"]["bookmarks"]
   delete local customArray ["cREVGeneral"]["handlerList"]
   delete local customArray ["cREVGeneral"]["scriptSelection"]
   delete local customArray ["cREVGeneral"]["prevHandler"]
   delete local customArray ["cREVGeneral"]["tempScript"]
   delete local customArray ["cREVGeneral"]["script"]
   delete local customArray ["cREVGeneral"]["scriptCheckSum"]
   
   delete local customArray ["cREVGeneral"]["breakpointconditions"]
   delete local customArray ["cREVGeneral"]["breakpoints"]
   delete local customArray ["cREVGeneral"]["breakpointstates"]
   delete local customArray ["cREVGeneral"]["stackfileversion"]
   
   delete local customArray ["cREVGeneral"]["scripteditorselection"]
   delete local customArray ["cREVGeneral"]["scripteditorvscroll"]
end objectArray_CleanGeneral

function object_FetchCustomArray objectFolder, pUseCustomFolders
   if pUseCustomFolders is not true then
      -- fetch from encoded array
      put meta_GetCustomArrayFile (objectFolder) into someFile
      put array_Fetch (someFile) into customArray
      return customArray
   else
      -- export as folder
      folder_Format objectFolder
      put objectFolder & "custom/" into customFolder
      put array_FromFolder (customFolder) into customArray
      return customArray
   end if
end object_FetchCustomArray

command object_ExportCustomArray objectFolder, customArray, pUseCustomFolders
   if pUseCustomFolders is not true then
      -- export as encoded array
      put meta_GetCustomArrayFile (objectFolder) into someFile
      array_Save someFile, customArray
      return someFile
   else
      -- export as folder
      folder_Format objectFolder
      put objectFolder & "custom/" into customFolder
      if customArray is not an array then
         revDeleteFolder customFolder
         return empty
      else
         put objectFolder & "custom/" into customFolder
         array_ToFolder customFolder, customArray
         return customFolder
      end if
   end if
end object_ExportCustomArray


--> Object | Property | Array
-
command object_GetPropertyArrays targetObject, @objectPropArray, @hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   put the rev_PropertyArray [pDontDiff] of targetObject into revPropertyArray
   
   switch word 1 of targetObject
      case "stack"
         put the style of targetObject into objectPropArray ["style"]
         put the stackfiles of targetObject into stackFileTable
         if stackFileTable is not empty then put stackFileTable into objectPropArray ["stackfiles"]
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "button"
         get revPropertyArray ["text"]
         if it is not empty then put it into objectPropArray ["text"]
         delete local revPropertyArray ["text"]
         
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "field"
         get revPropertyArray ["htmlText"]
         if it is not empty then put it into objectPropArray ["htmlText"]
         delete local revPropertyArray ["htmlText"]
         
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "image"
         if revPropertyArray ["fileName"] is empty then
            put the text of targetObject into objectPropArray ["image"] -- strange hack to get the full contents of an image
         end if
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "videoclip"
         put the text of targetObject into objectPropArray ["videoclip"] -- strange hack to get the full contents of a videoclip
         break
      case "audioclip"
         -- put the text of targetObject into objectPropArray ["audioclip"] -- RunRev bug!!! No way to export an audoclip
         copy targetObject
         put the clipboarddata ["objects"] into objectPropArray ["audioclip"]
         break
      default
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
   end switch 
   
   put revPropertyArray into objectPropArray ["rev"] -- contains id
end object_GetPropertyArrays

command object_AddScriptAndCustomArray @objectPropArray, targetObject, @hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
   -- ignoreCall:  object_AddToArray,c
   put the custom_PropertyArray of targetObject into customArray
   if customArray is an array then put customArray into objectPropArray ["custom"]
   put the script of targetObject into someScript
   if someScript is not empty then
      put someScript into objectPropArray ["script"]
      
      -- here we can also add object to the hArray (only if there is a script)
      if pref_GetValue ("Add object to hArray on stack export") is true then
         -- this can be slow (so turned off by default)
         put pref_GetValue ("Construct hashArray on stack export") into pCreateHashArray
         try
            -- a cheap way of allowing for "object_AddToArray" to be missing without the handler failing
            object_AddToArray hArray, targetObject, someScript, pExportHandlers, pCreateHashArray, pForceIndexHandlerCalls, pDontExport
         catch sError
            -- and so allowing for the whole comple hArtray handling set up to be in a separate (non-required) library.
            -- this should fail gracefully
            -- returning the object array (objectPropArray) without the hArray metadata
         end try
      end if
   end if
end object_AddScriptAndCustomArray

private command rev_SetMissing revPropertyArray, targetObject
   /*
   I can confirm that the antialiased/gradient props are not included in graphics; and the bitmap effect properties are not reported for controls.
   antialiased, fillgradient, strokegradient
   innershadow, innerglow, outerglow, dropshadow, coloroverlay
   */
   switch
      case word 1 of targetObject is not among the items of "card,stack,videoclip,audioclip"
         get revPropertyArray ["innershadow"]
         if it is an array then set the innerShadow of targetObject to it
         
         get revPropertyArray ["innerglow"]
         if it is an array then set the innerglow of targetObject to it
         
         get revPropertyArray ["outerglow"]
         if it is an array then set the outerglow of targetObject to it
         
         get revPropertyArray ["dropshadow"]
         if it is an array then set the dropshadow of targetObject to it
         
         get revPropertyArray ["coloroverlay"]
         if it is an array then set the coloroverlay of targetObject to it -- RunRev bug setting coloroverlay to empty !!!
         break
      case word 1 of targetObject is "graphic"
         set the antialiased of targetObject to revPropertyArray ["antialiased"]
         set the fillgradient of targetObject to revPropertyArray ["fillgradient"]
         set the strokegradient of targetObject to revPropertyArray ["strokegradient"]
         break   
   end switch
end rev_SetMissing

private command object_AddMissingArrays @revPropertyArray, targetObject
   /*
   I can confirm that the antialiased/gradient props are not included in graphics; and the bitmap effect properties are not reported for controls.
   antialiased, fillgradient, strokegradient
   innershadow, innerglow, outerglow, dropshadow, coloroverlay
   */
   
   if word 1 of targetObject is "graphic" then
      put the antialiased of targetObject into revPropertyArray ["antialiased"]
      get the fillgradient of targetObject
      if it is an array then put it into revPropertyArray ["fillgradient"]
      get the strokegradient of targetObject
      if it is an array then put it into revPropertyArray ["strokegradient"]
   end if
   
   if word 1 of targetObject is not among the items of "card,stack,videoclip,audioclip" then
      get the innerShadow of targetObject
      if it is an array then put it into revPropertyArray ["innershadow"]
      get the innerglow of targetObject
      if it is an array then put it into revPropertyArray ["innerglow"]
      get the outerglow of targetObject
      if it is an array then put it into revPropertyArray ["outerglow"]
      get the dropshadow of targetObject
      if it is an array then put it into revPropertyArray ["dropshadow"]
      get the coloroverlay of targetObject
      if it is an array then put it into revPropertyArray ["coloroverlay"]
   end if
end object_AddMissingArrays


--> Object | Property | Deps
-
command objectArray_StripMobile @objectPropArray
   put objectPropArray ["rev"] into revPropertyArray
   propertyArray_StripMobile revPropertyArray
   put revPropertyArray into objectPropArray ["rev"]
end objectArray_StripMobile

command propertyArray_StripMobile @revPropertyArray
   -- lets not store ids, positions (rect),, layers, or text (as we have html)
   delete local revPropertyArray ["id"]
   delete local revPropertyArray ["rect"]
   delete local revPropertyArray ["layer"]
   
   delete local revPropertyArray ["script"]
end propertyArray_StripMobile

function rev_PropertyTextToArray revPropText
   put revPropText into revPropertyArray
   split revPropertyArray with CR and tab
   
   put revPropertyArray ["colors"] into propColours
   if propColours is not empty then
      replace "/" with CR in propColours
      put propColours into revPropertyArray ["colors"]
   else
      -- delete local revPropertyArray ["colors"]
   end if
   
   put revPropertyArray ["patterns"] into propPatterns
   if propPatterns is not empty then
      replace "/" with CR in propPatterns
      put propPatterns into revPropertyArray ["patterns"]
   else
      -- delete local revPropertyArray ["patterns"]
   end if
   
   put revPropertyArray ["points"] into graphicPoints
   if graphicPoints is not empty then
      replace "/" with CR in graphicPoints
      put graphicPoints into revPropertyArray ["points"]
   else
      -- delete local revPropertyArray ["points"]
   end if
   
   return revPropertyArray
end rev_PropertyTextToArray

function rev_PropertyArrayToText revPropertyArray
   -- delete local revPropertyArray ["text"]
   delete local revPropertyArray ["htmlText"]
   
   put revPropertyArray ["colors"] into propColours
   delete local revPropertyArray ["colors"]
   put revPropertyArray ["patterns"] into propPatterns
   delete local revPropertyArray ["patterns"]
   put revPropertyArray ["points"] into graphicPoints
   delete local revPropertyArray ["points"]
   
   put revPropertyArray into propText
   combine propText with CR and tab
   
   if graphicPoints is not empty then
      replace CR with "/" in graphicPoints
      put CR & "points" & tab & graphicPoints after propText
   end if
   if propColours is not empty then
      replace CR with "/" in propColours
      put CR & "colors" & tab & propColours after propText
   end if
   if propPatterns is not empty then
      replace CR with "/" in propPatterns
      put CR & "patterns" & tab & propPatterns after propText
   end if
   
   return propText
end rev_PropertyArrayToText
