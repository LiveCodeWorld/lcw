script "model_Assets"
--> MetaData
-
license: GPLv3
name: model_Assets
type: model
version: 0.3


--> Asset | Utils
-
command asset_DownloadHtml someUrl, projectFolder, pShortFile
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of someUrl into pShortFile
   end if
   put asset_GetFile (projectFolder, pShortFile) into htmlFile
   put url someUrl into someHTML 
   put someHTML into url ("file:" & htmlFile)
end asset_DownloadHtml


--> Asset | Props
-
getprop project_Html [shortHtmlFile]
   put the project_HtmlFile [shortHtmlFile] of the target into localFile
   put url ("file:" & localFile) into someHtml
   return someHtml
end project_Html

setprop project_Html [shortHtmlFile] someHtml
   put the project_HtmlFile [shortHtmlFile] of the target into localFile
   put "file:" & localFile into localURL
   put someHtml into url localURL
   return localURL
end project_Html

getprop project_HtmlFile [shortFile]
   put the project_AssetFolder of the target into projectAssetFolder
   put projectAssetFolder & shortFile into imageFile
   return imageFile
end project_HtmlFile

getprop project_HtmlFiles [shortAssetFolder]
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_ListFiles (projectFolder, shortAssetFolder, false) into someFiles
   return someFiles
end project_HtmlFiles

getprop project_ShortHtmlFiles [shortAssetFolder]
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_ListFiles (projectFolder, shortAssetFolder, true) into someFiles
   return someFiles
end project_ShortHtmlFiles

getprop project_ImageFile [shortFile]
   put the project_Name of the target into projectName
   put asset_GetImageFile (projectName, shortFile) into imageFile
   return imageFile
end project_ImageFile

getprop project_ImageFiles
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_ListFiles (projectFolder, "img", false) into someFiles
   return someFiles
end project_ImageFiles

getprop project_ShortImageFiles
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_ListFiles (projectFolder, "img", true) into someFiles
   return someFiles
end project_ShortImageFiles

getprop project_CssFile [shortFile]
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_GetCssFile (projectFolder, shortFile) into cssFile
   return cssFile
end project_CssFile

getprop project_JavascriptFile [shortFile]
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_GetJavascriptFile (projectFolder, shortFile) into jsFile
   return jsFile
end project_JavascriptFile

getprop project_ImageFolder [shortFile]
   put the project_Name of the target into projectName
   put asset_GetJavascriptFile (projectName) into imageFile
   return imageFile
end project_ImageFolder

getprop project_CssFolder
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put project_GetCssFolder (projectFolder) into cssFolder
   return cssFolder
end project_CssFolder

getprop project_JavascriptFolder
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_GetJavascriptFolder (projectFolder) into jsFolder
   return jsFolder
end project_JavascriptFolder

getprop project_AssetFiles [shortAssetFolder]
   put the project_AssetFolder [shortAssetFolder] of the target into assetFolder
   if there is not a folder assetFolder then return empty
   
   put folder_ListFiles (assetFolder) into assetFiles
   return assetFiles
end project_AssetFiles

getprop project_ShortAssetFiles [shortAssetFolder]
   put the project_AssetFolder [shortAssetFolder] of the target into assetFolder
   if there is not a folder assetFolder then return empty
   
   put folder_ListShortFiles (assetFolder) into assetFiles
   return assetFiles
end project_ShortAssetFiles

getprop project_AssetFolder [shortAssetFolder]
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put asset_GetFolder (projectFolder, shortAssetFolder) into assetFolder
   return assetFolder
end project_AssetFolder


--> Asset | Model
-
function asset_GetText projectFolder, shortFile, pShortAssetFolder
   put asset_GetFile (projectFolder, shortFile, pShortAssetFolder) into someFile
   put url ("file:" & someFile) into someText
   return someHTML
end asset_GetText

command asset_SetText projectFolder, shortFile, someText, pShortAssetFolder
   put asset_GetFile (projectFolder, shortFile, pShortAssetFolder) into someFile
   put "file:" & someFile into someURL
   put someText into url someURL
   return someURL
end asset_SetText


--> Asset | Files
-
function asset_ListFiles projectFolder, shortFolder, pListShort, pSomeFilter
   put asset_GetFolder (projectFolder, shortFolder) into assetFolder
   if pListShort is true then
      put files (assetFolder) into assetFiles
      filter assetFiles without ".*"
      if pSomeFilter is not empty then
         filter assetFiles with pSomeFilter
      end if
   else
      put folder_ListFiles (assetFolder, false, pSomeFilter) into assetFiles
   end if
   return assetFiles
end asset_ListFiles

function asset_GetFile projectFolder, shortFile, pShortAssetFolder
   put asset_GetFolder (projectFolder, pShortAssetFolder) into htmlFolder
   put htmlFolder & shortFile into htmlFile
   return htmlFile
end asset_GetFile

function asset_GetImageFile projectFolder, shortFile
   put asset_GetFolder (projectFolder, "img") into imageFolder
   put imageFolder & shortFile into imageFile
   return imageFile
end asset_GetImageFile

function asset_GetCssFile projectFolder, shortFile
   put asset_GetFolder (projectFolder, "css") into imageFolder
   put cssFolder & shortFile into cssFile
   return cssFile
end asset_GetCssFile

function asset_GetJavascriptFile projectFolder, shortFile
   put asset_GetFolder (projectFolder, "js") into imageFolder
   put jsFolder & shortFile into jsFile
   return jsFile
end asset_GetJavascriptFile


--> Asset | Server | Model
-
function server_GetProjectFolder
   put $_SERVER ["DOCUMENT_ROOT"] & slash into projectFolder
   return projectFolder
end server_GetProjectFolder

function asset_GetJSON shortFile, pProjectFolder
   if pProjectFolder is empty then put server_GetProjectFolder() into pProjectFolder
   
   put asset_GetFolder (pProjectFolder, "json") into assetFolder
   put assetFolder & shortFile into jsonFile
   put url ("file:" & jsonFile) into someJSON
   return someJSON
end asset_GetJSON

command asset_SetJSON shortFile, someJSON, pProjectFolder
   if pProjectFolder is empty then put server_GetProjectFolder() into pProjectFolder
   
   put asset_GetFolder (pProjectFolder, "json") into assetFolder
   put assetFolder & shortFile into jsonFile
   put someJSON into url ("file:" & jsonFile)
   return jsonFile
end asset_SetJSON


--> Asset | Folders
-
function asset_GetJavascriptFile projectFolder
   put asset_GetFolder (projectFolder, "img") into cssFolder
   return cssFolder
end asset_GetJavascriptFile

function project_GetCssFolder projectFolder
   put asset_GetFolder (projectFolder, "css") into cssFolder
   return cssFolder
end project_GetCssFolder

function asset_GetJavascriptFolder projectFolder
   put asset_GetFolder (projectFolder, "js") into jsFolder
   return jsFolder
end asset_GetJavascriptFolder

function asset_GetFolder projectFolder, shortAssetFolder
   put "assets/" into subFolderPath
   if shortAssetFolder is not empty then
      text_AddTrailing shortAssetFolder, slash
      put shortAssetFolder after subFolderPath
   end if
   put projectFolder & subFolderPath into assetFolder
   folder_CreateNested assetFolder
   return assetFolder
end asset_GetFolder
