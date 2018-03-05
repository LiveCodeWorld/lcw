script "model_ScriptMetadata"
--> MetaData
-
license: GPLv3
name: model_ScriptMetadata
type: model
version: 0.1


--> Script | Metadata
-
getprop script_MetaData [someKey]
   put the script of the target into someScript
   put script_GetMetadataArray (someScript) into uRipArray
   if someKey is empty then
      return uRIPArray
   else
      return uRIPArray [someKey]
   end if
end script_MetaData
 
setprop script_MetaData uRIPArray
   put the long id of the target into tObject
   put the script of tObject into someScript   
   script_SetMetadataArray someScript, uRipArray
   set the customproperties ["uRIP"] of tObject to uRipArray
   send "set the script of tObject to someScript" to tObject in 2 ticks
   beep
end script_MetaData

function script_GetMetadataArray someScript
   local metadataArray
   put script_GetSuite ("MetaData", someScript) into metaDataSuite
   if metaDataSuite is empty then return empty
   
   script_DeconstructMetaDataSuite metaDataSuite, metadataBit, commentBit, handlerBit
   put commentBit into metadataArray ["script_Help"]
   
   -- loop through metadata part of suite
   set the itemdelimiter to ":"
   repeat for each line someLine in metadataBit
      put item 1 of someLine into someKey
      put item 2 to -1 of someLine into someValue
      if someValue is empty then next repeat
      
      put word 1 to -1 of someKey into someKey
      put word 1 to -1 of someValue into someValue
      -- replace quote with empty in someKey
      -- replace quote with empty in someValue
      
      put someValue into metadataArray [someKey]
   end repeat
   return metadataArray
end script_GetMetadataArray

command script_SetMetadataArray @someScript, uRipArray
   -- now add any handlers etc (stuff after an empty line) from old Metadata suite
   put script_GetSuite ("MetaData", someScript) into oldMetaDataSuite
   script_DeconstructMetaDataSuite oldMetaDataSuite, oldMetadataBit, oldCommentBit, handlerBit
   
   put oldCommentBit into uRipArray ["script_Help"]
   put script_ConstuctMetaDataHeader (uRipArray) into newMetaDataSuite
   if handlerBit is not empty then put CR & CR & word 1 to -1 of handlerBit after newMetaDataSuite
   
   put script_DeleteSuite ("Metadata", someScript) into cleanScript
   put newMetaDataSuite & CR & CR & CR & word 1 to -1 of cleanScript into someScript
   return newMetaDataSuite
end script_SetMetadataArray

command script_DeconstructMetaDataSuite metaDataSuite, @metadataBit, @commentBit, @handlerBit
   put empty into metadataBit
   put empty into commentBit
   put empty into handlerBit
   
   -- lets trim of suite header
   set the itemdelimiter to ":"
   repeat while line 1 of metaDataSuite begins with "-"
      delete line 1 of metaDataSuite
   end repeat
   
   set the itemdelimiter to ":"
   repeat with lineNum = 1 to the number of lines of metaDataSuite
      put line lineNum of metaDataSuite into someLine
      switch
         case word 1 of someLine = "/*"
            put true into commentBlock
            put lineNum into startCommentLine
            break
         case commentBlock is true
            -- keep looping till end of block
            if word -1 of someLine = "*/" then
               -- could put this commented out section in the index?
               put lineNum into endCommentLine
               put line (startCommentLine + 1) to (endCommentLine - 1) of metaDataSuite into commentBit
               put false into commentBlock
            end if
            break
         case token 1 of someLine is among the items of "on,command,function,getprop,setprop,private,local,constant,global"
            put word 1 to -1 of line lineNum to -1 of metaDataSuite into handlerBit
            break
         case the number of items of someLine = 2
            put someLine & CR after metadataBit
      end switch
   end repeat
   delete char -1 of metadataBit
end script_DeconstructMetaDataSuite

function script_ConstuctMetaDataHeader metadataArray, pScriptHelp, pScriptHelpTile
   local mData
   
   if pScriptHelp is empty then
      put metadataArray ["script_Help"] into oldBit
      if oldBit is empty then
         put empty into helpSection
      else
         put "/*" & oldBit & "*/" into helpSection
      end if
   else
      put "/*" into helpSection
      if pScriptHelpTile is not empty then put space & pScriptHelpTile after helpSection
      put CR & pScriptHelp after helpSection
      put CR & "*/" after helpSection
   end if
   
   delete local metadataArray ["script_Help"]
   repeat for each line someKey in keys(metadataArray)
      put metadataArray [someKey] into someValue
      put someKey & ":" && someValue & CR after mData
   end repeat
   delete last char of mData
   sort lines of mData
   
   put script_ConstructSuiteHeader ("MetaData") into metaDataHeader
   if mData is not empty then
      put CR & mData after metaDataHeader
   end if
   
   if helpSection is not empty then
      put CR & CR & helpSection after metaDataHeader
   end if
   
   return metaDataHeader
end script_ConstuctMetaDataHeader
  
function script_AddMetaDataToScript someScript, uRipKey, uRipValue
   put script_GetMetadataArray (someScript) into uRipArray
   get the paramcount - 1
   put trunc(it/2) into maxNum
   repeat with paramNum = 2 to maxNum step 2
      put param(paramNum) into uRipKey
      put param(paramNum + 1) into uRipValue
      put uRipValue into uRipArray [uRipKey]
   end repeat
   
   script_SetMetadataArray someScript, uRipArray
   return someScript
end script_AddMetaDataToScript

function script_MetaKeyList
    return "buildNumber,copyright,creator,date,description,downloadURL,EULA,help,homeURL,interface,name,props,requirements,specVersion,type,updateInfoURL,version"
 end script_MetaKeyList
