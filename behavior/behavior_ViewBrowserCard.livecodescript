script "behavior_ViewBrowserCard"
--> MetaData
-
license: GPLv3
name: behavior_ViewBrowserCard
type: behavior
version: 0.1


--> Working On
-
local LocalArray


getprop displayed_ViewSet
   return LocalArray ["display_Path"]
end displayed_ViewSet

setprop displayed_ViewSet displayedPaths
   display_Views displayedPaths
   put displayedPaths into LocalArray ["display_Path"]
end displayed_ViewSet

on dragEnd
   put the dragdata ["private"] into viewName
   put the dragDestination into targetObject
   if exists (targetObject) is false then return false
   put the dropped_TargetName of targetObject into targetView
   if exists (targetView) is false then return false
   
   put the stack_Name of targetView into stackName
   if stackName = "opn_ViewOutline" then
      put the tree_SelectedLink of targetView into linkedView
      if exists(linkedView) is false then
         opn_Notify "Dropped dragEnd - but no link text to find object?", true
      else
         set the view_Swap of linkedView to viewName
         dispatch "viewOutline_RefreshDisplay" to targetView
      end if
      pass dragEnd
   end if
   
   put the dgControl of targetObject into revDataGrid
   put the form_View of targetObject into formView
   if exists(revDataGrid) and (exists(targetView) is false or revDataGrid ends with targetView) then
      -- a datagrid   
      answer "You are dropping a view on a datagrid. Do you want to replace the datagrid or the row template?" with "Cancel" or "Replace" or "Set template"
      switch word 1 of it 
         case "Set"
            -- lets set the row template
            set the record_ViewName of revDataGrid to viewName
            put the result into newTemplateObject
            get merge("Set the dg_ViewName of [[the mobile_Name of newTemplateObject]] to the mobile_Name of [[newTemplateObject]]")
            opn_Notify it
            return viewName
         case "Cancel"
            return empty
         case "Replace"
            -- lets replace the datagrid
            set the view_Swap of revDataGrid to viewName
            dispatch "viewOutline_RefreshDisplay" to stack "opn_ViewOutline"
            return viewName
      end switch
   else if exists (formView) then
      -- a datagrid   
      answer "You are dropping a view on a form_View. Do you want to replace the record or insert one?" with "Cancel" or "Replace" or "Insert"
      switch it 
         case "Replace"
            set the view_Swap of targetView to viewName
            dispatch "viewOutline_RefreshDisplay" to stack "opn_ViewOutline"
            break
         case "Insert"
            set the form_InsertView [false] of formView to viewName
            break
         default
            return viewName
      end switch
   else
      -- not a datagrid   
      -- set the view_Swap of targetView to viewName
      set the control_Type of targetView to viewName
      -- dispatch "viewOutline_RefreshDisplay" to stack "opn_ViewOutline"
      return viewName
   end if
end dragEnd

getprop drag_Enter
   put the dragDestination into targetObject
   get the dragsource
   put the stack_Object of it into sourceStack
   if sourceStack = the stack_Object of targetObject then
      set the dragAction to "none"
      return false
   end if
   
   put the view_Object of targetObject into targetView
   if exists(targetView) then
      if the placeholder_Button of targetObject is not empty then return false
      set the dragAction to "link"
      return true
   else
      set the dragAction to "none"
      return false
   end if
end drag_Enter


--> Events
-
on preOpenStack
   display_Views
   pass preOpenStack
end preOpenStack

on mouseDoubleUp
   switch word 1 of the name of the target
      case "Image"
         put the record_Name of the target into vName
         view_NormalizeName vName
         put view_GetTemplateObject (vName) into libraryObject
         object_GoTo libraryObject
         break
      case "graphic"
         -- some blank space in a datagrid
         display_Views
         break
      default
         -- resizeStack
         pass mouseDoubleUp
   end switch
end mouseDoubleUp

on resizeStack
   view_ResizeToCard 0
end resizeStack

--> Datagrid
-
on linkclicked cText
   switch
      case cText contains "|"
         display_ViewRecord cText
         break
      default
         put the params
   end switch 
end linkclicked

on dg_FillInData pDataArray, recordView
   try   
      put pDataArray ["title"] into vName
      
      set the itemdelimiter to "|"
      delete item 1 of vName
      set the record_Name of recordView to vName
      
      put view_GetHelpHtml (vName) into someHtml
      set the record_HelpHtml of recordView to someHtml
      
      put view_LocalIconFile (vName) into imageFile
      if there is a file imageFile then set the record_ImageFile of recordView to imageFile
      
      put pDataArray ["isExpanded"] is true into isExpanded
      set the record_IsExpanded of recordView to isExpanded
      
      set the menu_Title of recordView to "Tree | Field | Menu"
      set the menu_ToolTitle of recordView to "Global | Record | View Info | Menu"
   catch e
      -- log_Error "dg_FillInData", e
      opn_Notify e, true
   end try
end dg_FillInData

on dg_CloseFieldEditor pFieldEditor, recordView
   if recordView is empty then put the long id of the target into recordView
   put the htmltext of pFieldEditor into someHtml
   put the record_Name of recordView into vName
   view_AutoLinkHelpText someHtml
   view_SetHelpHtml vName, someHtml
end dg_CloseFieldEditor
