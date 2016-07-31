script "behavior_View|Index|Group"
--> MetaData
-
license: GPLv3
name: View|Index|Group
type: view behavior
version: 0.3


--> Variables
-
local LocalArray


--> Work in Progress
-

--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop index_Group
   return the long id of me
end index_Group

getprop horizontal_Layout
   return the long id of me
end horizontal_Layout

getprop layout_View
   return the long id of me
end layout_View


--> Hilite
-
setprop view_Hilite someStyle
   lock screen
   put the child_Controls of me into indexViews
   repeat for each line indexView in indexViews
      switch someStyle
         case "all"
            set the multiple_Hilites of indexView to true
            put the view_Index of indexView into shortFiles
            break
         case "known"
            set the cursor to watch
            put the known_ShortStackFiles of indexView into shortFiles
            set the multiple_Hilites of indexView to true
            break
         case "used"
            set the cursor to watch
            put the used_ShortStackFiles of indexView into shortFiles
            set the multiple_Hilites of indexView to true
            break
         default -- "none" or empty
            put empty into shortFiles
            set the multiple_Hilites of indexView to false
      end switch
      
      put shortFiles & CR after allShortFiles
      set the selected_Index of indexView to shortFiles
   end repeat
   unlock screen
   return word 1 to -1 of allShortFiles
end view_Hilite


--> Selected
-
getprop selected_ShortStackFiles
   put the index_View of the target into indexView
   if exists (indexView) is false then return empty
   put the selected_Index of indexView into shortStackFiles 
   return shortStackFiles
end selected_ShortStackFiles

getprop selected_StackObjects
   put empty into pSetName
   put the selected_ShortStackFiles of the target into shortStackFiles
   repeat for each line shortStackFile in shortStackFiles
      put stackFile_NameFromShortFile (shortStackFile, pSetName) into stackName
      if exists (stack stackName) then 
         put the name of stack stackName & CR after stackObjects
      end if
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end selected_StackObjects

getprop selected_StackNames
   put empty into pSetName
   put the selected_ShortStackFiles of the target into shortStackFiles
   repeat for each line shortStackFile in shortStackFiles
      put stackFile_NameFromShortFile (shortStackFile, pSetName) into stackName
      put stackName & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return stackNames
end selected_StackNames

getprop selected_LongStackFiles
   put empty into pSetName
   put the index_Field of the target into indexField
   put the selected_ShortStackFiles of indexField into shortStackFiles  
   repeat for each line shortStackFile in shortStackFiles
      put stackFile_NameFromShortFile (shortStackFile, pSetName) into stackName
      if exists (stack stackName) then 
         put the filename of stack stackName & CR after longStackFiles
      end if
   end repeat
   delete char -1 of longStackFiles
   return longStackFiles
end selected_LongStackFiles


--> Events
-
on resizeControl
   LayoutControl
end resizeControl


--> Geometry
-
on LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the margins of me into myMargins
   rect_SubtractMargins pRect, myMargins
   put item 3 of pRect - item 1 of pRect into innerWidth
   
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   if numberOfChildren = 0 then return 0
   
   put numberOfChildren - 1 into gutterNum
   put the view_Spacing of me into viewSpacing
   put innerWidth - (gutterNum * viewSpacing) into availableWidth
   put round (availableWidth / numberOfChildren) into indexWidth
   
   put item 1 of pRect into thisLeft
   repeat with cNum = 1 to numberOfChildren 
      put pRect into childRect
      put thisLeft into item 1 of childRect
      put thisLeft + indexWidth into thisRight
      put thisRight into item 3 of childRect
      
      put line cNum of topControlIDs into topControlID
      set the rect of control id topControlID to childRect
      
      put thisRight + viewSpacing into thisLeft
   end repeat
   unlock screen
   return numberOfChildren
end LayoutControl


--> Geometry
-
getprop index_Width
   put line 1 of LocalArray ["topControls"] into leftControl
   put the width of leftControl into indexWidth
   put indexWidth into LocalArray ["indexWidth"]
   return indexWidth
end index_Width

setprop index_Width someWidth
   switch
      case someWidth is a number
         put someWidth into LocalArray ["indexWidth"]
         break
      default
         put 250 into someWidth
   end switch
   LayoutControl
end index_Width

getprop view_Spacing
   put LocalArray ["viewSpacing"] into someNum
   if someNum is not a number then -- let's set a default
      put 8 into someNum
      put someNum into LocalArray ["viewSpacing"]
   end if
   return someNum
end view_Spacing

setprop view_Spacing someNum
   put someNum into LocalArray ["viewSpacing"]
   LayoutControl
end view_Spacing


--> Children
-
getprop child_Views [testViewName]
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID into cControl
      put the view_Name of cControl into viewName
      
      if testViewName is empty then
         if vName is not empty then
            put cControl & CR after childViews
         end if
      else if viewName begins with testViewName then
         put cControl & CR after childViews
      end if
   end repeat
   delete char -1 of childViews
   return childViews
end child_Views

getprop child_Controls
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID & CR after childViews
   end repeat
   delete char -1 of childViews
   return childViews
end child_Controls

getprop child_Names
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      
      put the short name of control id topControlID into childName
      put childName & CR after childNames
   end repeat
   delete char -1 of childNames
   return childNames
end child_Names


--> Deps
-
command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
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
