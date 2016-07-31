script "model_ScriptMenu"
--> MetaData
-
license: GPLv3
name: model_ScriptMenu
type: model
version: 0.9

/*
The menu model is in transition, and is still using the old "table" baes data structure.
Currently in the process of moving over to the new array based structure which should be more readable, maintainable and faster.

A menu_Controller contains all the information needed to create a menu, and link each menu item to a handler.
Views are linked to menu_Controllers via the menu_Title and the menu_Controller of the view.
This combination of mTitle and mController uniquely identifies the menu model for that menu and it's associated script.

This model can be referenced by a property of the menu_Target called "the menu_Array".
The actual data is stored as a custom property of the menu_Controller, but in future could use other methods.

As a model it contains the usual structure:  data, display data and metadata
You can access the various components of the menu model with the following properties:

menu_DataArray = a single array containing the menu_Tables of all the views it is linked to (usually the card views)
menu_DisplayArray= display data, translations and other formattng of the menu (not used yet)
menu_MetaDataArray = information, help etc associated with a menu. Things like menu_HelpUrl

Each individual menu has an associated mTable. The majority of the handlers that create and display dynamic menus act on the menu_Table:

-  menu_Table = data about a single menu stored as part of menu_DataArray

The storage of the actual data differs slightly from a normal array based model in that:

-  menu_DataArray does not use [mTitle]["Data"] but instead it's own custom property  set "menu_Table"
-  menu_DisplayArray will use [mTitle]["Display"]
-  menu_MetaDataArray uses [mTitle]["MetaData"]
*/


--> Menu | Models | MetaData
-
function menu_GetTable mTitle, mController
   put menu_GetDataArray (mController) into dataArray
   put dataArray [mTitle] into mTable
   return mTable
end menu_GetTable

command menu_SetTable mTitle, mController, mTable
   put menu_GetDataArray (mController) into dataArray
   if mTable is empty then
      delete local dataArray [mTitle]
   else
      put mTable into dataArray [mTitle]
   end if
   menu_SetDataArray mController, dataArray
   return dataArray
end menu_SetTable

function menu_GetDataArray mController
   -- we look at custom props first
   -- then check the hArray
   
   put the customproperties ["menu_Table"] of mController into mTitleTableArray
   if mTitleTableArray is empty then
      put menu_GetTitleTableArrayGlobal (mController) into mTitleTableArray
   else
      -- here we could add it to hArray 
   end if   
   menu_SetTitleTableArrayGlobal mController, mTitleTableArray
   return mTitleTableArray
end menu_GetDataArray

command menu_SetDataArray mController, mTitleTableArray
   if mTitleTableArray is empty then return empty
   
   -- here we start creating a new global array model for menu tables
   menu_SetTitleTableArrayGlobal mController, mTitleTableArray
   
   -- if it is a script-only stack then these changes won't stick
   set the customproperties ["menu_Table"] of mController to mTitleTableArray
   return mTitleTableArray
end menu_SetDataArray

function menu_GetTitleTableArrayGlobal mController
   global gHkey_Array
   
   put the rugged_ID of mController into mController
   
   -- a temp hack
   put gHkey_Array ["scriptArray"][mController]["data"]["menuDataArray"] into oldTitleTableArray
   if oldTitleTableArray is an array then
      -- update it
      delete variable gHkey_Array ["scriptArray"][mController]["data"]["menuDataArray"]
      menu_SetTitleTableArrayGlobal mController, oldTitleTableArray
      return oldTitleTableArray
   end if
   
   put gHkey_Array ["scriptArray"][mController]["data"]["mTitleTableArray"] into mTitleTableArray
   return mTitleTableArray
end menu_GetTitleTableArrayGlobal

command menu_SetTitleTableArrayGlobal mController, mTitleTableArray
   /*
   mTitleTableArray is a simple array with keys corresponding to mTitles, and values corresponding to mControllers
   */
   global gHkey_Array
   if mTitleTableArray is not an array then return gHkey_Array
   
   put the rugged_ID of mController into mController
   put mTitleTableArray into gHkey_Array ["scriptArray"][mController]["data"]["mTitleTableArray"]
   return gHkey_Array
end menu_SetTitleTableArrayGlobal


--> Menu Model | Global
-
function menu_GetGlobalController globalMenuTitle
   -- was "menu_GlobalController"
   put menu_GetGlobalArray() into gMenuHkeyArray
   put gMenuHkeyArray [globalMenuTitle]["mController"] into mController
   return mController
end menu_GetGlobalController

command menu_SetGlobalController globalMenuTitle, scriptObject
   put menu_GetGlobalArray() into gMenuHkeyArray
   put the rugged_ID of scriptObject into gMenuHkeyArray [globalMenuTitle]["mController"]
   menu_SetGlobalArray gMenuHkeyArray
   return the result
end menu_SetGlobalController

function menu_GetGlobalArray
   global gHkey_Array
   put gHkey_Array ["Global Menus"] into gMenuHkeyArray
   return gMenuHkeyArray
end menu_GetGlobalArray

command menu_SetGlobalArray gMenuHkeyArray
   global gHkey_Array
   put gMenuHkeyArray into gHkey_Array ["Global Menus"]
   return gHkey_Array ["Global Menus"]
end menu_SetGlobalArray


--> Menu Model | Props
-
getprop menu_Array
   put the long id of the target into mController
   lock messages
   put the menu_Array of mController into mArray
   unlock messages
   return mArray
end menu_Array

setprop menu_Array mArray
   put the long id of the target into mController
   if mArray is empty then
      custom_DeleteProperty "menu_Array", mController
   else
      lock messages
      set the menu_Array of mController to mArray
      unlock messages
   end if
end menu_Array

getprop menu_MetaDataArray [mTitle]
   put the menu_Array of the target into mArray
   return mArray [mTitle]["metadata"]
end menu_MetaDataArray

setprop menu_MetaDataArray [mTitle] metaDataArray
   put the menu_Array of the target into mArray
   if metaDataArray is an array then
      put metaDataArray into mArray [mTitle]["metadata"]
   else
      delete variable mArray [mTitle]["metadata"]
   end if
   set the menu_Array of the target to mArray
   return mArray
end menu_MetaDataArray

getprop menu_DataArray
   put the long id of the target into mController
   put menu_GetDataArray (mController) into mDataArray
   return mDataArray
end menu_DataArray

setprop menu_DataArray mDataArray
   put the long id of the target into mController
   menu_SetDataArray mController, mDataArray
   return the result
end menu_DataArray

getprop script_MenuTitles
    put the script of the target into someScript
    put script_ExtractMenuSuiteTitles (someScript) into mTitles
    return mTitles
end script_MenuTitles

getprop menu_GlobalTitle
   put the script_GlobalTitles ["Menu"] of the target into globalMenuTitles
   return globalMenuTitles
end menu_GlobalTitle

setprop menu_GlobalTitle globalMenuTitles
   put the long id of the target into scriptObject
   repeat for each line globalMenuTitle in globalMenuTitles
      menu_SetGlobalController globalMenuTitle, scriptObject
   end repeat
end menu_GlobalTitle

getprop menu_TableTitles
   -- direct property of mController
   put the long id of the target into mController
   put menu_GetTableTitles (mController) into tableTitles
   return tableTitles
end menu_TableTitles

setprop menu_Table [pMenuTitle] mTable
   if pMenuTitle is empty then put the menu_Title of the target into pMenuTitle
   if pMenuTitle is empty then return empty
   put the menu_Controller [pMenuTitle] of the target into mController
   
   menu_SetTable pMenuTitle, mController, mTable
   return the result
end menu_Table

getprop menu_Help [mTitle]
   put the long id of the target into mController
   put the menu_Array of mController into mArray
   put mArray [mTitle]["metadata"]["help"]["menu"] into someHtml
   return someHtml
end menu_Help

setprop menu_Help [mTitle] someHtml
   put the long id of the target into mController
   put the menu_Array of mController into mArray
   put someHtml into mArray [mTitle]["metadata"]["help"]["menu"]
   set the menu_Array of mController to mArray
end menu_Help


--> Menu | Model
-
function menu_GetTableTitles mController
   put menu_GetDataArray (mController) into menuTableArray
   put keys(menuTableArray) into tableTitles
   return tableTitles
end menu_GetTableTitles

function menu_GetActiveText
   global gTemp_ActiveMenuArray
   return gTemp_ActiveMenuArray ["menu"]["text"]
end menu_GetActiveText

command menu_SetActiveText mText
   global gTemp_ActiveMenuArray
   put mText into gTemp_ActiveMenuArray ["menu"]["text"]
end menu_SetActiveText

function menu_GetTargetObject
   global gTemp_ActiveMenuArray
   put gTemp_ActiveMenuArray ["top"]["targetObject"] into targetObject
   return targetObject
end menu_GetTargetObject

function menu_GetTargetOveride mTitlePath, mPath
   put menu_GetItemTargetOveride (mPath) into mTarget
   if exists (mTarget) then return mTarget
   
   put menu_GetTitleTargetOveride (mTitlePath) into mTarget
   return mTarget
end menu_GetTargetOveride


--> Menu | Global | Titles
-
function menu_GlobalTitles pFilter
   put menu_ListGlobalNames() into globalTitles
   if pFilter is not empty then filter globalTitles with pFilter
   return globalTitles
end menu_GlobalTitles

function menu_GlobalControllers pFilter
   put script_GetGlobalSuiteObjects ("Menu") into gMenuControllers
   if pFilter is not empty then filter gMenuControllers with pFilter
   return gMenuControllers
end menu_GlobalControllers

function menu_TitleIsGlobal mTitle
   -- here in case we nee to change mTitle to start with "Menu" rather than end
   set the itemDelimiter to "|"
   return word 1 to -1 of item 1 of mTitle is "Global"
end menu_TitleIsGlobal


--> Menu | Model | Table | Titles
-
function menu_GetTableTitles mController
   put menu_GetDataArray (mController) into menuTableArray
   put keys(menuTableArray) into tableTitles
   return tableTitles
end menu_GetTableTitles

command menu_DeleteTables mController
   put the custompropertysets of mController into setNames
   line_Delete "uOPN_MenuTable", setNames
   set the custompropertysets of mController to setNames
end menu_DeleteTables


--> Help | Model
-
/*
These utility handlers provide access to menu help. 
This is useful not just for development, but also in providing help for the final product.
*/

function menu_GetItemHelp hName, mController
   put the menu_Array of mController into mArray
   put mArray [mTitle]["metadata"]["help"]["menu item"][hName] into someHtml
   return someHtml
end menu_GetItemHelp

command menu_SetItemHelp hName, mController, someHtml
   put the menu_Array of mController into mArray
   put someHtml into mArray [mTitle]["metadata"]["help"]["menu item"][hName]
   set the menu_Array of mController to mArray
end menu_SetItemHelp


--> Old
/*
Removing the old Global menu Suite code, as we have switched to hArray

getprop script_UpdateGlobalSuiteIndex
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   
   put script_ExtractGlobalTitles (someScript) into newSuiteTitles
   script_RemoveObjectFromSuiteArray scriptObject
   
   put the rugged_ID of scriptObject into scriptObject
   put empty into newArray
   repeat for each line suiteTitle in newSuiteTitles
      put scriptObject into newArray [suiteTitle]
   end repeat
   
   script_AddToGlobalSuiteArray newArray
   put the result into arrayKeyList
   return arrayKeyList
end script_UpdateGlobalSuiteIndex

command script_AddToGlobalSuiteArray newArray, modelObject
   -- this should be updated to take advantage of the new script_Array metadata
   if keys(newArray) is empty then return empty
   
   put script_GetGlobalSuiteArray() into dataArray
   array_AddNew newArray, dataArray
   -- union dataArray with newArray
   script_SetGlobalSuiteArray dataArray   
   return the result
end script_AddToGlobalSuiteArray

on script_RemoveObjectFromSuiteArray scriptObject
   if exists(scriptObject) is false then
      put merge("Error: cannot find object: [[scriptObject]]") into someError
      return the script_Error [someError] of me
   end if
   
   put script_GetGlobalSuiteArray() into dataArray
   repeat for each key suiteTitle in dataArray
      put dataArray [suiteTitle] into testObject
      if exists(testObject) is false or the long id of testObject is the long id of scriptObject then
         delete local dataArray [suiteTitle]
      end if
   end repeat
   script_SetGlobalSuiteArray dataArray
   return empty
end script_RemoveObjectFromSuiteArray

command script_UpdateGlobalSuiteIndex scriptObject, someScript, pSuiteTitles
   if pSuiteTitles is empty then put script_ExtractGlobalTitles (someScript) into pSuiteTitles
   script_RemoveObjectFromSuiteArray scriptObject	# but instead just delete all old references in index
   
   -- get the mobile_Name of scriptObject
   put the rugged_ID of scriptObject into scriptObject
   put empty into newArray
   repeat for each line suiteTitle in pSuiteTitles
      put scriptObject into newArray [suiteTitle]
   end repeat
   
   script_AddToGlobalSuiteArray newArray
   put the result into scriptGlobalSuites
   return scriptGlobalSuites
end script_UpdateGlobalSuiteIndex

function script_MenuTitleArrayFromSuiteTitles suiteTitles
    local menuTitleArray
    set the itemdelimiter to "|"
    put "Menu \((.*)\)" into regularExpression
    put empty into menuTitles
    repeat for each line suiteTitle in suiteTitles
        put word 1 to -1 of last item of suiteTitle into lastMenuItem
        if lastMenuItem is "Menu" then
            put suiteTitle & CR after menuTitles
            put "" into menuTitleArray [suiteTitle]
        else if matchtext(lastMenuItem, regularExpression, toolMode) is true then
            put suiteTitle & CR after menuTitles
            put toolMode into menuTitleArray [suiteTitle]
        end if
    end repeat
    delete last char of menuTitles
    put menuTitles into menuTitleArray ["OrderedMenuTitles"]
    return menuTitleArray
end script_MenuTitleArrayFromSuiteTitles

function script_MenuToolModeArray someScript
    local menuToolModeArray
    put script_GetSuiteTitles(someScript) into suiteTitles
    
    set the itemdelimiter to "|"
    put "Menu \((.*)\)" into regularExpression
    put empty into menuTitles
    set the wholematches to true
    repeat for each line suiteTitle in suiteTitles
        put word 1 to -1 of last item of suiteTitle into lastMenuItem
        if lastMenuItem is among the items of "Menu|Menus|Submenu|Submenus" then
            put suiteTitle & CR after menuTitles
            put empty into menuToolModeArray [suiteTitle]
        else if matchtext(lastMenuItem, regularExpression, toolMode) is true then
            put suiteTitle & CR after menuTitles
            put toolMode into menuToolModeArray [suiteTitle]
        end if
    end repeat
    delete last char of menuTitles
    put menuTitles into menuToolModeArray ["OrderedMenuTitles"]
    return menuToolModeArray
end script_MenuToolModeArray
*/
