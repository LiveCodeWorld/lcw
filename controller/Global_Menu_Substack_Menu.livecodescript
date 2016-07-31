script "Global | Menu | Substack | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Substack | Menu
type: controller
version: 0.1

local LocalArray


--> Global | Menu | Substack | Menu
-
on menu_ReindexLocalMenus scriptObject
   put the menu_SubStack of scriptObject into subStackObject
   menu_IndexStackMenuCards subStackObject
   hArray_StoreGlobal
   put merge ("Stored global hArray database to disk!") into someComment
   opn_Notify someComment
end menu_ReindexLocalMenus

on menu_CreateMenuCard scriptObject, localMenuTitle
   menu_CreateSubStack scriptObject
   put the result into subStackObject
   
   switch localMenuTitle
      case "Create"
         put "Local | Test | Menu" into mTitle
         put opn_Ask ("What name do you want to give this new menu?", mTitle) into mTitle
         go to subStackObject
         if the defaultstack is not the name of subStackObject then
            breakpoint
            exit to top
         end if
         
         create card mTitle
         edit the script of card mTitle
         break
      default
         put the script of scriptObject into someScript
         put script_GetSuite (localMenuTitle, someScript) into scriptSuite
         if scriptSuite is empty then
            opn_Answer "There was a problem copying the menu" && kwote (localMenuTitle) & "!"
            exit to top
         end if
         
         if exists (card localMenuTitle of subStackObject) is true then
            set the clipboarddata to scriptSuite
            edit the script of cd localMenuTitle of subStackObject
            put "There already is a local menu with named" && kwote (localMenuTitle) & ". Here it is!" into someComment
            opn_Notify someComment, true
            exit to top
         else
            menu_DeleteTitleSuites localMenuTitle, someScript
            put the result into scriptSuite
            rev_SetScriptEditorField someScript
            
            set the defaultstack to subStackObject
            create card localMenuTitle
            
            -- could paste the script into the editor rather than set the script
            set the script of card localMenuTitle to scriptSuite
            put the long id of cd localMenuTitle of subStackObject into newController
            menu_CreateAndStoreTables newController
            edit the script of cd localMenuTitle of subStackObject
            
            put "Created new local menu" && kwote(localMenuTitle) into someComment
            opn_Notify someComment, true
         end if
   end switch
end menu_CreateMenuCard

on menu_EditMenuCard scriptObject, mCard
   put the menu_SubStack of scriptObject into subStackObject
   put "card" && kwote(mCard) && "of" && subStackObject into cardObject
   set the visible of subStackObject to true
   if exists(cardObject) then
      if the shiftkey is "Down" then go to cardObject
      edit the script of cardObject
   end if
end menu_EditMenuCard

on menu_DeleteMenuCard scriptObject, mCard
   put the menu_SubStack of scriptObject into subStackObject
   if exists(card mCard of subStackObject) then
      delete card mCard of subStackObject
   end if
end menu_DeleteMenuCard

on _
end _

on menu_ShowMenuStack scriptObject, someBoolean
   put rev_ScriptObject() into mController
   put the menu_SubStack of mController into subStackObject
   if exists (subStackObject) then
      set the visible of subStackObject to someBoolean
      if someBoolean is true then
         go to subStackObject
      end if
   else
      beep
   end if
end menu_ShowMenuStack

on menu_DeleteMenuStack
   answer "Sure you want to delete the local record stack - and all the views it contains?" with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   put rev_ScriptObject() into mController
   put the stack_Name of mController into mainStackName
   put the stack_SubName ["OPN Stack Menus"] of mController into subStackName
   breakPoint
   delete stack subStackName of stack mainStackName
end menu_DeleteMenuStack

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Menu | Substack | Menu | Props
-
getprop local_MenuTitles [scriptObject]
   put the menu_ScriptTitles of scriptObject into localMenuTitles
   if localMenuTitles is empty then
      return "Create"
   else
      put CR & "-,Create" after localMenuTitles
      return localMenuTitles
   end if
end local_MenuTitles

getprop m_Cards [scriptObject]
   return LocalArray ["mCardMenu"]
end m_Cards

getprop m_Cards [scriptObject]
   -- put the mobile_Name of scriptObject into scriptObject
   put the menu_CardNames of scriptObject into mCards
   return mCards
end m_Cards


--> Global | Menu | Substack | Menu | Disabled
-
getprop disabled_EditMenuCard [scriptObject]
   put the menu_CardNames of scriptObject into mCards
   sort mCards
   put mCards into globalMenuTitles
   filter globalMenuTitles with "Global |*"
   
   put mCards into mCardMenu
   filter mCardMenu without "Global |*"
   
   if mCardMenu is not empty and globalMenuTitles is not empty then put ",-," after mCardMenu
   if globalMenuTitles is not empty then put globalMenuTitles after mCardMenu
   
   put mCardMenu into LocalArray ["mCardMenu"]
   return mCardMenu is empty
end disabled_EditMenuCard

getprop disabled_DeleteMenuCard [scriptObject]
   put the menu_SubStack of scriptObject into menuSubStack
   if exists (menuSubStack) is false then return "delete"
   put the cardNames of menuSubStack into mCards
   filter mCards without "card *"
   if mCards is empty then
      return true
   else
      return false
   end if
end disabled_DeleteMenuCard

getprop disabled_ShowMenuStack
   put rev_ScriptObject() into mController
   put the menu_SubStack of mController into subStackObject
   if exists(subStackObject) then
      return false
   else
      return true
   end if
end disabled_ShowMenuStack

getprop disabled_DeleteMenuStack
   put rev_ScriptObject() into mController
   put the menu_SubStack of mController into subStackObject
   if exists(subStackObject) then
      return false
   else
      return true
   end if
end disabled_DeleteMenuStack


--> Dev | Menu
-
on menu_CreateItemButtons scriptObject, mCard
   -- ignoreCall: form_Records
   put the menu_SubStack of scriptObject into subStackObject
   if exists(card mCard of subStackObject) is true then
      put the long id of card mCard of subStackObject into mCardObject
      go to mCardObject
   else
      menu_CreateSubStack scriptObject
      put the result into subStackObject
      set the behavior_Name of subStackObject to "Stack Menus"
      
      go to subStackObject
      create card mCard
      put the long id of card mCard of subStackObject into mCardObject
   end if
   
   if exists(group "Menu Items" of mCardObject) is true then
      put the long id of group "Menu Items" of mCardObject into menuItemGroup
   else
      set the view_Insert of mCardObject to "View|Form|Simple"
      put the result into menuItemGroup
   end if
   set the form_Records of menuItemGroup to empty
   
   put the menu_Table [mCard] of scriptObject into mTable
   display_Lines mTable
   
   repeat for each line mTableLine in mTable
      menu_DeconstructTableLine mTableLine, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp, mSendLine
      create button mLine in menuItemGroup
      put it into createdButton
      if mLine is "-" then next repeat
      if exists (mController) is false then next repeat
      put token 1 of pigeon into handlerName
      put menu_GetItemScript (handlerName, mController) into menuItemScript
      set the script of createdButton to menuItemScript
   end repeat
   
   put the rect of mCardObject into someRect
   put rect_SubtractMargin (24, someRect) into someRect
   set the rect of menuItemGroup to someRect
end menu_CreateItemButtons


--> Menu | Props
-
getprop menu_Target
   put rev_ScriptObject() into scriptObject
   return scriptObject
end menu_Target

getprop menu_CheckTarget [scriptObject]
   if exists (scriptObject) is false then return false
   return true
end menu_CheckTarget
