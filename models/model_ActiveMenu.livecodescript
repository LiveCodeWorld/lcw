script "model_ActiveMenu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_ActiveMenu
type: model
version: 0.1

/*
Most of the handlers in this menu can be retired.

This model stores teh state of an active menu. It is old and uses the gLCW global.
We have now started using lib_MenuArray which deals with representing individual menus as arrays (mArray), and stores temporary active state.
The model also stores "paths" to the active menu.
We no longer do this as it is complicated, and we get most of the benefits by using menu properties.
*/

--> Menu | Active | Model
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
   
   put menu_GetTopTargetObject() into targetObject
   put targetObject into tArray ["targetObject"]
end menu_GetSentArray

function menu_GetActiveText
   global gLCW
   return gLCW ["activeMenuArray"]["menu"]["text"]
end menu_GetActiveText

command menu_SetActiveText mText
   global gLCW
   put mText into gLCW ["activeMenuArray"]["menu"]["text"]
end menu_SetActiveText

function menu_ControllerFromTitlePath mTitlePath
   global gLCW
   put gLCW ["activeMenuArray"]["mTitlePath"][mTitlePath]["mController"] into mController
   return mController
end menu_ControllerFromTitlePath
