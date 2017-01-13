script "model_MenuSubStacks"
--> MetaData
-
license: GPLv3
name: model_MenuSubStacks
type: model
version: 0.1


--> Menu | Sub Stacks
-
/*
Menu sub-stacks allow you to separate out menus onto their own sel-contained cards,
without haivng to go to create a Global menu.

These are used by "menu_TableLineFromScript"
*/

getprop menu_SubStackCard [mTitle]
   -- can be used by "menu_GetDefaultController"
   put the stack_SubName ["OPN Stack Menus"] of the target into subStackName
   if exists (card mTitle of stack subStackName) then
      return the long id of card mTitle of stack subStackName
   else
      return empty
   end if
end menu_SubStackCard

getprop menu_SubStackName
   put the stack_SubName ["OPN Stack Menus"] of the target into subStackName
   return subStackName
end menu_SubStackName

getprop menu_SubStack
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   -- put the stack_Name of the target into mainStackName -- give a substack name
   
   put the stack_SubName ["OPN Stack Menus"] of stackObject into subStackName
   -- put the menu_SubStackName of the target into subStackName
   
   if exists(stack subStackName of stack mainStackName) then
      put the long name of stack subStackName of stack mainStackName into stackObject
      return stackObject
   else
      return empty
   end if
end menu_SubStack

getprop menu_Cards
   put the menu_CardArray of the target into mCardArray
   return keys (mCardArray ["rugged_ID"])
end menu_Cards

getprop menu_CardNames
   put the menu_SubStack of the target into menuSubStack
   if exists (menuSubStack) is false then return empty
   put the cardNames of stack menuSubStack into mCardNames
   filter mCardNames with "* | Menu"
   return mCardNames
end menu_CardNames

getprop menu_CardMenu
   put the menu_CardNames of the target into mCards
   return menu_ConstructCardMenu (mCards)
end menu_CardMenu

function menu_ConstructCardMenu mCards
   sort mCards
   put mCards into globalMenuTitles
   filter globalMenuTitles with "Global |*"
   
   put mCards into mCardMenu
   filter mCardMenu without "Global |*"
   
   if mCardMenu is not empty and globalMenuTitles is not empty then put ",-," after mCardMenu
   if globalMenuTitles is not empty then put globalMenuTitles after mCardMenu
   return mCardMenu
end menu_ConstructCardMenu

getprop menu_CardArray
   put the menu_CardNames of the target into mCardNames
   repeat for each line mCardName in mCardNames
      put the long id of card mCardName of stack menuSubStack into cardObject
      put revRuggedID (cardObject) into rObject
      put rObject into mCardArray ["mTitle"][mCardName]
      put mCardName into mCardArray ["rugged_ID"][rObject]
   end repeat
   return mCardArray
end menu_CardArray

command menu_IndexStackMenuCards pStackObject
   if pStackObject is empty then put the stack_Object of the target into pStackObject
   
   repeat for each line someID in the cardids of pStackObject
      set the cursor to busy
      put the long id of card id someID of pStackObject into cardObject
      
      set the menu_Update of cardObject to true
           
      lcw_Notify ("Updated index for menu" && kwote (the short name of cardObject) & "!")
   end repeat
end menu_IndexStackMenuCards

command menu_CreateSubStack someObject
   stack_CreateSubStack someObject, "OPN Stack Menus"
   return the result
end menu_CreateSubStack


