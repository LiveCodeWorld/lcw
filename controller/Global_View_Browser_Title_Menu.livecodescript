script "Global_View_Browser_Title_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Browser_Title_Menu
type: controller
version: 0.2

local LocalArray


--> Global | View | Browser | Title | Menu
-
on menu_DisplaySet treeView, displayPath
   set the displayed_ViewSet of treeView to displayPath
end menu_DisplaySet

on menu_AddViewSet treeView, displayPath
   put the displayed_ViewSet of treeView into displayedViewSet
   if displayPath is among the lines of displayedViewSet then
      line_Delete displayPath, displayedViewSet
   else
      line_Add displayPath, displayedViewSet
   end if
   set the displayed_ViewSet of treeView to displayedViewSet
end menu_AddViewSet

on menu_RefreshDisplay
   display_Views
end menu_RefreshDisplay

on _
end _

on menu_Filter treeView, viewFilter
   lock screen
   set the view_Filter of me to viewFilter
   if the shiftkey is "Down" then
      set the top_LevelPath of me to "all"
   end if
   
   display_Views
   viewBrowser_ResetTitle
   unlock screen
end menu_Filter

on menu_KnowAllViews
   put library_ViewFiles() into stackPaths
   set the stackfile_Paths of me to stackPaths
   
   -- put the stack_Name of me into stackName
   put "libOPN_ViewBrowser" into stackName
   save stack stackName
   display_Views
end menu_KnowAllViews

on _
end _

on menu_CreateTemplateFromSelectedGroup
   -- template_ConstructCloneStack
   
   put the selectedObject into someObject
   template_ConstructStackFromObject someObject
end menu_CreateTemplateFromSelectedGroup

on menu_CreateBlankTemplate
   template_CreateInvisibleStack
   put the result into stackObject
end menu_CreateBlankTemplate

on menu_DodgyCreateButtonView
   ask "Give this button view a name.." with "View|Button|Something"
   put it into vName
   if vName is empty then exit to top
   
   template_ConstructStackFromObject
   -- template_CreateLibraryStack vName
   put the result into stackObject
   
   put "View|Button|Cog"  into cloneViewName
   set the view_Insert of card 1 of stackObject to cloneViewName
   put the result into createdView
   set the view_Name of createdView to vName
   
   view_CreateTemplateIconGroup createdView
end menu_DodgyCreateButtonView

on _
end _

on menu_DisplayOutlinePalette treeView
   display_ViewOutline
end menu_DisplayOutlinePalette

on submenu_DisplayOutline
   return "View | Display | Outline | Menu"
end submenu_DisplayOutline

on _
end _

on menu_DisplayViewBrowserRecord treeView
   put menu_GetTargetObject() into targetObject
   put the dgControl of targetObject into dgView
   put the dgProps ["record template"] of dgView into recordView
   object_GoTo recordView
end menu_DisplayViewBrowserRecord

on menu_ViewBrowserRecordBehavior treeView
   put menu_GetTargetObject() into targetObject
   put the dgDataControl of targetObject into recordView
   put the behavior of recordView into recordBehavior
   if exists(recordBehavior) then
      edit the script of recordBehavior
   else
      edit the script of recordView
      opn_Notify "This view does not have a behavior!", true
   end if
end menu_ViewBrowserRecordBehavior


on _
end _

on menu_EditScript treeView, objectReference
   put the objectReference of treeView into scriptObject
   
   if exists (scriptObject) is false then
      put merge ("the [[objectReference]] of [[treeView]]")
      answer warning merge ("Cannot locate the [[objectReference]] of treeView?")
   else
      edit the script of scriptObject
   end if
end menu_EditScript

on menu_EditViewToolMenu treeView
   put the menu_ToolTitle of treeView into mTitle
   menu_EditMenuScript mTitle
end menu_EditViewToolMenu


--> Global | View | Browser | Title | Menu | Props
-
getprop display_Path [treeView]
   put the displayed_ViewSet of treeView into displayedViewSet
   return displayedViewSet
end display_Path

getprop display_Paths
   put view_PathIndex() into pathIndex
   put outline_FirstColumnFromPathIndex (pathIndex, "|") into rootIndex
   return "All,-," & rootIndex
end display_Paths

getprop object_References
   return "viewBrowser_Recordbehavior,viewBrowser_Card,view_BrowserStack,view_OutlineStack,-,view_Template,template_Card,template_CardBehavior,-,viewBrowser_TitleView,viewBrowser_DataGrid"
end object_References

getprop viewBrowser_Title
   put the view_Filter of me into viewFilter
   put the display_Path of me into displayPath
   replace CR with "/" in displayPath
   return displayPath && "(" & viewFilter & ")"
end viewBrowser_Title

getprop top_LevelPath [normalize]
   put the uOPN ["top_LevelPath"] of me into viewStem
   if normalize is true then
      view_NormalizeName viewStem
   end if
   return viewStem
end top_LevelPath

setprop top_LevelPath viewName
   -- display_Views viewName, true
   set the uOPN ["top_LevelPath"] of me to viewName
end top_LevelPath

getprop top_LevelPaths
   put view_PathIndex() into pathIndex
   put outline_FirstColumnFromPathIndex (pathIndex, "|") into rootIndex
   return "All,-," & rootIndex
end top_LevelPaths

setprop display_Grid someBoolean
   put viewBrowser_DataGrid() into dgView
   set the visible of dgView to someBoolean
end display_Grid

getprop display_Grid
   put the viewBrowser_DataGrid of me into dgView
   return the visible of dgView
end display_Grid


--> Deps
-
function outline_FirstColumnFromPathIndex pathIndex, pDelim, pDontSort
   if pDelim is not empty then set the itemDelimiter to pDelim
   repeat for each line someLine in pathIndex
      put item 1 of someLine into newRoot
      if newRoot is not among the lines of rootIndex then
         put newRoot & CR after rootIndex
      end if
   end repeat
   delete char -1 of rootIndex
   if pDontSort is not true then sort rootIndex
   return rootIndex
end outline_FirstColumnFromPathIndex

function menu_GetClassOutline
   put display_GetClassPathArray() into pathArray
   put keys(pathArray) into pathIndex
   put "|" into pathDelim
   set the itemdelimiter to pathDelim
   sort pathIndex
   put outline_FromPathIndex(pathIndex, pathDelim) into tabbedOutline
end menu_GetClassOutline
