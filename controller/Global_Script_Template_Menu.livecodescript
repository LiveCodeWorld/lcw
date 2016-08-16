script "Global | Script | Template | Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Template_Menu
type: controller
version: 0.1

local LocalArray


--> Global | Script | Template | Menu
-
on menu_DisplayTemplate textDisplayView, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

on _
end _

on menu_NewTemplateFromClipboard
   ask "What would you like to call this template as..."
   put it into templateName
   if templateName is empty then exit to top
   
   put the clipboarddata ["text"] into someScript
   script_SetTemplate templateName, someScript
   put the result into savedFile
   
   display_ScriptTemplate templateName
end menu_NewTemplateFromClipboard

on menu_CopyTemplateToClipboard mTarget, templateName
   put script_GetTemplate (templateName) into templateScript
   set the clipboarddata ["text"] to templateScript
   opn_Notify "Script copied to clipboard!"
end menu_CopyTemplateToClipboard

on _
end _

on menu_DeleteTemplate textDisplayView, templateName
   put merge ("Are you sure you want to delete the script template '[[templateName]]'. This cannot be undone!") into someWarning
   answer warning someWarning with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   script_DeleteTemplate templateName
   put the result into deletedFile
   answer merge ("Deleted stored template script '[[templateName]]'!")
end menu_DeleteTemplate

on _
end _

on menu_Save textDisplayView   
   put the title_Text of textDisplayView into templateName
   put the view_Text of textDisplayView into someScript
   
   script_SetTemplate templateName, someScript
   put the result into savedFile
   
   answer merge ("Stored template script as '[[templateName]]'")
end menu_Save

on menu_SaveAs textDisplayView
   put the view_Text of textDisplayView into someScript
   put the view_Title of textDisplayView into templateName
   
   ask "What would you like to save this template as..." with templateName
   put it into templateName
   if templateName is empty then exit to top
   
   script_SetTemplate templateName, someScript
   put the result into savedFile
   
   put "file:" & savedFile into newUrl
   set the displayed_Url of textDisplayView to newUrl
   set the view_Title of textDisplayView to templateName
end menu_SaveAs

on _
end _

-- on menu_UnlockText textDisplayView, someBoolean
set the lock_Text of textDisplayView to (someBoolean is false)
end menu_UnlockText

-- getprop unlock_Text [textDisplayView]
-- gives an error when called on a behavior by the "Global | Script | Template | Menu" menu
put the lock_Text of textDisplayView into someBoolean
return someBoolean is false
end unlock_Text

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev

    
--> Global | Script | Template | Menu | Props
-
getprop template_Names [mTarget]
    return script_TemplateNames()
end template_Names


--> Global | Script | Template | Menu | Disabled
-
-- getprop disabled_Save [textDisplayView]
   put LocalArray ["textDisplayView"]  into textDisplayView
   put exists (textDisplayView) into isTextDisplay
   return isTextDisplay is false
end disabled_Save

-- getprop disabled_SaveAs [textDisplayView]
   put LocalArray ["textDisplayView"]  into textDisplayView
   put exists (textDisplayView) into isTextDisplay
   return isTextDisplay is false
end disabled_SaveAs


--> Dev | Menu
-
on menu_ViewProperty someView, someProp
   view_DoPropertyMenu someProp, someView
end menu_ViewProperty

getprop some_Props [mTarget]
   -- put the name of mTarget
   put the view_PropertyMenu of mTarget into viewPropertyMenu
   return viewPropertyMenu
end some_Props

on _
end _

on menu_EditBehavior textDisplayView
   put the behavior of textDisplayView into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_TopLevel textDisplayView
   put the stack_Name of textDisplayView into stackName
   toplevel stackName
end menu_TopLevel

on _
end _

on menu_EditThisTemplate mTarget
   put the displayed_File of mTarget into someFile  
   text_EditFile someFile
end menu_EditThisTemplate

on menu_EditTemplate mTarget, templateName
   put library_ScriptTemplateFolder (templateName) into someFile
   launch someFile with "Atom"
   return the result
end menu_EditTemplate

on _
end _

on menu_CopyMergeScriptToClipboard mTarget, templateName
   put script_GetTemplate (templateName) into templateScript
   
   -- could get all the script metadata
   put user_GetName() into ObjectAuthor
   put rev_ScriptObject() into scriptObject
   put the view_Name of scriptObject into viewName
   
   put merge (templateScript) into someScript
   set the clipboarddata ["text"] to merge (someScript)
   
   put someScript
   opn_Notify "Script copied to clipboard!"
end menu_CopyMergeScriptToClipboard



--> Menu | Props
-
-- on menu_Init
   put menu_GetTargetObject() into tObject
   if word 1 of tObject = "card" then put the long id of grp 1 of tObject into tObject
   put the textDisplay_View of tObject into textDisplayView
   put textDisplayView into LocalArray ["textDisplayView"]   
end menu_Init

-- getprop menu_Target [mTitlePath]
   put LocalArray ["textDisplayView"]  into textDisplayView
   return textDisplayView
end menu_Target


--> Deps
-
command text_EditFile someFile
   launch someFile with "Atom"
   return the result
   
   put "edit" && kwote(someFile) into someShell
   put shell (someShell) into shellResult
end text_EditFile

