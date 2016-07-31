script "Global_Object_Folder_Menu"
--> MetaData
-
license: GPLv3
name: Global_Object_Folder_Menu
type: controller
version: 0.1


--> Global | Object | Folder | Menu
-
on menu_RevealFolder scriptObject, folderProp
   /*
   switch folderProp
      case "object_Folder"
   end switch
   */
   
   put the folderProp of scriptObject into someFolder
   finder_Reveal someFolder
end menu_RevealFolder

getprop folder_Props
   return "object_Folder,textStack_Folder,-,project_Folder,overlay_Folder"
end folder_Props
