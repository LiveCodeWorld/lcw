script "lib_Scaffolding"
--> MetaData
-
license: GPLv3
name: lib_Scaffolding
type: library
version: 0.1


--> Script | Templates
-
function script_GetTemplate templateName
   put script_ConstructTemplateUrl (templateName) into someUrl
   put url someUrl into someScript
   return someScript
end script_GetTemplate

command script_SetTemplate templateName, someScript
   put library_ScriptTemplateFolder (templateName) into someFile
   file_CreateText someScript, someFile
   put the result into savedFile
   return savedFile
end script_SetTemplate

function script_ConstructTemplateUrl templateName
   put library_ScriptTemplateFolder (templateName) into someFile
   return "file:" & someFile
end script_ConstructTemplateUrl

command script_DeleteTemplate templateName
    put library_ScriptTemplateFolder (templateName) into someFile
    file_Delete someFile
    return someFile
end script_DeleteTemplate

function script_TemplateNames
    put library_ScriptTemplateFolder() into scriptTemplateFolder
    return folder_ShortFiles(scriptTemplateFolder)
end script_TemplateNames
