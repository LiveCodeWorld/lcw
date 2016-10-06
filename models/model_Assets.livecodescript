script "model_Assets"
--> MetaData
-
license: GPLv3
name: model_Assets
type: model
version: 0.3


--> Asset | Utils
-
command asset_DownloadHtml someUrl, projectName, pShortFile
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of someUrl into pShortFile
   end if
   put asset_GetFile (projectName, pShortFile) into htmlFile
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

getprop project_HtmlFiles [shortFolder]
   put the project_Name of the target into projectName
   put asset_ListFiles (projectName, shortFolder, false) into someFiles
   return someFiles
end project_HtmlFiles

getprop project_ShortHtmlFiles [shortFolder]
   put the project_Name of the target into projectName
   put asset_ListFiles (projectName, shortFolder, true) into someFiles
   return someFiles
end project_ShortHtmlFiles

getprop project_ImageFile [shortFile]
   put the project_Name of the target into projectName
   put asset_GetImageFile (projectName, shortFile) into imageFile
   return imageFile
end project_ImageFile

getprop project_ImageFiles
   put the project_Name of the target into projectName
   put asset_ListFiles (projectName, "img", false) into someFiles
   return someFiles
end project_ImageFiles

getprop project_ShortImageFiles
   put the project_Name of the target into projectName
   put asset_ListFiles (projectName, "img", true) into someFiles
   return someFiles
end project_ShortImageFiles

getprop project_CssFile [shortFile]
   put the project_Name of the target into projectName
   put asset_GetCssFile (projectName, shortFile) into cssFile
   return cssFile
end project_CssFile

getprop project_JavascriptFile [shortFile]
   put the project_Name of the target into projectName
   put asset_GetJavascriptFile (projectName, shortFile) into jsFile
   return jsFile
end project_JavascriptFile

getprop project_ImageFolder [shortFile]
   put the project_Name of the target into projectName
   put asset_GetJavascriptFile (projectName) into imageFile
   return imageFile
end project_ImageFolder

getprop project_CssFolder
   put the project_Name of the target into projectName
   put project_GetCssFolder (projectName) into cssFolder
   return cssFolder
end project_CssFolder

getprop project_JavascriptFolder
   put the project_Name of the target into projectName
   put asset_GetJavascriptFolder (projectName) into jsFolder
   return jsFolder
end project_JavascriptFolder

getprop project_AssetFiles [shortFolder]
   put the project_AssetFolder [shortFolder] of the target into assetFolder
   put folder_ListFiles (assetFolder) into assetFiles
   return assetFiles
end project_AssetFiles

getprop project_ShortAssetFiles [shortFolder]
   put the project_AssetFolder [shortFolder] of the target into assetFolder
   put folder_ListShortFiles (assetFolder) into assetFiles
   return assetFiles
end project_ShortAssetFiles

getprop project_AssetFolder [shortFolder]
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into somePath
   project_FindFromPath somePath, homeStackName, projectFolder, projectStackPath
   if exists (stack projectStackPath) is false then return empty
   
   put projectFolder & "assets/" into assetFolder
   if shortFolder is not empty then put shortFolder and slash after assetFolder
   return assetFolder
end project_AssetFolder


--> Asset | Model
-
function asset_GetText projectName, shortFile, pShortAssetFolder
   put asset_GetFile (projectName, shortFile, pShortAssetFolder) into someFile
   put url ("file:" & someFile) into someText
   return someHTML
end asset_GetText

command asset_SetText projectName, shortFile, someText, pShortAssetFolder
   put asset_GetFile (projectName, shortFile, pShortAssetFolder) into someFile
   put "file:" & someFile into someURL
   put someText into url someURL
   return someURL
end asset_SetText


--> Asset | Files
-
function asset_ListFiles projectName, shortFolder, pListShort, pSomeFilter
   put asset_GetFolder (projectName, shortFolder) into assetFolder
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

function asset_GetFile projectName, shortFile, pShortAssetFolder
   put asset_GetFolder (projectName, pShortAssetFolder) into htmlFolder
   put htmlFolder & shortFile into htmlFile
   return htmlFile
end asset_GetFile

function asset_GetImageFile projectName, shortFile
   put asset_GetFolder (projectName, "img") into imageFolder
   put imageFolder & shortFile into imageFile
   return imageFile
end asset_GetImageFile

function asset_GetCssFile projectName, shortFile
   put asset_GetFolder (projectName, "css") into imageFolder
   put cssFolder & shortFile into cssFile
   return cssFile
end asset_GetCssFile

function asset_GetJavascriptFile projectName, shortFile
   put asset_GetFolder (projectName, "js") into imageFolder
   put jsFolder & shortFile into jsFile
   return jsFile
end asset_GetJavascriptFile


--> Asset | Folders
-
function asset_GetJavascriptFile projectName
   put asset_GetFolder (projectName, "img") into cssFolder
   return cssFolder
end asset_GetJavascriptFile

function project_GetCssFolder projectName
   put asset_GetFolder (projectName, "css") into cssFolder
   return cssFolder
end project_GetCssFolder

function asset_GetJavascriptFolder projectName
   put asset_GetFolder (projectName, "js") into jsFolder
   return jsFolder
end asset_GetJavascriptFolder

function asset_GetFolder projectName, shortAssetFolder
   put "assets/" into subFolderPath
   if shortAssetFolder is not empty then
      put shortAssetFolder after subFolderPath
      text_AddTrailing subFolderPath, slash
   end if
   put project_GetFolder (projectName, subFolderPath) into assetFolder
   folder_CreateNested assetFolder
   return assetFolder
end asset_GetFolder
