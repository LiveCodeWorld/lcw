script "model_LiveLanguage"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_LiveLanguage
type: model
version: 0.1


--> Variables
-
local LivecodeDictionaryTerms


--> Display
-
command display_ExtraDictionaryArray
   put ide_FetchExtraDicTermArray() into dArray
   --
   display_Data dArray, "ide_FetchExtraDicTermArray()"
   return the result
end display_ExtraDictionaryArray


--> Working on
-
command dict_GetAndCacheTerms
   put dict_GetLangaugeTerms() into dTerms
   --
   dict_SetCached dTerms
   return dTerms
end dict_GetAndCacheTerms


--> Deps | dict_IsLanguageTerm
-
getprop model_Index [pShortFile]
   -- by convention we a model stack
   put the model_TextFile [pShortFile] of the target into indexFile
   put text_Get (indexFile) into sIndex
   return sIndex
end model_Index

getprop model_TextFile [pShortFile]
   if pShortFile is empty then put "index.txt" into pShortFile
   --
   put the short name of the defaultstack into modelStackName
   put the stack_Folder of the target into projectFolder
   put model_GetDataFile (modelStackName, projectFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_TextFile

getprop stack_Folder
   put the effective filename of the defaultstack into stackFolder
   set the itemdelimiter to slash
   put empty into item -1 of stackFolder
   return stackFolder
end stack_Folder

function folder_AddShort projectFolder, shortFolder
   text_AddPath projectFolder, shortFolder, slash
   return projectFolder
end folder_AddShort

function model_GetDataFile modelStackName, projectFolder, pShortFile
   if projectFolder is empty then return empty
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put _ConstructModelDataFile (modelDataFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_GetDataFile

function model_GetDataFolder modelStackName, projectFolder
   put folder_AddShort (projectFolder, "models") into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder

command text_AddPath @sText, pPathItem, pDelim
   -- used by "folder_AddShort" to add
   if pPathItem is empty then return false
   if sText is empty then return false -- return pDelim ?
   --
   if pDelim is empty then put slash into pDelim --lazy default
   
   if char -1 of sText is not pDelim then
      put pDelim after sText
   end if
   put pPathItem & pDelim after sText
end text_AddPath

function text_Get someFile
   put url ("binfile:" & someFile) into binaryData
   put textDecode (binaryData, "UTF-8") into sText
   -- put url ("file:" & someFile) into sText
   return sText
end text_Get

private function _ConstructModelDataFile modelDataFolder, pShortFile
   -- rename / replace
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of modelDataFolder into modelName
      put modelName & ".array" into pShortFile
   end if
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end _ConstructModelDataFile


--> Dict
-
command dict_AddExtraTerm newTerm
   put dict_ListCached() into dTerms
   if newTerm is among the lines of dTerms then return false
   
   # New term add to cache and store new index
   put newTerm & CR before dTerms
   dict_SetCached dTerms
   dict_SetLangaugeTerms dTerms
   return true
end dict_AddExtraTerm

function dict_IsLanguageTerm sWord
   if char 1 to 3 of sWord is "rev" and char 4 of sWord is not "_" then return true -- a bit risky to assume this!
   
   put dict_ListCached() into dTerms
   set the wholematches to true
   put sWord is among the lines of dTerms into sBoolean
   return sBoolean
end dict_IsLanguageTerm

function dict_ListCached
   -- was "ide_GetDictionaryTerms"
   if LivecodeDictionaryTerms is empty then
      put dict_GetLangaugeTerms() into LivecodeDictionaryTerms
   end if
   return LivecodeDictionaryTerms
end dict_ListCached

command dict_SetCached dTerms
   put word 1 to -1 of dTerms into LivecodeDictionaryTerms
end dict_SetCached

function dict_FetchLangaugeTerms
   
end dict_FetchLangaugeTerms

function dict_GetLangaugeTerms
   put the model_Index of me into dTerms
   return dTerms
end dict_GetLangaugeTerms

command dict_SetLangaugeTerms dTerms
   set the model_Index of me to dTerms
   put the result into indexFile
   put indexFile
end dict_SetLangaugeTerms


--> IDE | Dictionary | Model
-
command ide_AddExtraDicTerm newTerm, pHKeyUsingTerm
   put ide_FetchExtraDicTermArray() into ideExtraDicTermArray
   put pHKeyUsingTerm into ideExtraDicTermArray [newTerm]
   ide_StoreExtraDicTermArray ideExtraDicTermArray
   return ideExtraDicTermArray
end ide_AddExtraDicTerm

command ide_DeleteExtraDicTerms dicTerms
   replace comma with CR in dicTerms
   put ide_FetchExtraDicTermArray() into ideExtraDicTermArray
   repeat for each line dicTerm in dicTerms
      delete variable ideExtraDicTermArray [dicTerm]
   end repeat
   ide_StoreExtraDicTermArray ideExtraDicTermArray
   return ideExtraDicTermArray
end ide_DeleteExtraDicTerms

function ide_ListExtraDicTerms
   put ide_FetchExtraDicTermArray() into ideExtraDicTermArray
   put keys (ideExtraDicTermArray) into extraDicTerms
   sort extraDicTerms
   return extraDicTerms
end ide_ListExtraDicTerms

function ide_FetchExtraDicTermArray
   put lcw_FetchArray ("ideExtraDicTermArray.array") into ideExtraDicTermArray
   return ideExtraDicTermArray
end ide_FetchExtraDicTermArray

command ide_StoreExtraDicTermArray ideExtraDicTermArray
   lcw_StoreArray "ideExtraDicTermArray.array", ideExtraDicTermArray
   return the result
end ide_StoreExtraDicTermArray
