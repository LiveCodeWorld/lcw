script "Global_IDE_Menu"
--> MetaData
-
license: GPLv3
name: Global_IDE_Menu
type: controller
version: 0.1


--> Global | IDE | Menu
-
on menu_ScriptFieldHack
   put scriptEditor_ScriptFieldBehavior() into scriptFieldBehavior
   put rev_ScriptEditorField (0) into scriptEditorField
   
   edit the script of scriptFieldBehavior
   put scriptEditorField
   edit the script of scriptEditorField
   
   menu_Edit "Global | Script | Editor | Menu"
   menu_Edit "Global | Script Editor | Extras | Menu"
end menu_ScriptFieldHack

on menu_ApplyScriptHack
   put scriptEditor_CompileButtonBehavior() into compileButtonBehavior
   put rev_CompileButton (0) into scriptEditorCompileButton
   
   edit the script of compileButtonBehavior
   edit the script of scriptEditorCompileButton
end menu_ApplyScriptHack

on menu_HandlerListHack
   put scriptEditor_HandlerListBehavior() into handlerListBehavior
   put rev_HandlerTreeField (0) into scriptEditorHandlerListField
   
   edit the script of handlerListBehavior
   edit the script of scriptEditorHandlerListField
end menu_HandlerListHack

on menu_RecentChangesHack
   put scriptEditor_HistoryButtonBehavior() into historyBehavior
   put rev_HistoryButton (0) into scriptEditorHistoryButton
   
   edit the script of historyBehavior
   edit the script of scriptEditorHistoryButton
end menu_RecentChangesHack

on menu_FindFieldHack
   put scriptEditor_FindFieldBehavior() into findFieldBehavior
   put rev_SimpleFindField (0) into scriptEditorFindField
   
   edit the script of findFieldBehavior
   edit the script of scriptEditorFindField
end menu_FindFieldHack

on menu_DocFieldHack
   put scriptEditor_DocumentationFieldBehavior() into documentationFieldBehavior
   put rev_ScriptEditorDocField (someNum) into scriptEditorDocField
   
   edit the script of documentationFieldBehavior
   edit the script of scriptEditorDocField
end menu_DocFieldHack

on menu_LaunchDocsHack
   put scriptEditor_LaunchDocsBehavior() into launchDocsBehavior
   put rev_LaunchDocsButton (someNum) into scriptEditorLaunchDocsButton
   
   edit the script of launchDocsBehavior
   edit the script of scriptEditorLaunchDocsButton
end menu_LaunchDocsHack

on _
end _

on menu_EditLivecodeBehaviorButton mTarget, ideBname
   put hArray_GetNamedObjectType (ideBname, "behavior") into ideBehavior
   edit the script of ideBehavior
end menu_EditLivecodeBehaviorButton


--> Global | IDE | Menu | Props
-
getprop ide_BNames
   put hArray_ListBehaviorNames() into bNames
   filter bNames with "behavior_Ide*"
   return bNames
end ide_BNames
