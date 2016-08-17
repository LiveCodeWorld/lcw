script "model_GlobalMenu"
--> MetaData
-
license: GPLv3
name: model_GlobalMenu
type: model
version: 0.7


--> Menu | Array
-
function menu_GetTargetObject
   global gTemp_ActiveMenuArray
   put gTemp_ActiveMenuArray ["top"]["targetObject"] into targetObject
   return targetObject
end menu_GetTargetObject

command menu_SetTargetObject targetObject
   -- the target clicked on by the user
   global gTemp_ActiveMenuArray
   put targetObject into gTemp_ActiveMenuArray ["top"]["targetObject"]
end menu_SetTargetObject

function menu_ControllerFromTitlePath mTitlePath
   global gTemp_ActiveMenuArray
   put gTemp_ActiveMenuArray ["mTitlePath"][mTitlePath]["mController"] into mController
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
   global gTemp_ActiveMenuArray
   put gTemp_ActiveMenuArray ["sent"]["mPath"] into mPath
   return mPath
end menu_GetSentPath

command menu_SetSentPath mPath
   global gTemp_ActiveMenuArray
   put mPath into gTemp_ActiveMenuArray ["sent"]["mPath"]
end menu_SetSentPath

function menu_GetSentTitlePath
   -- could be called "menu_GetSentTitlePath"
   global gTemp_ActiveMenuArray
   put gTemp_ActiveMenuArray ["sent"]["mTitlePath"] into sentMenuPath
   return sentMenuPath
end menu_GetSentTitlePath

command menu_SetTitlePath mTitlePath
   -- could be called "menu_SetSentTitlePath"
   global gTemp_ActiveMenuArray
   put mTitlePath into gTemp_ActiveMenuArray ["sent"]["mTitlePath"]
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
-- function menu_GetTopController
-- could probably work out from mTitlePath (by getting first items mController)
global gTemp_ActiveMenuArray
put gTemp_ActiveMenuArray ["top"]["mController"] into mTopController
return mTopController
end menu_GetTopController

command menu_SetTopController mTopController
   global gTemp_ActiveMenuArray
   put mTopController into gTemp_ActiveMenuArray ["top"]["mController"]
end menu_SetTopController

function menu_GetTopTitle
   global gTemp_ActiveMenuArray
   put gTemp_ActiveMenuArray ["top"]["mTitlePath"] into mTopTitle
   return mTopTitle
end menu_GetTopTitle

command menu_SetTopTitle mTopTitle
   global gTemp_ActiveMenuArray
   put mTopTitle into gTemp_ActiveMenuArray ["top"]["mTitlePath"]
end menu_SetTopTitle


--> Menu | Active | Model
-
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

function menu_TitleIsGlobal mTitle
   -- here in case we nee to change mTitle to start with "Menu" rather than end
   set the itemDelimiter to "|"
   return word 1 to -1 of item 1 of mTitle is "Global"
end menu_TitleIsGlobal


--> Menu | Global | Model
-
function menu_ListGlobalTitles
   global gLCW
   
   put keys (gLCW ["Global Menus"]) into gMenuNames
   sort gMenuNames
   return gMenuNames
end menu_ListGlobalTitles

function menu_GetGlobalController gMenuTitle
   -- was "menu_GlobalController"
   put menu_GetGlobalArray() into gMenuHkeyArray
   put gMenuHkeyArray [gMenuTitle]["mController"] into mController
   return mController
end menu_GetGlobalController

command menu_SetGlobalController gMenuTitle, scriptObject
   put menu_GetGlobalArray() into gMenuHkeyArray
   put the rugged_ID of scriptObject into gMenuHkeyArray [gMenuTitle]["mController"]
   menu_SetGlobalArray gMenuHkeyArray
   return the result
end menu_SetGlobalController


--> Menu | Update
-
setprop menu_Update someBoolean
   -- let's fix and index the menus 
   -- should change to be done / use the work done above
   put the long id of the target into scriptObject
   
   put the script_MenuTitleTableArray of scriptObject into mTitleTableArray
   if mTitleTableArray is not an array then return empty
   
   if someBoolean is true then
      set the menu_DataArray of scriptObject to mTitleTableArray -- local
   end if
   
   -- now update Global menus
   repeat for each key gMenuTile in mTitleTableArray
      if word 1 of gMenuTile = "Global" and word 2 of gMenuTile = "|" then
         put mTitleTableArray [gMenuTile] into gMenuTable
         put gMenuTable into menuTitleArray [gMenuTile]["gMenuTable"]
         put scriptObject into menuTitleArray [gMenuTile]["mController"]
      end if
   end repeat
   
   if someBoolean is true then
      -- menu_SetGlobalTable gMenuTile, gMenuTable
      put menu_GetGlobalArray() into gMenuTitleArray
      union menuTitleArray with gMenuTitleArray
      menu_SetGlobalArray menuTitleArray
   end if
   
   return menuTitleArray
end menu_Update

getprop menu_Update
   local menuTitleArray
   
   put the script_MenuTitleTableArray of the target into mTitleTableArray
   repeat for each key gMenuTile in mTitleTableArray
      if word 1 of gMenuTile = "Global" and word 2 of gMenuTile = "|" then
         put mTitleTableArray [gMenuTile] into gMenuTable
         -- menu_SetGlobalTable gMenuTile, gMenuTable
         put gMenuTable into menuTitleArray ["gMenuTable"]
      end if
   end repeat
   return menuTitleArray
end menu_Update


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

function menu_GetGlobalArray
   global gLCW
   put gLCW ["Global Menus"] into menuGlobalArray
   return menuGlobalArray
end menu_GetGlobalArray

command menu_SetGlobalArray menuGlobalArray
   global gLCW
   put menuGlobalArray into gLCW ["Global Menus"]
   return gLCW ["Global Menus"]
end menu_SetGlobalArray

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

private command _UpdateOldGlobalMenu mController
   -- a temp hack
   put gLCW ["scriptArray"][mController]["data"]["menuDataArray"] into oldTitleTableArray
   if oldTitleTableArray is an array then
      breakpoint
      -- update it
      breakpoint
      delete variable gLCW ["scriptArray"][mController]["data"]["menuDataArray"]
      menu_SetTitleTableArrayGlobal mController, oldTitleTableArray
      return oldTitleTableArray
   end if
end _UpdateOldGlobalMenu


--> Menu | Global | Model | Utils
-
function menu_TitlePathFromPath mPath
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   return mTitlePath
end menu_TitlePathFromPath
