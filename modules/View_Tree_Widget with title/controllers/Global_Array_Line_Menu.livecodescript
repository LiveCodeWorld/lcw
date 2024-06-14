script "Global | Array | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Array | Line | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

on mDoubleUp_DisplayShortHkey displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_DisplayShortHkey


--> Global | Array | Line | Menu
-
on menu_SelectedLine displayView
   put the selected_Line of displayView
end menu_SelectedLine

on menu_SelectedValue displayView
   put the selected_Value of displayView
end menu_SelectedValue

private on _
end _

on menu_CreateLineMenu arrayView
   put the line_Menu of arrayView into mTitle
   put the displayed_Object of arrayView into linkedView
   if exists (linkedView) is true then
      put the project_Name of linkedView into libName
   else
      put "What project or module would you like to create the menu '[[var]]' in?" into sComment
      put lcw_Ask (sComment, "lcw_Tools", arrayView, mTitle) into libName
      if exists (stack libName) is false then
         lcw_Notify "Stack '[[var]]' does not exist!", "Error", libName
      end if
   end if
   --
   breakpoint
   ask_CreateMenuFromObject mTitle, libName
   put the result into sError
   if item 1 of sError = "Error" then
      lcw_Notify sError
      if word -2 to -1 of sError = "already exits!" then
         set the line_Menu of arrayView to mTitle
      end if
   else
      put sError into lineController
      --
      set the line_Menu of arrayView to mTitle
      set the line_Controller of arrayView to lineController
      --
      edit the script of lineController
   end if
end menu_CreateLineMenu

getprop checked_CreateLineMenu [arrayView]
   put the line_Controller of arrayView into mController
   return exists (mController)
end checked_CreateLineMenu

getprop disabled_CreateLineMenu [arrayView]
   put the line_Controller of arrayView into lineController
   return exists (lineController)
end disabled_CreateLineMenu

on menu_EditDoubleUpHandler arrayView
   put the mouse_DoubleUp of arrayView into mDoubleUp
   put the mouse_Target of arrayView into mTarget
   --
   put mDoubleUp
   edit the script of mTarget
end menu_EditDoubleUpHandler
   
private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Array | Line | Menu")
end submenu_Dev

