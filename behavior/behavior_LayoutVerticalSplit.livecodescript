script "behavior_View|Layout|Vertical|Split"
--> MetaData
-
license: GPLv3
name: behavior_View|Layout|Vertical|Split
type: behavior
version: 0.2


local LocalArray


--> Currently Working On
-
getprop search_LongStackFile [stackName]
   put the index_View of the target into indexView
   if exists (indexView) is false then return empty
   
   put the index_Folder of indexView into indexFolder
   put the view_Index of indexView into shortStackFiles
   repeat for each line shortStackFile in shortStackFiles
      put indexFolder & shortStackFile into longStackFile
      if exists (stack longStackFile) is empty then next repeat
      
      put the short name of stack longStackFile into testStackname
      if stackName = testStackname then 
         return longStackFile
      end if
   end repeat
   return empty
end search_LongStackFile

getprop index_ShortFiles
   put the view_Index of the target into shortStackFiles
   return shortStackFiles
end index_ShortFiles


--> Props | Selected
-
/*
There can be similar named props in an iner "View|Index|Group" view.

These handlers depend on the "selected_ShortStackFiles" virtual property.
*/

getprop selected_ShortStackFiles
   put the index_View of the target into indexView
   if exists (indexView) is false then return empty
   put the view_Index of indexView into shortStackFiles 
   return shortStackFiles
end selected_ShortStackFiles

getprop selected_LongStackFiles
   put the index_Field of the target into indexField
   put the selected_ShortStackFiles of indexField into shortStackFiles
   put the index_Folder of indexField into indexFolder
   
   repeat for each line shortStackFile in shortStackFiles
      put indexFolder & shortStackFile into longStackFile
      put longStackFile & CR after longStackFiles
   end repeat
   delete char -1 of longStackFiles
   return longStackFiles
end selected_LongStackFiles

getprop selected_Stacks
   put the child_Names of group "Stacks and Libraries" into indexGroupNames
   repeat for each line indexGroupName in indexGroupNames
      put the child_Controls of group indexGroupName of group "Stacks and Libraries" into indexViews
      repeat for each line indexView in indexViews
         put the short name of indexView into testName
         get the selected_StackObjects of indexView
         if it is not empty then
            put it & CR after selectedStackObjects
         end if
      end repeat
   end repeat
   delete char -1 of selectedStackObjects
   return selectedStackObjects
end selected_Stacks

getprop selected_StackFiles
   put the child_Names of group "Stacks and Libraries" into indexGroupNames
   repeat for each line indexGroupName in indexGroupNames
      put the child_Controls of group indexGroupName of group "Stacks and Libraries" into indexViews
      repeat for each line indexView in indexViews
         put the selected_LongStackFiles of indexView into selectedLongStackFiles
         if selectedLongStackFiles is not empty then
            put selectedLongStackFiles & CR after selectedStackFiles
         end if
      end repeat
   end repeat
   delete char -1 of selectedStackFiles
   return selectedStackFiles
end selected_StackFiles

getprop selected_StackObject
   -- bit of a hack
   put the selected_StackObjects of the target into selectedStackObjects
   return line 1 of selectedStackObjects
end selected_StackObject

getprop selected_StackObjects
   put the selected_ShortStackFiles of the target into shortStackFiles
   put the index_Folder of the target into indexFolder
   repeat for each line shortStackFile in shortStackFiles
      put indexFolder & shortStackFile into longStackFile
      if exists (stack longStackFile) is false then
         put longStackFile & CR after badStackFiles
         next repeat
      end if
      
      put the name of stack longStackFile & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end selected_StackObjects


--> Folder
-
getprop index_Folder
   put the long id of the target into indexView
   put the group_Name of indexView into groupName
   put the displayed_Project of indexView into projectName
   
   put project_GetFolder (groupName, projectName) into someFolder 
   return someFolder 
end index_Folder

setprop index_Folder someFolder
   put the long id of the target into indexView
   
   put the group_Name of indexView into groupName
   put the displayed_Project of indexView into projectName
   
   project_SetFolder groupName, projectName, someFolder
   return groupName    
end index_Folder

getprop index_Folders
   put the child_Names of group "Stacks and Libraries" into indexGroupNames
   repeat for each line indexGroupName in indexGroupNames
      put the child_Controls of group indexGroupName of group "Stacks and Libraries" into indexViews
      repeat for each line indexView in indexViews
         put the index_Folder of indexView into indexFolder
         put indexFolder & CR after indexFolders
      end repeat
   end repeat
   delete char -1 of indexFolders
   return indexFolders
end index_Folders


--> Index | Stackfiles
-
getprop index_LongStackFiles
   switch
      case the long id of the target = the long id of me
         return the verticalLayout_LongStackFiles of me
      case the view_Name of the target = "View|Index|Group"
         return the indexGroup_LongStackFiles of the target
      case the view_Name of the target = "View|Index|Simple"
         return the indexView_LongStackFiles of the target
      default
         -- could be a nested layout?
         breakpoint
         return empty
   end switch
end index_LongStackFiles

getprop verticalLayout_LongStackFiles
   put the child_Views ["View|Index|Group"] of me into indexGroups
   repeat for each line indexGroup in indexGroups
      put the child_Views ["View|Index|Simple"] of indexGroup into indexViews
      repeat for each line indexView in indexViews
         set the cursor to busy
         put the indexView_LongStackFiles of indexView into indexViewLongStackFiles
         put indexViewLongStackFiles & CR after longStackFiles
      end repeat
   end repeat
   delete char -1 of longStackFiles
   sort longStackFiles
   return word 1 to -1 of longStackFiles
end verticalLayout_LongStackFiles

getprop indexGroup_LongStackFiles
   put the child_Views ["View|Index|Simple"] of the target into indexViews
   repeat for each line indexView in indexViews
      put the indexView_LongStackFiles of indexView into indexViewLongStackFiles
      put indexViewLongStackFiles & CR after longStackFiles
   end repeat
   delete char -1 of longStackFiles
   sort longStackFiles
   return word 1 to -1 of longStackFiles
end indexGroup_LongStackFiles

getprop indexView_LongStackFiles
   put the index_View of the target into indexView
   if exists (indexView) is false then return empty
   
   put the index_Folder of indexView into indexFolder
   put the view_Index of indexView into shortStackFiles
   repeat for each line shortStackFile in shortStackFiles
      put indexFolder & shortStackFile into longStackFile
      put longStackFile & CR after longStackFiles
   end repeat
   delete char -1 of longStackFiles
   return longStackFiles
end indexView_LongStackFiles


--> Index | Stacks
-
getprop index_Stacks
   -- here we experiment with a generic handler that
   -- could be recursive - but avoiding that :)
   -- also could just place versions of the handler in the various levels (may be best strategy ?)
   switch
      case the long id of the target = the long id of me
         return the verticalLayout_Stacks of me
      case the view_Name of the target = "View|Index|Simple"
         return the indexView_Stacks of the target
      case the view_Name of the target = "View|Index|Group"
         return the indexGroup_Stacks of the target
      default
         -- could be a nested layout?
         breakpoint
         return empty
   end switch
end index_Stacks

getprop verticalLayout_Stacks
   put the child_Views ["View|Index|Group"] of me into indexGroups
   repeat for each line indexGroup in indexGroups
      put the child_Views ["View|Index|Simple"] of indexGroup into indexViews
      repeat for each line indexView in indexViews
         set the cursor to busy
         put the indexView_Stacks of indexView into indexViewStackObjects
         put indexViewStackObjects & CR after stackObjects
      end repeat
   end repeat
   delete char -1 of stackObjects
   sort stackObjects
   return word 1 to -1 of stackObjects
end verticalLayout_Stacks

getprop indexGroup_Stacks
   put the child_Views ["View|Index|Simple"] of the target into indexViews
   repeat for each line indexView in indexViews
      set the cursor to busy
      put the indexView_Stacks of indexView into indexViewStackObjects
      put indexViewStackObjects & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   sort stackObjects
   return word 1 to -1 of stackObjects
end indexGroup_Stacks

getprop indexView_Stacks
   put the index_View of the target into indexView
   if exists (indexView) is false then return empty
   
   put the index_Folder of indexView into indexFolder
   put the view_Index of indexView into shortStackFiles
   repeat for each line shortStackFile in shortStackFiles
      put indexFolder & shortStackFile into longStackFile
      if exists (stack longStackFile) is false then next repeat
      put the name of stack longStackFile & CR after indexStackObjects
   end repeat
   delete char -1 of indexStackObjects
   return word 1 to -1 of indexStackObjects
end indexView_Stacks 


--> Objects
-
getprop index_GroupNames
   breakpoint
   return the child_GroupNames of me
end index_GroupNames

getprop index_Views
   -- could be made intelligent to nest or nto nest depending if there is an index group
   put the child_Views ["View|Index|Group"] of me into indexGroups
   repeat for each line indexGroup in indexGroups
      put the child_Views ["View|Index|Simple"] of indexGroup & CR after indexViews
   end repeat
   delete char -1 of indexViews
   return indexViews
end index_Views

getprop index_Controls
   -- returns other things not just index_Views to 2 levels down.
   put the child_Groups of me into indexGroups
   repeat for each line indexGroup in indexGroups
      put the child_Controls of indexGroup & CR after indexViews
   end repeat
   delete char -1 of indexViews
   return indexViews
end index_Controls

getprop index_Groups
   breakpoint
   return the child_Groups of me
end index_Groups


--> Events
-
on resizeControl pFirstparam
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl

on refresh pFetchStandardLcwFiles
   set the cursor to watch
   put the index_View of the target into indexView
   
   switch pFetchStandardLcwFiles
      case true
         put the lcw_ShortFiles of indexView into newIndex
         break
      default
         put the index_Folder of indexView into indexFolder
         put folder_ListShortStackFiles (indexFolder) into newIndex
   end switch
   set the view_Index of indexView to newIndex
end refresh


--> Geometry
-
on LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the margins of me into myMargins
   rect_SubtractMargins pRect, myMargins
   
   put item 4 of pRect - item 2 of pRect into innerHeight
   
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   if numberOfChildren = 0 then return 0
   
   put numberOfChildren - 1 into gutterNum
   put the view_Spacing of me into viewSpacing
   
   put round((innerHeight - gutterNum * viewSpacing)/numberOfChildren) into splitHeight
   
   put item 2 of pRect into childTop
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      
      put childTop + splitHeight into childBottom
      put pRect into childRect
      put childTop into item 2 of childRect
      put childBottom into item 4 of childRect
      set the rect of control id topControlID to childRect
      
      put childBottom + viewSpacing into childTop
   end repeat
   unlock screen
   return numberOfChildren
end LayoutControl

getprop view_Spacing
   put LocalArray ["viewSpacing"] into someNum
   if someNum is not a number then -- let's set a default
      -- usually fine to use margins of internal groups
      put 0 into someNum
      put someNum into LocalArray ["viewSpacing"]
   end if
   return someNum
end view_Spacing

setprop view_Spacing someNum
   put someNum into LocalArray ["viewSpacing"]
   LayoutControl
end view_Spacing


--> Geometry
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


--> Names
-
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

getprop child_GroupNames
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID of me into childControl
      if word 1 of childControl = "group" then
         -- put the group_Name of childControl into gName
         put the short name of control id topControlID of me into gName
         put gName & CR after gNames
      end if
   end repeat
   delete char -1 of gNames
   return gNames
end child_GroupNames


--> Objects
-
getprop child_Groups
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      put the long id of control id topControlID of me into childControl
      if word 1 of childControl = "group" then
         put childControl & CR after childControls
      end if
   end repeat
   delete char -1 of childControls
   return childControls
end child_Groups

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

getprop verticalSplit_Layout
   return the long id of me
end verticalSplit_Layout

getprop vertical_Layout
   return the long id of me
end vertical_Layout

getprop layout_View
   return the long id of me
end layout_View

getprop view_Object
   return the long id of me
end view_Object
