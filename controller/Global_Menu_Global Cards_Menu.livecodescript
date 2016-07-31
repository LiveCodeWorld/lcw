script "Global_Menu_Global Cards_Menu"
--> MetaData
-
license: GPLv3
name: Global_Menu_Global Cards_Menu
type: controller
version: 0.1

--> Variables
-
local LocalArray


--> Global | Menu | Global Cards | Menu
-
on menu_EditGlobalCard scriptObject, cardName
   edit the script of card cardName of stack "libOPN_Menus"
end menu_EditGlobalCard

-- on menu_InUse usedName
   edit the script of stack usedName
end menu_InUse

on _
end _

on menu_CreateGlobalCard originalMenuController, newGlobalTitle
   if newGlobalTitle is empty or newGlobalTitle is "Create" then
      put opn_Ask ("Create new global menu card?", "Global | ??? | Menu") into newGlobalTitle
   end if
   
   -- put rev_ScriptObject() into originalMenuController
   
   put the script of originalMenuController into someScript
   put script_GetSuite (newGlobalTitle, someScript) into globalMenuSuites
   
   if exists (card newGlobalTitle of stack "libOPN_Menus") is true then
      -- should not be!
      if globalMenuSuites is not empty then set the clipboarddata to globalMenuSuites
      opn_Notify "Copied menu script to clipboard.", true
      edit the script of card newGlobalTitle of stack "libOPN_Menus"
   else
      -- put script_DeleteSuite (newGlobalTitle, someScript) into newOriginalScript
      menu_DeleteTitleSuites newGlobalTitle, someScript
      put the result into globalMenuSuites
      
      set the defaultstack to "libOPN_Menus"
      create card newGlobalTitle
      put the long id of cd newGlobalTitle of stack "libOPN_Menus" into newGlobalMenuController
      display_Menus
      
      if globalMenuSuites is empty then
         -- put script_ConstructSuite ("Object", newScripts) into newSuite
         put menu_ConstructTemplateScript (newGlobalTitle) into globalMenuSuites
         set the script of newGlobalMenuController to globalMenuSuites
      else
         rev_CloseTab originalMenuController
         set the script of newGlobalMenuController to globalMenuSuites
         set the script of originalMenuController to someScript
         menu_CreateAndStoreTables originalMenuController
         -- rev_SetScriptEditorField someScript
         edit the script of originalMenuController
      end if
      
      -- reindex menu tables for orignal menu controller and new global menu card controller
      menu_CreateAndStoreTables newGlobalMenuController      
      -- update the displayed originalMenuController script, and edit the script of the new global menu card
      edit the script of newGlobalMenuController
      
      put "Created new global menu" && kwote(newGlobalTitle) into someComment
      opn_Notify someComment, true
   end if
end menu_CreateGlobalCard

on menu_DeleteGlobalCard scriptObject, cardName
   opn_Answer "Are you sure you want to delete this Global Menu card?"
   delete card cardName of stack "libOPN_Menus"
   display_Menus
end menu_DeleteGlobalCard

on _
end _

on menu_ReindexCards
   display_Menus
end menu_ReindexCards

on menu_ReExportGlobalMenus
   -- need to do it twice
   put the cardids of stack "libOPN_Menus" into mCardIDs
   repeat for each line mCardID in mCardIDs
      set the cursor to busy
      put the long id of card id mCardID of stack "libOPN_Menus" into mController
      set the exported_Script of mController to the script of mController
   end repeat
   
   repeat for each line mCardID in mCardIDs
      set the cursor to busy
      put the long id of card id mCardID of stack "libOPN_Menus" into mController
      set the exported_Script of mController to the script of mController
   end repeat
end menu_ReExportGlobalMenus


--> Global | Menu | Global Cards | Menu | Disabled
-
-- getprop disabled_ReindexGlobalMenus [mTarget]
   return true
end disabled_ReindexGlobalMenus


--> Global | Menu | Global Cards | Menu | Props
-
getprop m_Names
   -- seems to me that there may to many lines for a menu
   -- should filter for only good published menus?
   -- maybe a switch for different sets?
   
   put menu_GlobalTitles() into mNames
   -- put line 138 to -1 of mNames
   return line 1 to 138 of mNames
   display_Lines mNames, "menu_GlobalTitles()"
   return word 1 to -1 of mNames
end m_Names

-- getprop used_Names
   get the stacksinuse
   sort it
   return it
end used_Names

getprop card_Names
   -- can simply return too many for menu draw limits
   put the cardnames of stack "libOPN_Menus" into globalMenuCardNames
   sort globalMenuCardNames
   -- display_Lines globalMenuCardNames
   return globalMenuCardNames
end card_Names

getprop new_GlobalTitles
   local newGlobalTitles
   put LocalArray ["menu_ScriptTitles"] into mTitles
   put the cardnames of stack "libOPN_Menus" into mCardNames
   repeat for each line newGlobalTitle in mTitles
      if newGlobalTitle begins with "Global |" then
         if newGlobalTitle is not among the lines of mCardNames then
            put newGlobalTitle & CR after newGlobalTitles
         end if
      end if
   end repeat
   delete char -1 of newGlobalTitles
   if newGlobalTitles is not empty then put CR & "-,Create" after newGlobalTitles
   return newGlobalTitles
end new_GlobalTitles


--> Menu | Props
-
getprop menu_CheckTarget [mTarget]
   -- lets load cache here
   put rev_ScriptObject() into scriptObject
   if exists(scriptObject) is false then return empty
   
   -- put the menu_TableTitles of scriptObject into CachedMenuTitles
   put the menu_ScriptTitles of scriptObject into LocalArray ["menu_ScriptTitles"]
   return true -- mTarget = scriptObject
end menu_CheckTarget
