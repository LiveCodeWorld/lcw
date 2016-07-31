script "Global_View_Wireframe_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Wireframe_Menu
type: controller
version: 0.2


--> Global | View | Wireframe | Menu
-
on menu_TakePictureOfView viewObject
   wireframe_SnapAndExport viewObject, true
   put the result into imageFile
   
   put the wireframe_LocalhostURL of viewObject into localhostURL
   finder_Reveal imageFile
   
   -- lcw_UploadImage imageFile
   put the wireframe_RemoteURL of viewObject into remoteUrl
   launch url remoteUrl
end menu_TakePictureOfView

on menu_TakePictureOfStack viewObject
   wireframe_SnapAndExport viewObject, true
   put the result into imageFile
   
   put the wireframe_LocalhostURL of viewObject into localhostURL
   finder_Reveal imageFile
   
   -- lcw_UploadImage imageFile
   put the wireframe_RemoteURL of viewObject into remoteUrl
   launch url remoteUrl
end menu_TakePictureOfStack

on menu_ViewSnapshot viewObject, viewHow
   switch viewHow
      case "local file"
         put the wireframe_ImageFile of viewObject into imageFile
         finder_Reveal imageFile
         break
      case "localhost"
         put the wireframe_LocalhostURL of viewObject into localhostURL
         launch url localhostURL
         break
      case "www.livecode.world"
         put the wireframe_RemoteURL of viewObject into remoteURL
         launch url remoteURL
         break
   end switch
end menu_ViewSnapshot

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | View | Wireframe | Menu | Props
-
--> Handlers
-

--> Dev | Menu
-
on menu_RevealIcon templateView
   breakpoint
   put the view_Name of templateView into viewName
   put view_LocalIconFile (viewName) into imageFile
   
   finder_Reveal imageFile
   display_Image imageFile, true, viewName
   display_Lines ( imageFile )
end menu_RevealIcon

on menu_DeletePicture templateView
   breakpoint
   put the view_Name of templateView into viewName
   put view_LocalIconFile (viewName) into imageFile
   file_Delete imageFile
end menu_DeletePicture

on menu_IconifyImage templateView
   breakpoint
   put menu_GetTargetObject() into targetObject
   put the info_Group of targetObject into infoGroup
   put the image_View of infoGroup into iconView
   
   put the view_IconFile of templateView into imageFile
   put url ("binfile:" & imageFile) into someImage
   -- put the image_Contents ["file"] of iconView into someImage
   
   set the resized_Image ["60,60"] of iconView to someImage
   put the result into resizedImage
   put resizedImage into url ("binfile:" & imageFile)
   try
      -- magick_FloodFill imageFile, floodedFile, "white", 40
   catch someError
      -- no library or imagemagick installed?
   end try
   set the image_File of iconView to imageFile
end menu_IconifyImage
