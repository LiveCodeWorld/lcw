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


--> Menu | Array
-
function menu_GetTargetObject
   global gLCW
   put gLCW ["activeMenuArray"]["top"]["targetObject"] into targetObject
   return targetObject
end menu_GetTargetObject

command menu_SetTargetObject targetObject
   -- the target clicked on by the user
   global gLCW
   put targetObject into gLCW ["activeMenuArray"]["top"]["targetObject"]
end menu_SetTargetObject

function menu_ControllerFromTitlePath mTitlePath
   global gLCW
   put gLCW ["activeMenuArray"]["mTitlePath"][mTitlePath]["mController"] into mController
   return mController
end menu_ControllerFromTitlePath


--> Menu | Array | Sent
-
function menu_GetSentController
   put menu_GetSentPath() into mPath
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   return mController
end menu_GetSentController

function menu_GetSentTitle
   put menu_GetSentPath() into mSentPath
   menu_DeconstructPath mSentPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   set the itemdelimiter to "/"
   put item -1 of mTitlePath into sentMenuTitle
   return sentMenuTitle
end menu_GetSentTitle

function menu_GetSentPath
   global gLCW
   put gLCW ["activeMenuArray"]["sent"]["mPath"] into mPath
   return mPath
end menu_GetSentPath

command menu_SetSentPath mPath
   global gLCW
   put mPath into gLCW ["activeMenuArray"]["sent"]["mPath"]
end menu_SetSentPath

function menu_GetSentTitlePath
   global gLCW
   put gLCW ["activeMenuArray"]["sent"]["mTitlePath"] into sentMenuPath
   return sentMenuPath
end menu_GetSentTitlePath

command menu_SetTitlePath mTitlePath
   global gLCW
   put mTitlePath into gLCW ["activeMenuArray"]["sent"]["mTitlePath"]
end menu_SetTitlePath

function menu_GetSentArray mPath
   -- utility function (not really needed)
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   put mPath into tArray ["mPath"]
   put foundPath into tArray ["foundPath"]
   put mTitlePath into tArray ["mTitlePath"]
   put mController into tArray ["mController"]
   put mItemType into tArray ["mItemType"]
   put pigeon into tArray ["pigeon"]
   
   put menu_GetTargetObject() into targetObject
   put targetObject into tArray ["targetObject"]
end menu_GetSentArray


--> Menu | Array | Top
-
command menu_SetTopController mTopController
   global gLCW
   put mTopController into gLCW ["activeMenuArray"]["top"]["mController"]
end menu_SetTopController

function menu_GetTopTitle
   global gLCW
   put gLCW ["activeMenuArray"]["top"]["mTitlePath"] into mTopTitle
   return mTopTitle
end menu_GetTopTitle

command menu_SetTopTitle mTopTitle
   global gLCW
   put mTopTitle into gLCW ["activeMenuArray"]["top"]["mTitlePath"]
end menu_SetTopTitle


--> Menu | Active | Model
-
function menu_GetActiveText
   global gLCW
   return gLCW ["activeMenuArray"]["menu"]["text"]
end menu_GetActiveText

command menu_SetActiveText mText
   global gLCW
   put mText into gLCW ["activeMenuArray"]["menu"]["text"]
end menu_SetActiveText

function menu_GetTargetObject
   global gLCW
   put gLCW ["activeMenuArray"]["top"]["targetObject"] into targetObject
   return targetObject
end menu_GetTargetObject


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


--> Menu | Global | Model
-
function menu_ListGlobalTitles
   global gLCW
   
   put keys (gLCW ["Global Menus"]) into gMenuNames
   sort gMenuNames
   return gMenuNames
end menu_ListGlobalTitles

command menu_SetGlobalController gMenuTitle, scriptObject
   put menu_GetGlobalArray() into gMenuArray
   put the rugged_ID of scriptObject into gMenuArray [gMenuTitle]["mController"]
   menu_SetGlobalArray gMenuArray
   return the result
end menu_SetGlobalController


--> Menu | Global | TitleTableArray | Model
-
command  menu_FixGlobalTitleArray @gMenuTable, gMenuTitle
   if gMenuTable is empty then
      put the menu_Controller [gMenuTitle] of the target into mController
      put the menu_DataArray of mController into gMenuTitleArray
      put gMenuTitleArray [gMenuTitle] into gMenuTable
      
      -- now set it
      menu_SetGlobalTable gMenuTitle, gMenuTable
   end if
end menu_FixGlobalTitleArray

function menu_GetGlobalTable gMenuTitle
   put menu_GetGlobalTitleArray (gMenuTitle) into gMenuTitleArray
   put gMenuTitleArray ["gMenuTable"] into gMenuTable
   
   menu_FixGlobalTitleArray gMenuTable, gMenuTitle
   return gMenuTable
end menu_GetGlobalTable

command menu_SetGlobalTable gMenuTitle, gMenuTable
   put menu_GetGlobalTitleArray (gMenuTitle) into gMenuTitleArray
   put gMenuTable into gMenuTitleArray ["gMenuTable"]
   menu_SetGlobalTitleArray gMenuTitle, gMenuTitleArray
   return mTitleTable
end menu_SetGlobalTable

function menu_GetGlobalTitleArray gMenuTitle
   put menu_GetGlobalArray() into menuGlobalArray
   put menuGlobalArray [gMenuTitle] into gMenuTitleArray
   return gMenuTitleArray
end menu_GetGlobalTitleArray

command menu_SetGlobalTitleArray gMenuTitle, gMenuTitleArray
   put menu_GetGlobalArray() into menuGlobalArray
   put gMenuTitleArray into menuGlobalArray [gMenuTitle]
   menu_SetGlobalArray menuGlobalArray
   return gLCW
end menu_SetGlobalTitleArray

function menu_GetTitleTableArrayGlobal mController
   global gLCW
   put the rugged_ID of mController into mController
   
   put gLCW ["scriptArray"][mController]["data"]["mTitleTableArray"] into mTitleTableArray
   return mTitleTableArray
end menu_GetTitleTableArrayGlobal

command menu_SetTitleTableArrayGlobal mController, mTitleTableArray, suiteTitle
   /*
   mTitleTableArray is a simple array with keys corresponding to mTitles, and values corresponding to mControllers
   */
   global gLCW
   if mTitleTableArray is not an array then return gLCW
   put the rugged_ID of mController into mController
   
   put mTitleTableArray into gLCW ["scriptArray"][mController]["data"]["mTitleTableArray"]
   put mTitleTableArray into gLCW ["Global Menus"][suiteTitle]["data"]["mTitleTableArray"]
   
   return gLCW ["Global Menus"][suiteTitle]
   return gLCW ["scriptArray"][mController]
end menu_SetTitleTableArrayGlobal


--> Menu | Global | Model | Utils
-
function menu_TitlePathFromPath mPath
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   return mTitlePath
end menu_TitlePathFromPath
