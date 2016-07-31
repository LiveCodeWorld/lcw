script "Global | Script | Merge | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Merge | Menu
type: controller
version: 0.1


--> Global | Script | Merge | Menu
-
on menu_MergeScriptTemplate textDisplayView
   put the view_Text of textDisplayView into mergeScript
   put the displayed_File of textDisplayView into scriptFile
   
   put script_MergeHandlers (scriptFile, mergeScript) into someScript
   set the clipboarddata ["text"] to someScript
   put someScript
   
   answer "Copied merged script to the clipboard."
end menu_MergeScriptTemplate

on _
end _

on menu_EditMyBehavior textDisplayView
   put the behavior of textDisplayView into bObject
   edit the script of bObject
end menu_EditMyBehavior


--> Global | Script | Merge | Menu | Props
-
getprop menu_Target [mTitle]
   put menu_GetTargetObject() into mTarget
   put the textDisplay_View of mTarget into textDisplayView
   return textDisplayView
end menu_Target

