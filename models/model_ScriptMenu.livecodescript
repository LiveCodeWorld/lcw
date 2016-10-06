script "model_ScriptMenu"
--> MetaData
-
license: GPLv3
name: model_ScriptMenu
type: model
version: 0.9

/*
The menu model is in transition, and is still using the old "table" based data structure.
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

--> Working on
-
getprop script_MenuTitles
   -- not used except "Global | Menu | Table | Menu" ?
   
   put the long id of the target into targetObject
   put the script of targetObject into someScript
   put script_ExtractMenuSuiteTitles (someScript) into mTitles
   return mTitles
end script_MenuTitles

function script_ExtractMenuSuiteTitles someScript
   put script_GetSuiteTitles (someScript) into suiteTitles
   put script_MenuTitleArrayFromSuiteTitles (suiteTitles) into menuTitleArray
   return menuTitleArray ["OrderedMenuTitles"]
end script_ExtractMenuSuiteTitles

function script_MenuTitleArrayFromSuiteTitles suiteTitles
   -- not the best way ?
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


--> Menu | Models | MetaData
-
function menu_GetTable mTitle, mController
   if word 1 of mTitle = "Global" and word 2 of mTitle = "|" then
      put menu_GetGlobalTable (mTitle) into mTable
      menu_FixGlobalTitleArray mTable, mTitle
   else
      put the menu_DataArray of mController into menuTableArray
      put menuTableArray [mTitle] into mTable
   end if
   return mTable
end menu_GetTable

command menu_SetTable mTitle, mController, mTable
   put the menu_DataArray of mController into menuTableArray
   if menuTableArray is empty then
      delete local menuTableArray [mTitle]
   else
      put mTable into menuTableArray [mTitle]
   end if
   set the menu_DataArray of mController to menuTableArray
   return menuTableArray
end menu_SetTable

function menu_GetTableTitles mController
   put the menu_DataArray of mController into menuTableArray
   put keys (menuTableArray) into tableTitles
   return tableTitles
end menu_GetTableTitles

getprop menu_DataArray
   put the customproperties ["menu_Table"] of the target into mTitleTableArray
   return mTitleTableArray
end menu_DataArray

setprop menu_DataArray mTitleTableArray
   set the customproperties ["menu_Table"] of the target to mTitleTableArray
end menu_DataArray


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


--> Old | Suite
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
      put merge("Error: cannot find object: scriptObject") into someError
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
