script "model_GlobalMenu"
--> MetaData
-
license: GPLv3
name: model_GlobalMenu
type: model
version: 0.7


--> Working on
-
/*
"menu_GetTable" is used by "menu_IncludeMenuText" and "menu_IncludeMenuText", 
and therefore "menu_PopUp" etc depends on them.

So moved this suite here for now from "model_ScriptMenu" to reduce dependencies
*/

getprop menu_Table [pMenuTitle]
   put the long id of the target into tObject
   if pMenuTitle is empty then put the menu_Title of tObject into pMenuTitle
   if pMenuTitle is empty then return empty
   
   if word 1 of pMenuTitle = "Global" and word 2 of pMenuTitle = "|" then
      put menu_GetGlobalTable (pMenuTitle) into mTable
      return mTable
   else
      put the menu_Controller [pMenuTitle] of tObject into mController
      if exists (mController) is false then put tObject into mController
      put the menu_DataArray of mController into menuTableArray
      put menuTableArray [pMenuTitle] into mTable
      
      -- hack
      -- fix local contrllers in cases where the object has been copied to another stack
      set the itemdelimiter to tab
      repeat for each line mTableLine in mTable
         put mController into item 3 of mTableLine
         put mTableLine & CR after fixedLocalMenuTable
      end repeat
      delete char -1 of fixedLocalMenuTable
      return fixedLocalMenuTable
   end if
end menu_Table


--> Menu | Global | Model
-
function menu_GetGlobalController gMenuTitle
   put menu_GetModel() into gMenuModel
   put gMenuModel [gMenuTitle]["mController"] into mController
   return mController
end menu_GetGlobalController

command menu_SetGlobalController gMenuTitle, scriptObject
   put menu_GetModel() into gMenuModel
   put the rugged_ID of scriptObject into gMenuModel [gMenuTitle]["mController"]
   menu_SetModel gMenuModel
   return the result
end menu_SetGlobalController

command menu_RemoveGlobalController gMenuTitle
   put menu_GetModel() into gMenuModel
   put gMenuModel [gMenuTitle]["mController"] into mController
   delete variable gMenuModel [gMenuTitle]
   menu_SetModel gMenuModel
   return mController
end menu_RemoveGlobalController


--> Menu | Global | Model | Array
-
function menu_GetGlobalData pFilterText
   put menu_GetModel() into mGlobalArray
   --
   set the itemdelimiter to "|"
   repeat for each key gMenuTitle in mGlobalArray
      set the cursor to busy
      --
      if pFilterText is not empty then
         put item 2 to -2 of gMenuTitle into mBit
         put mBit contains pFilterText into isGood
         if isGood is false then
            next repeat
         end if
      end if
      
      put mGlobalArray [gMenuTitle] into mData [gMenuTitle]
      put mData [gMenuTitle]["mController"] into mController
      if exists (mController) is false then
         put empty into mData [gMenuTitle]["stack name"]
      else
         put the project_Name of mController into mData [gMenuTitle]["project_Name"]
         put the short name of mController into mData [gMenuTitle]["stack name"]
      end if
   end repeat
   --
   return mData
end menu_GetGlobalData

function menu_GetGlobalTitleArray gMenuTitle
   -- should rename menu_GetArray
   put menu_GetModel() into gMenuModel
   put gMenuModel [gMenuTitle] into gMenuArray
   return gMenuArray
end menu_GetGlobalTitleArray

command menu_SetGlobalTitleArray gMenuTitle, gMenuArray
   -- should rename menu_SetArray
   put menu_GetModel() into gMenuModel
   put gMenuArray into gMenuModel [gMenuTitle]
   menu_SetModel gMenuModel
   return gMenuModel
end menu_SetGlobalTitleArray

function menu_GetModel
   global gLCW
   put gLCW ["Global Menus"] into menuGlobalArray
   return menuGlobalArray
end menu_GetModel

command menu_SetModel menuGlobalArray
   global gLCW
   put menuGlobalArray into gLCW ["Global Menus"]
   return gLCW ["Global Menus"]
end menu_SetModel


--> Menu | Global | Model | Utils
-
function menu_ListGlobalTitles
   put menu_GetModel() into gMenuModel
   put keys (gMenuModel) into gMenuNames
   sort gMenuNames
   return gMenuNames
end menu_ListGlobalTitles

function menu_GlobalControllerExists gMenuTitle
   put menu_GetGlobalController (gMenuTitle) into mController
   return exists (mController)
end menu_GlobalControllerExists


--> Menu | Global | Table
-
function menu_GetTable mTitle, mController
   if word 1 of mTitle = "Global" and word 2 of mTitle = "|" then
      put menu_GetGlobalTable (mTitle) into mTable
      -- menu_FixGlobalTitleArray mTable, mTitle
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

function menu_ListCustomPropertyTitles mController
   put the menu_DataArray of mController into menuTableArray
   put keys (menuTableArray) into tableTitles
   return tableTitles
end menu_ListCustomPropertyTitles


--> Menu | Global | Titles
-
function menu_GlobalTitles pFilter
   put menu_ListGlobalTitles() into globalTitles
   if pFilter is not empty then filter globalTitles with pFilter
   return globalTitles
end menu_GlobalTitles

function menu_GlobalControllers pFilter
   put script_GetGlobalSuiteObjects ("Menu") into gMenuControllers
   if pFilter is not empty then filter gMenuControllers with pFilter
   return gMenuControllers
end menu_GlobalControllers

function menu_GlobalControllers pObjectFormat
   put menu_ConstructGlobalControllerArray (pObjectFormat) into menuObjectArray
   return keys (menuObjectArray)
end menu_GlobalControllers

function menu_ConstructGlobalControllerArray pObjectFormat
   put menu_GlobalTitles() into globalTitles
   repeat for each line globalTitle in globalTitles
      put menu_GetGlobalController (globalTitle) into someObject
      if exists (someObject) then
         if pObjectFormat is not empty then
            put the pObjectFormat of someObject into someObject
         end if
         array_AddToIndex globalTitle, someObject, menuObjectArray
      end if
   end repeat
   return menuObjectArray
end menu_ConstructGlobalControllerArray


--> Menu | Global | TitleTableArray | Model
-
function menu_GetGlobalTable gMenuTitle
   put menu_GetGlobalTitleArray (gMenuTitle) into gMenuTitleArray
   put gMenuTitleArray ["gMenuTable"] into gMenuTable
   
   -- menu_FixGlobalTitleArray gMenuTable, gMenuTitle
   return gMenuTable
end menu_GetGlobalTable

function menu_GetTable mTitle, mController
   if word 1 of mTitle = "Global" and word 2 of mTitle = "|" then
      put menu_GetGlobalTable (mTitle) into mTable
      -- menu_FixGlobalTitleArray mTable, mTitle
   else
      put the menu_DataArray of mController into menuTableArray
      put menuTableArray [mTitle] into mTable
   end if
   return mTable
end menu_GetTable

command menu_SetGlobalTable gMenuTitle, gMenuTable
   put menu_GetGlobalTitleArray (gMenuTitle) into gMenuTitleArray
   put gMenuTable into gMenuTitleArray ["gMenuTable"]
   menu_SetGlobalTitleArray gMenuTitle, gMenuTitleArray
   return mTitleTable
end menu_SetGlobalTable


--> Menu | Global | Model | Utils
-
function menu_TitlePathFromPath mPath
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   return mTitlePath
end menu_TitlePathFromPath
