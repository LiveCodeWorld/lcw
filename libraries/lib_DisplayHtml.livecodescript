script "lib_DisplayHtml"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayHtml
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_ScaffoldHtml htmlTemplateName, pLocOrRect, pStackStyle, pCloneName
   put scaffold_GetTemplate (htmlTemplateName) into someHTML
   --
   display_Html someHTML, pCloneName, pLocOrRect, pStackStyle
   put the result into displayView
   --
   return displayView
end display_ScaffoldHtml

command display_Html someHTML, pCloneName, pLocOrRect, pStackStyle
   if pCloneName is empty then put "Browser" into pCloneName
   --
   display_Clone "View|Browser", pCloneName, someHTML, "browser_HtmlText", pLocOrRect, pStackStyle
   put the result into displayView
   dispatch "LayoutControl" to displayView
   --
   display_ToolStack displayView
   return displayView
end display_Html

command display_HtmlText someHTML, pTitle, pTreeMenuTitle
   put stack_GetLastRect () into oRect
   --
   display_InvisibleIndex empty, pTitle, pTreeMenuTitle, empty, empty, empty, empty, true
   put the result into displayView 
   set the displayed_HtmlText of displayView to someHTML
   --
   put the formatted_Rect of displayView into fRect
   put the screen_Rect of displayView into displayScreenRect
   put display_GetNewStackRect (oRect, fRect, displayScreenRect) into newRect
   --
   put token -1 of displayView into cloneStackName
   set the rect of stack cloneStackName to newRect --- this is not working in latest dp
   revIDEEnsureOnscreen cloneStackName
   --
   show stack cloneStackName
   go to stack cloneStackName
   --
   set the field_Style of displayView to "text"
   return displayView
end display_HtmlText


--> Display | Html
-
command display_Browser someURL, pShowTools, sRect
   -- put the stack_BelowRect of stack "Image 1" into sRect
   --
   display_Clone "View|Browser", "Browser", someURL, "browser_URL", sRect
   put the result into displayView
   --
   if pShowTools is not false then
      display_ToolStack displayView
   end if
   --
   display_SetMenu displayView, "Browser", "title_Menu"
   --
   return displayView
end display_Browser

--> Deps
-
