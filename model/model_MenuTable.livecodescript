script "model_MenuTable"
--> MetaData
-
license: GPLv3
name: model_MenuTable
type: model
version: 0.1

/*
The main menu model is handled by the model_ScriptMenu stack.

I'm not sure this is really useful or needed.
Used to be libOPN_MenuModel.rev
*/


--> Menu | Extras
-
command menu_ReIndexSubStack pStackObject
   if pStackObject is empty then put the stack_Object of the target into pStackObject
   repeat with cardNum = 1 to the number of cards of pStackObject
      set the cursor to busy
      put the long id of card cardNum of pStackObject into cardObject
      -- object_AddToGlobalArray cardObject
      
      -- script_JustCompiled cardObject
      object_AddToGlobalArray cardObject
      put the script of cardObject into someScript
      set the exported_Script of cardObject to someScript
   end repeat
end menu_ReIndexSubStack

function menu_GetTitleSuites mTitle, someScript
   put script_GetSuiteTitles (someScript) into suiteTitles
   filter suiteTitles with (mTitle & "*")
   sort suiteTitles
   repeat for each line suiteTitle in suiteTitles
      put script_GetSuite (mTitle, someScript) into scriptSuite
      if scriptSuite is not empty then put scriptSuite & CR & CR after scriptSuites
   end repeat
   delete char -2 to -1 of scriptSuites
   return scriptSuites
end menu_GetTitleSuites

command menu_DeleteTitleSuites mTitle, @someScript
   put script_GetSuiteTitles (someScript) into suiteTitles
   put suiteTitles into allMenuTitles
   sort allMenuTitles
   filter allMenuTitles with ("*" && "| Menu")
   put suiteTitles into mTitles
   filter mTitles with (mTitle & "*")
   
   put "Menu | Props" into generalMenuPropTitle
   put script_GetSuite (generalMenuPropTitle, someScript) into scriptSuite
   if scriptSuite is not empty then
      put scriptSuite & CR & CR & CR after scriptSuites
      if mTitle = allMenuTitles then
         -- it's the only menu, so others nothing to require "Menu | Props"
         put script_DeleteSuite (generalMenuPropTitle, someScript) into newScript
      end if
   end if
   
   repeat for each line mTitle in mTitles
      put script_GetSuite (mTitle, someScript) into scriptSuite
      if scriptSuite is not empty then put scriptSuite & CR & CR & CR after scriptSuites
      put script_DeleteSuite (mTitle, someScript) into someScript
   end repeat
   put word 1 to -1 of someScript into someScript -- might as well tidy
   put word 1 to -1 of scriptSuites into scriptSuites
   return scriptSuites
end menu_DeleteTitleSuites


--> Model | Menu | Plugin
-
/*
References to menus are stored in the global vairable "gOPN_MenuArray".
It allows for front scripts to override existing menus (like those in the IDE),
based on the contents of this global array.

This model is stored along with other OPN Globals in the opn_Preferences stack.
These preferences are automatically stored on exiting the open environment and loaded on opening it.
*/

getprop menu_Plugin [pModifierKey]
   if pModifierKey is empty then put "control" into pModifierKey
   put the long id of the target into targetObject
   
   menu_AddPlugin targetObject, pModifierKey, gMenuTitle
   put the menu_PluginTable [pModifierKey] of targetObject into prettyResult
   return prettyResult
end menu_Plugin

setprop menu_Plugin [pModifierKey] gMenuTitle
   if pModifierKey is empty then put "control" into pModifierKey
   put the long id of the target into targetObject
   
   menu_AddPlugin targetObject, pModifierKey, gMenuTitle
   put the menu_PluginTable [pModifierKey] of targetObject into prettyResult
   return prettyResult
end menu_Plugin

-- getprop menu_PluginArray [pToolMode]
   global gOPN_MenuArray
   put the long id of the target into targetObject
   
   put item 2 of pToolMode into pObjectTestProp
   -- use main_Name as default as this is what is needed by revScriptEditor and faster to have only one prop to search
   if pObjectTestProp is empty then put "main_Name" into pObjectTestProp
   put item 1 of pToolMode into toolMode
   if toolMode is empty then
      put menu_ModifierKeys() into toolMode
      if toolMode is empty then put "none" into toolMode
   end if
   
   put gOPN_MenuArray [toolMode] into toolModeArray
   put keys(toolModeArray) into pObjectTestProps
   repeat for each line pObjectTestProp in pObjectTestProps
      try
         put the pObjectTestProp of targetObject into objectRefValue
         put toolModeArray [pObjectTestProp][objectRefValue] into mPluginArray
         return mPluginArray
      catch someError
         breakPoint
         put the pObjectTestProp of targetObject into objectRefValue
      end try
   end repeat
   return empty
end menu_PluginArray

setprop menu_PluginArray [pToolMode] mPluginArray
   put the long id of the target into targetObject
   
   menu_SetPluginArray targetObject, mPluginArray, pToolMode
   return the result
end menu_PluginArray

command menu_SetPlugin targetObject, modifierKey, gMenuTitle, pBeforeLineNum, pPassMouseDown
   put gMenuTitle into mRecordArray ["mTitle"]
   put menu_GetGlobalController (gMenuTitle) into mController
   put the rugged_ID of mController into mRecordArray ["mController"]
   if pBeforeLineNum is empty then put 0 into pBeforeLineNum
   if pPassMouseDown is empty then put false into pPassMouseDown
   put pBeforeLineNum into mRecordArray ["mBeforeLineNum"]
   put pPassMouseDown into mRecordArray ["mPassMouseDown"]
   put mRecordArray into mPluginArray [1]  -- now set plugin (not add)
   
   menu_SetPluginArray targetObject, mPluginArray, pToolMode
end menu_SetPlugin

command menu_AddPlugin targetObject, modifierKey, gMenuTitle, pBeforeLineNum, pPassMouseDown
   put gMenuTitle into mRecordArray ["mTitle"]
   put menu_GetGlobalController (gMenuTitle) into mController
   -- put the main_Name of mController into mRecordArray ["mController"]
   put the rugged_ID of mController into mRecordArray ["mController"]
   
   if pBeforeLineNum is empty then put 0 into pBeforeLineNum
   if pPassMouseDown is empty then put false into pPassMouseDown
   
   put pBeforeLineNum into mRecordArray ["mBeforeLineNum"]
   put pPassMouseDown into mRecordArray ["mPassMouseDown"]
   
   put the menu_PluginArray [modifierKey] of targetObject into mPluginArray
   put item 2 of the extents of mPluginArray + 1 into indexNum
   put mRecordArray into mPluginArray [indexNum]
   
   -- set the menu_PluginArray [modifierKey] of targetObject to mPluginArray
   menu_SetPluginArray targetObject, mPluginArray, modifierKey
end menu_AddPlugin

command menu_SetPluginArray targetObject, mPluginArray, pToolMode, pObjectTestProp
   global gOPN_MenuArray
   if pObjectTestProp is empty then put "main_Name" into pObjectTestProp -- use main_Name as default as this is what is needed by revScriptEditor and faster to have only one prop to search
   
   if mPluginArray is not an array then
      put the pObjectTestProp of targetObject into objectRefValue
      menu_DeletePluginRecord pToolMode, pObjectTestProp, objectRefValue 
   else
      put the pObjectTestProp of targetObject into objectRefValue
      put mPluginArray into gOPN_MenuArray [pToolMode][pObjectTestProp][objectRefValue]      
      return gOPN_MenuArray
   end if
end menu_SetPluginArray

-- getprop menu_PluginTable [pToolMode]
   put the menu_PluginArray [pToolMode] of the target into mPluginArray
   put item 2 of the extents of mPluginArray into maxNum
   repeat with indexNum = 1 to maxNum
      put mPluginArray [indexNum] into mRecordArray
      menu_ConvertArrayToRecord mRecordArray
      put mRecordArray & CR after mRecordTable
   end repeat
   delete char -1 of mRecordTable   
   return mRecordTable
end menu_PluginTable

setprop menu_PluginTable [pToolMode] menuRecord
   menu_ConvertRecordToArray menuRecord
   put menuRecord into mPluginArray [1]
   set the menu_PluginArray [pToolMode] of the target to mPluginArray
   return the result
end menu_PluginTable

command menu_ConvertRecordToArray @mRecord
   local mRecordArray
   if menuRecord is an array then return false
   set the itemdelimiter to tab
   put item 1 of mRecord into mRecordArray ["mTitle"]
   put item 2 of mRecord into mRecordArray ["mController"]
   put item 3 of mRecord into mRecordArray ["mBeforeLineNum"]
   put item 4 of mRecord into mRecordArray ["mPassMouseDown"]
   put mRecordArray into mRecord
   return true
end menu_ConvertRecordToArray

command menu_ConvertArrayToRecord @mRecordArray
   if mRecordArray is not an array then return false
   set the itemdelimiter to tab
   put mRecordArray ["mTitle"] into item 1 of mRecord
   put mRecordArray ["mController"] into item 2 of mRecord
   put mRecordArray ["mBeforeLineNum"] into item 3 of mRecord
   put mRecordArray ["mPassMouseDown"] into item 4 of mRecord
   put mRecord into mRecordArray
   return true
end menu_ConvertArrayToRecord

command menu_NormalizePluginArray @mPluginArray
   put item 2 of the extents of mPluginArray into maxNum
   repeat with indexNum = 1 to maxNum
      put mPluginArray [indexNum] into mRecordArray
      menu_NormalizeRecordArray mRecordArray
      put mRecordArray into mPluginArray [indexNum]
   end repeat
end menu_NormalizePluginArray

command menu_NormalizeRecordArray @mRecordArray
   if mRecordArray is not an array then return false
   set the itemdelimiter to tab
   put mRecordArray ["mTitle"] into mTitle
   put mRecordArray ["mController"] into mController
   
   if exists (mController) is false then
      put empty into mRecordArray
      return false
   end if
   put menu_CheckTitleController (mTitle, mController) into mTitleIsThere
   if mTitleIsThere is false then
      put empty into mRecordArray
      return false
   end if
   
   -- put the main_Name of mController into mRecordArray ["mController"] 
   return true
end menu_NormalizeRecordArray

function menu_ConstructPluginRecord menuController, menuTitle, beforeLineNum, passMouseDown
   -- was "menu_ConstructNamedRecord"
   -- used by menu front script
   
   set the itemdelimiter to tab
   put menuTitle into item 1 of menuRecord
   put menuController into item 2 of menuRecord
   put beforeLineNum into item 3 of menuRecord
   put passMouseDown into item 4 of menuRecord
   return menuRecord
end menu_ConstructPluginRecord

on menu_DeconstructPluginRecord menuRecord, @menuController, @mTitle, @beforeLineNum, @passMouseDown
   -- was "menu_DeconstructNamedRecord"
   set the itemdelimiter to tab
   put item 1 of menuRecord into mTitle
   put item 2 of menuRecord into mController
   put item 3 of menuRecord into beforeLineNum
   put item 4 of menuRecord into passMouseDown
end menu_DeconstructPluginRecord

on menu_DeletePluginRecord toolMode, pObjectTestProp, objectRefValue
   global gOPN_MenuArray
   if pObjectTestProp is empty then put "object_ShortID" into pObjectTestProp
   
   put gOPN_MenuArray [toolMode] into propertyArray
   put propertyArray [pObjectTestProp] into recordArray
   
   delete local recordArray [objectRefValue]
   
   put recordArray into propertyArray [pObjectTestProp]
   put propertyArray into gOPN_MenuArray [toolMode]
   
   return keys (gOPN_MenuArray)
end menu_DeletePluginRecord

getprop object_ShortID
   -- used as a default property to identify objects (should use rugged_ID)
   return the short id of the target
end object_ShortID


--> Menu | Model | Table
-
/*
Stored in the menu_DataArray - mDataArray [mTitle], or mArray [mTitle]
*/

-- getprop menu_Table [pMenuTitle]
   if pMenuTitle is empty then put the menu_Title of the target into pMenuTitle
   if pMenuTitle is empty then return empty
   put the menu_Controller [pMenuTitle] of the target into mController
   
   put menu_GetTable (pMenuTitle, mController) into mTable
   return mTable
end menu_Table

function menu_TableArrayHeaders
   return "mLine,mType,pigeon,mTitle,mController,disabledProp,submenuGetProp,checkedGetProp,submenuTitle,submenuController"
end menu_TableArrayHeaders

getprop menu_TableArray [pMenuTitle]
   -- put the menu_Table [pMenuTitle] of the target into mTable
   if pMenuTitle is empty then put the menu_Title of the target into pMenuTitle
   if pMenuTitle is empty then return empty
   put the menu_Controller [pMenuTitle] of the target into mController
   
   put menu_GetDataArray (mController) into dataArray
   put dataArray [pMenuTitle] into mTable
   
   set the itemdelimiter to tab
   repeat with lineNum = 1 to the number of lines of mTable
      put line lineNum of mTable into someLine
      
      put item 1 of someLine into mLine
      put item 6 of someLine into mType
      
      if mType is empty then put "no params" into mType
      
      if mLine is "-" then
         put "-" into mTableArray [lineNum]["mType"]
         next repeat
      else
         put mType into mTableArray [lineNum]["mType"]
      end if
      
      switch mType
         case "insert"
            put item 7 of someLine into mTableArray [lineNum]["submenu_Title"]
            _AddObjectToArray "submenu_Controller", 8, lineNum, mTableArray, someLine
            break
         case "submenu"
            put mLine into mTableArray [lineNum]["mLine"]
            
            put item 7 of someLine into mTableArray [lineNum]["submenu_Title"]
            _AddObjectToArray "submenu_Controller", 8, lineNum, mTableArray, someLine
            break
         case "boolean"
            put mLine into mTableArray [lineNum]["mLine"]
            put item 2 of someLine into mTableArray [lineNum]["pigeon"]
            
            _AddToArray "submenu_CheckedProp", 8, lineNum, mTableArray, someLine
            break
         case "fixed"
            put mLine into mTableArray [lineNum]["mLine"]
            put item 2 of someLine into mTableArray [lineNum]["pigeon"]
            
            _AddToArray "submenu_GetProp", 7, lineNum, mTableArray, someLine
            break
         case "custom submenu"
            --  if script_GetGetProp(getPropName, someScript) is not empty
            -- there is a getprop submenuProp handler in the mController script
            put mLine into mTableArray [lineNum]["mLine"]
            put item 2 of someLine into mTableArray [lineNum]["pigeon"]
            
            _AddToArray "submenu_GetProp", 7, lineNum, mTableArray, someLine
            _AddToArray "submenu_CheckedProp", 8, lineNum, mTableArray, someLine
            break
         case "custom external"
            put mLine into mTableArray [lineNum]["mLine"]
            put item 2 of someLine into mTableArray [lineNum]["pigeon"]
            
            _AddToArray "submenu_GetProp", 7, lineNum, mTableArray, someLine
            _AddToArray "submenu_CheckedProp", 8, lineNum, mTableArray, someLine
            break
         default -- case "no params"
            put mLine into mTableArray [lineNum]["mLine"]
            put item 2 of someLine into mTableArray [lineNum]["pigeon"]
      end switch
      
      _AddObjectToArray "mController", 3, lineNum, mTableArray, someLine
      put item 4 of someLine into mTableArray [lineNum]["mTitle"]
      
      _AddToArray "disabledProp", 5, lineNum, mTableArray, someLine
      
      -- put item 9 of someLine into mTableArray [lineNum]["mSendLine"]  -- what is this for?
   end repeat
   return mTableArray
end menu_TableArray

function menu_GetDataArray mController
   put the customproperties ["menu_Table"] of mController into mDataArray
   return mDataArray
end menu_GetDataArray

command menuTableArray_AddBoolean @mTableArray, lineNum, mLine, mController, pigeon, pCheckedProp, pDisabledProp
   put "boolean" into mTableArray [lineNum]["mType"]
   
   put mLine into mTableArray [lineNum]["mLine"]
   put pigeon into mTableArray [lineNum]["pigeon"]
   
   put mController into mTableArray [lineNum]["mController"]
   
   if pCheckedProp is not empty then put pCheckedProp into mTableArray [lineNum]["submenu_CheckedProp"]
   if pDisabledProp is not empty then put pDisabledProp into mTableArray [lineNum]["disabledProp"]
end menuTableArray_AddBoolean

command menuTableArray_AddPlain @mTableArray, lineNum, mLine, mController, pigeon, pDisabledProp
   put "plain" into mTableArray [lineNum]["mType"]
   
   put mLine into mTableArray [lineNum]["mLine"]
   put pigeon into mTableArray [lineNum]["pigeon"]
   
   put mController into mTableArray [lineNum]["mController"]
   
   if pDisabledProp is not empty then put pDisabledProp into mTableArray [lineNum]["disabledProp"]
end menuTableArray_AddPlain

private command _AddToArray someKey, itemNum, lineNum, @mTableArray, someLine
   set the itemdelimiter to tab
   put item itemNum of someLine into someProp
   if someProp is not empty then put someProp into mTableArray [lineNum][someKey]
end _AddToArray

private command _AddObjectToArray someKey, itemNum, lineNum, @mTableArray, someLine
   set the itemdelimiter to tab
   put item itemNum of someLine into someObject
   put the rugged_ID of someObject into mTableArray [lineNum][someKey]
end _AddObjectToArray
