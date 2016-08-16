script "Global_Script_Folders_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Folders_Menu
type: controller
version: 0.1


--> Global | Script | Folders | Menu
-
on menu_ProjectFolder scriptObject
   put the project_Folder of scriptObject into projectFolder
   display_Folder projectFolder
end menu_ProjectFolder

on menu_OverlayFolder scriptObject
   put the overlay_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_OverlayFolder

on menu_ObjectMetaDataFolder scriptObject
   put the object_MetaDataFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_ObjectMetaDataFolder

on menu_ProjectOverlayFolder scriptObject
   put the project_OverlayFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_ProjectOverlayFolder

on _
end _

on menu_RevealTextStackOverlayFolder scriptObject
   put the textStackOverlay_Folder [false] of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_RevealTextStackOverlayFolder

on menu_RevealTextStackFolder scriptObject
   put the textStack_Folder of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_RevealTextStackFolder
   
on menu_RevealMainstackDotText scriptObject
   put the textStackOverlay_Folder [true] of scriptObject into overlayFolder
   put overlay_ConstructFile ("dot", overlayFolder, "Mainstack Structure") into someFile
   
   display_File someFile
end menu_RevealMainstackDotText

on _
end _

on menu_RevealScriptFile mTarget
   put the script_File of mTarget into someFile
   display_Folder someFile
end menu_RevealScriptFile

on menu_DeleteScriptFile mTarget
   put the script_File of mTarget into someFile
   file_Delete someFile
end menu_DeleteScriptFile

on _
end _

on menu_OpenHandlerLibraryFolder
   put library_HkeyFolder (empty, false) into hkeyFolder
   display_Folder hkeyFolder
end menu_OpenHandlerLibraryFolder


--> Deps
-
command display_File someFile
   put someFile
   if there is a file someFile then
      finder_Reveal someFile
      opn_Notify "Here is the file..."
   else
      answer warning "File does not exist!"
   end if
end display_File

command display_Folder someFolder
   put someFolder
   if there is a folder someFolder then
      finder_Reveal someFolder
      opn_Notify "Here is the folder..."
   else
      answer warning "Folder does not exist!"
   end if
end display_Folder


