script "behavior_CardModule"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_CardModule
type: behavior
version: 0.1

/*
A minimal script to work with the View|Tree module.
*/


--> Working on
-
getprop module_View
   put the stack_Name of me into sName
   switch
      case exists (control sName of me)
         return the long id of control sName of me
         break
      case exists (control 1 of me)
         breakpoint
         return the long id of control 1 of me
         break
      default
         breakpoint
         return the long id of me
   end switch
end module_View

private function _CardView
   put the card_View of me into cView
   if exists (cView) then return cView
   
   # Default can override on the cards script
   if exists (control 1 of me) then
      return the long id of control 1 of me
   else
      return empty
   end if
end _CardView


--> Layout
-
on LayoutCard
   put the card_InnerRect of me into vRect
   --
   put _CardView() into cView
   if exists (cView) then
      dispatch "LayoutControl" to cView with vRect
   end if
end LayoutCard


--> Events
-
on resizeStack
   put _CardView() into cView
   if exists (cView) then
      put the card_InnerRect of this cd into cRect
      -- dispatch "LayoutControl" to cView with cRect
      set the rect of cView to cRect
   end if
end resizeStack

on preOpenCard
   put _CardView() into cView
   if exists (cView) then
      dispatch "view_Init" to cView
   end if
   pass preOpenCard
end preOpenCard

on resizeStack
   LayoutCard
   pass resizeStack
end resizeStack

on preOpenStack
   choose browse tool
   --
   put _CardView() into cView
   if exists (cView) then
      put the uOPN ["object_BehaviorArray"] of cView into bArray
      set the object_Behaviors of cView to bArray
   end if
   --
   pass preOpenStack
end preOpenStack

on openStack
   use_AndLoad  
   pass openStack
end openStack


--> Props | Dep
- 
/* Could be at card level or stored with module */

getprop dep_UsedNames
   put the dep_Array of me into depArray
   get depArray ["dep_UsedNames"]
   return keys (it)
end dep_UsedNames

getprop dep_UsedPaths
   put the dep_Array of me into depArray
   get depArray ["dep_UsedPaths"]
   return keys (it)
end dep_UsedPaths

getprop dep_Array
   put the uOPN ["dep_Array"] of me into dArray
   return dArray
end dep_Array

setprop dep_Array dArray
   if dArray = "default" then
      put the stackFile_DepArray of me into dArray
   end if
   set the uOPN ["dep_Array"] of me to dArray
   return dArray
end dep_Array


--> Load
-
command use_AndLoad
   -- Order matters
   if the platform is "web" then
      use_Wasm
      load_FrameContext
      load_MatchData
   else
      put the dep_UsedPaths of me into sPaths
      use_StackPaths sPaths
   end if
end use_AndLoad

command use_Wasm
   put "/boot/standalone/lib_Wasm.livecodescript" into stackPath
   dispatch "wasm_UseLibs" to stack stackPath
end use_Wasm

command load_FrameContext
   -- After use_Wasm
   put wikiFrame_GetContextData() into contextData
   set the context_Data of me to contextData
end load_FrameContext

command load_MatchData pPort
   -- After use_Wasm and load_FrameContext
   set the match_Data of me to empty
   
   put the origin_Protocol of me into pProtocol
   put controller_FetchMatchData (pProtocol, pPort) into matchData
   set the match_Data of me to matchData
end load_MatchData

command use_StackPaths stackPaths, pBoolean
   put the stacksInUse into usedNames
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the short name of stack stackPath into sName
      --
      if pBoolean is false then
         stop using stack stackPath
      else if sName is not among the lines of usedNames then
         start using stack stackPath
      end if
   end repeat
end use_StackPaths


--> Props | Geometry
-
getprop card_InnerRect [cMargin]
   if cMargin is empty then put the card_Margin of me into cMargin
   put the rect of this cd into cRect
   --
   rect_SubtractMargins cRect, cMargin
   /*
   if cMargin is a number then
      add cMargin to item 1 of cRect
      add cMargin to item 2 of cRect
      --
      subtract cMargin from item 3 of cRect
      subtract cMargin from item 4 of cRect
   end if
   */
   return cRect
end card_InnerRect

getprop card_Margin
   put the uOPN ["card_Margin"] of me into cMargin
   return cMargin
end card_Margin

setprop card_Margin cMargin
   switch
      case cMargin is a number
      case cMargin is a rect
      case cMargin is a point
         set the uOPN ["card_Margin"] of this cd to cMargin
         break
      default
         set the uOPN ["card_Margin"] of this cd to empty
   end switch
   dispatch "LayoutCard" to this cd
end card_Margin


--> Deps
-
command rect_SubtractMargins @sRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of sRect
   add topM to item 2 of sRect
   subtract rightM from item 3 of sRect
   subtract bottomM from item 4 of sRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   put leftM,topM,rightM,bottomM into someMargin
end margin_Normalize

