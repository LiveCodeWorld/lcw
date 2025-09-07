script "Global | Data | Wiki | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Wiki | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_IconArray
   local fData
   put the name of me into mController
   put "Global | Data | Wiki | Menu" into mTitle
   --  
   if icon_FamilyExists ("Phosphor regular") AND the shiftkey is "Up" then
      iconData_AddStack fData, "menu_Local", mTitle, "Phosphor regular/bug beetle", "Local"
      --
      iconData_AddStack fData, "menu_Fedwiki", mTitle, "Phosphor regular/aperture", "Fedwiki"
      iconData_AddStack fData, "menu_Livecode", mTitle, "Phosphor regular/alien", "Livecode"
   else
      iconData_AddStack fData, "menu_Local", mTitle, "fontawesome/bug", "Local"
      --
      iconData_AddStack fData, "menu_Fedwiki", mTitle, "fontawesome/book", "Fedwiki"
      iconData_AddStack fData, "menu_Livecode", mTitle, "fontawesome/file text", "Livecode"
   end if
   
   if icon_FamilyExists ("octicons") AND the shiftkey is "Up" then
      iconData_AddStack fData, "menu_Hitchhiker", mTitle, "octicons/accessibility 16", "Hitchhiker"
   else
      iconData_AddStack fData, "menu_Hitchhiker", mTitle, "fontawesome/briefcase", "Hitchhiker"
   end if
   
   if icon_FamilyExists ("Phosphor regular") AND the shiftkey is "Up" then
      -- iconData_AddStack fData, "menu_Readme", mTitle, "Phosphor regular/biohazard", "Readme"
      iconData_AddStack fData, "menu_Readme", mTitle, "Phosphor regular/question", "Readme"
   else
      iconData_AddStack fData, "menu_Readme", mTitle, "fontawesome/question sign", "Readme"
   end if
   
   iconData_AddStack fData, "menu_Tools", mTitle, "fontawesome/cogs", "Tools"
   iconData_AddStack fData, "menu_Test", mTitle, "fontawesome/cog", "Test"
   
   return fData
end menu_IconArray

getprop menu_Target [tObject]
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private command _Refresh sView, pItemLabel
   put the footer_View of sView into footerView
   --
   put the menu_IconArray of me into iData
   if iData is not an array then
      put the menu_ItemArray of me into iData
   end if
   if pItemLabel is not empty then
      put indexArray_Find (iData, "label", pItemLabel) into iNum
      indexArray_Delete iData, iNum
   end if
   set the footer_Data of footerView to iData
   
   set the title_Menu of sView to "Global | Data | Wiki | Menu"
end _Refresh

getprop checked_NodeServer [sView]
   return wikiServer_NodeIsRunning()
end checked_NodeServer

private command _DisplayReadme sView, projectName
   put the browser_View of sView into browserView
   set the behavior_StackNames of browserView to "behavior_ViewTiddlyWiki"
   --
   set the tiddly_Readme of browserView to projectName
   set the title_Menu of browserView to "Global | TiddlyWiki | Basic | Menu"
   set the body_Type of browserView to "browser"
end _DisplayReadme

private command _DisplayWiki sView, wDomain, pTitle
   put the browser_View of sView into browserView
   if pTitle is empty then
      put "Welcome Visitors" into pTitle
   end if
   --
   switch
      case the shiftKey is "Down"
         put "https://" & wDomain into wikiURL
         set the displayed_Wiki of browserView to wikiURL
         break
      default
         set the page_Title [wDomain] of browserView to pTitle
   end switch
end _DisplayWiki


--> Global | Data | Wiki | Menu
-
on submenu_Wiki
   return "Global | Wiki | Browser | View | Menu"
end submenu_Wiki

on submenu_Tools
   return "Global | Wiki | Browser | Tools | Menu"
end submenu_Tools

on menu_Readme sView
   _DisplayReadme sView, "lcw_Wiki"
end menu_Readme

on menu_NodeServer mTarget
   if wikiServer_NodeIsRunning() is false then
      set the cursor to watch
      wikiServer_StartNode
      -- wait until wikiServer_NodeIsRunning()
      wait 50 ticks with messages
      --
      set the displayed_Wiki of mTarget to "http://localhost"
   else
      wikiServer_StopNode
      menu_Hitchhiker mTarget
   end if
end menu_NodeServer

on menu_Local sView
   if wikiServer_NodeIsRunning() is false then
      set the cursor to watch
      wikiServer_StartNode
      -- wait until wikiServer_NodeIsRunning()
      wait 50 ticks with messages
   end if
   
   set the displayed_Wiki of sView to "http://localhost"
end menu_Local

private on _
end _

on menu_Hitchhiker sView
   -- set the displayed_Wiki of sView to "https://david.hitchhikers.earth"
   _DisplayWiki sView, "david.hitchhikers.earth"
end menu_Hitchhiker

on menu_Fedwiki sView
   -- set the displayed_Wiki of sView to "https://fedwiki.club"
   _DisplayWiki sView, "fedwiki.club"
end menu_Fedwiki

on menu_Livecode sView
   -- set the displayed_Wiki of sView to "https://david.livecode.wiki"
   _DisplayWiki sView, "david.livecode.wiki"
end menu_Livecode

private on __
end __

on menu_Edit mTarget
   put the browser_View of mTarget into browserView
   --
   put the wiki_EditMode of browserView into sBoolean
   set the wiki_EditMode of browserView to (sBoolean is false) -- javascript error
end menu_Edit

on menu_Test sView
   put the browser_View of sView into browserView
   --
   get the last_PageInfo of browserView
   put item 1 of it into wikiDomain
   put item 2 of it into pSlug
   --
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   set the ghost_PageArray of browserView to pageArray
   
   /*
   put pageJson_Fetch (wikiDomain, pSlug) into pageJSON
   --
   -- put jsonImport (pageJSON) into pageArray
   -- put jsonExport (pageArray) into pageJSON
   --
   set the ghost_PageJson of browserView to pageJSON
   */
end menu_Test

on menu_Tools sView
   _Refresh sView
   --
   if the shiftKey is "Down" then
      put the view_Name of sView into viewName
      display_ModuleTools viewName
      if there is not a stack "Display Icon Data" then
         display_IconDialogue sView
      end if
   end if
end menu_Tools

on menu_StopNode mTarget
   # Experiment
   wikiServer_StopNode
   set the displayed_Wiki of mTarget to "https://david.livecode.wiki/view/welcome-visitors/view/local-proxy/view/localhost"
end menu_StopNode

private on ___
end ___

on menu_ConstructGetProp mTarget
   put the footer_View of mTarget into footerView
   put the footer_GetProp of footerView into sHandler
   --
   display_Script sHandler, "menu_IconArray"
end menu_ConstructGetProp

on menu_MenuTitle mTarget, mTitle
   set the title_Menu of mTarget to mTitle
end menu_MenuTitle

getprop menuTitle_Params [mTarget]
   -- return "Global | Data | Wiki | Menu"
   put the module_Object of mTarget into mView
   return the module_MenuTitles of mView
end menuTitle_Params

private on ____
end ____

on submenu_Dev
   return "Global | Data | Wiki | Dev | Menu"
end submenu_Dev
