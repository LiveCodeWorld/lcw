script "model_Library"
--> MetaData
-
license: GPLv3
name: model_Library
type: model
version: 0.1

/*
This model provides an interface to all the standard files and folders used for Library management.
*/


--> Currently Working On
-
function library_ViewFolder shortFileBit, pDontCreate
   return library_StandardViewFolder (shortFileBit, pDontCreate)
end library_ViewFolder

function library_StackFolder shortFileBit, pDontCreate
   -- same as "library_StandardFolder" ???
   return library_PluginFolder ("opn_Libraries/", pDontCreate) & shortFileBit
end library_StackFolder

function library_GetTextStackFolder shortFileBit, pDontCreate
   put library_PluginFolder ("opn_Text/rev/object/", pDontCreate) & shortFileBit into standardFolder
   if there is a folder standardFolder then
      return standardFolder
   else
      return empty
   end if
end library_GetTextStackFolder


--> Library | Folders | Standard | List
-
function library_ListStandardLibs
   put library_StandardLibFolder() into oldStackLibFolder
   
end library_ListStandardLibs



--> Library | Folders | Standard
-
/*
These are the standard old location of library folders within the revIDE plugin directory.
They are now slowly being moved to lcw folders in their own repository anywhere on your system.
*/

function library_StandardBehaviorFolder pShortFileBit
   put library_PluginFolder ("opn_Behaviors/", true) into standardFolder
   if there is a folder standardFolder then
      return standardFolder & pShortFileBit
   else
      return empty
   end if
end library_StandardBehaviorFolder

function library_StandardFolder pShortFileBit
   -- this is the old stack based library folder
   put library_PluginFolder ("opn_Libraries/", true) into standardFolder
   if there is a folder standardFolder then
      return standardFolder & pShortFileBit
   else
      return empty
   end if
end library_StandardFolder

function library_StandardLibFolder pShortFileBit
   -- this is the old place for the newer script_only library folder
   -- put library_PluginFolder ("opn_Text/rev/libraries/", pDontCreate) into standardFolder
   
   breakpoint
   put lcw_GetFolder ("library") into standardFolder
   if there is a folder standardFolder then
      return standardFolder & pShortFileBit 
   else
      return empty
   end if
end library_StandardLibFolder

function library_StandardViewFolder pShortFileBit
   put library_PluginFolder ("opn_Components/views/", true) into standardFolder
   if there is a folder standardFolder then
      return standardFolder & pShortFileBit
   else
      return empty
   end if
end library_StandardViewFolder

function library_StandardModelFolder pShortFileBit
   -- this is the old place for the newer script_only model folder
   -- put library_PluginFolder ("opn_Model/", true) into standardFolder
   
   breakpoint
   put lcw_GetFolder ("library") into standardFolder
   if there is a folder standardFolder then
      return standardFolder & pShortFileBit
   else
      return empty
   end if
end library_StandardModelFolder


--> Library | Folders
-
function library_ArrayFolder shortFileBit, pDontCreate
   return library_PluginFolder ("opn_Text/array/", pDontCreate) & shortFileBit
end library_ArrayFolder

function library_PluginFolder pSubFolder, pDontCreate
   put revEnvironmentUserPluginsPath() & "/" into opnRootFolder
   put opnRootFolder & "opn_Plugins/" into someFolder
   
   if pSubFolder is not empty then
      folder_Format pSubFolder
      put pSubFolder after someFolder
   end if
   
   if pDontCreate is not true then folder_CreateNested someFolder
   return someFolder
end library_PluginFolder


--> Library | Add and Remove
-
command library_RemoveStackFromAllProjects stackObjects
   put library_ListProjectNames() into projectNames
   repeat for each line projectName in projectNames
      if projectName is among the items of "All,None" then next repeat
      
      repeat for each line stackObject in stackObjects
         library_DeleteUsedStack stackObject, projectName
         library_DeleteBackObject stackObject, projectName
         library_DeleteFrontObject stackObject, projectName
      end repeat
   end repeat
end library_RemoveStackFromAllProjects


--> Library | Text Files
-
function library_TextUrl shortName, folderName, folderOwnerName, pDontCreate
   -- here we could also switch to online mode and fetch from an http url
   put library_TextFile (shortName, folderName, folderOwnerName, pDontCreate) into localFile
   if localFile is empty then return empty
   return "binfile:" & localFile
end library_TextUrl

function library_TextFile shortName, folderName, folderOwnerName, pDontCreate
   return library_TextFolder (folderName, folderOwnerName, pDontCreate) & shortName
end library_TextFile

function library_TextFolder folderName, folderOwnerName, pDontCreate
   put merge ("opn_Text/rev/[[folderOwnerName]]/[[folderName]]/") into somePath
   return library_PluginFolder (somePath, pDontCreate)
end library_TextFolder


--> Library | Files
-
function pref_File pModelName
   put library_PrefFolder ("opn_pref.array") into someFile
   return someFile
end pref_File

function library_CallsFile hKey, pDontCreate
   put library_HandlerFile (hKey, "links.txt", pDontCreate) into someFile
   return someFile
end library_CallsFile

function library_DotFile hKey, pVersionName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "dot" into shortFile
   put library_HandlerFile (hKey, shortFile, pDontCreate) into someFile
   return someFile
end library_DotFile

function library_HandlerFile hKey, pShortFileBit, pDontCreate
   -- returns empty if there is no folder, but the filename if there is
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   if there is not a folder hkeyFolder then return empty
   put pShortFileBit after hkeyFolder
   return hkeyFolder
end library_HandlerFile

function library_ViewFiles pDontFilter
   put library_ViewFolder() into libraryFolder
   put folder_FilesInside (libraryFolder) into opnLibraryFiles
   if pDontFilter is not true then filter opnLibraryFiles with "*.rev"
   return opnLibraryFiles
end library_ViewFiles


--> Library | Folders | List
-
function library_ListTextStackFolders
   put library_GetTextStackFolder() into someFolder
   put folder_FoldersInside (someFolder) into textStackFolders
   return textStackFolders
end library_ListTextStackFolders

function library_ListHkeyFolders
   put library_HandlerFolder() into someFolder
   put folder_FoldersInside (someFolder) into hkeyFolders
   return hkeyFolders
end library_ListHkeyFolders

function library_ListLibraryFolderFiles
   put library_StandardFolder() into libraryFolder
   put folder_FilesInside (libraryFolder) into opnLibraryFiles
   filter opnLibraryFiles with (libraryFolder & "libOPN_*")
   return opnLibraryFiles
end library_ListLibraryFolderFiles

function library_ListModelFolderFiles
   put library_StandardModelFolder() into libraryFolder
   put folder_FilesInside (libraryFolder) into opnLibraryFiles
   filter opnLibraryFiles with (libraryFolder & "libOPN_*")
   return opnLibraryFiles
end library_ListModelFolderFiles


--> Library | Folders | Handler
-
function library_HandlerFolder shortFileBit, pDontCreate
   return library_PluginFolder ("opn_Text/rev/handlers/", pDontCreate) & shortFileBit
end library_HandlerFolder

function library_HkeyFolder hKey, pDontCreate
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   put hkey_FolderName (shortHkey) into folderName
   put library_HandlerFolder (folderName, pDontCreate) into hkeyFolder
   if folderName is not empty then put "/" after hkeyFolder
   
   if pDontCreate is false then folder_CreateNested hkeyFolder
   return hkeyFolder
end library_HkeyFolder

function library_HandlerMetadataFolder hKey, pDontCreate
   -- for the handler/hkey library metadata is in the same folder as the scripts
   -- in the project handler export - handlers and metadata are in separate roots.
   put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   return hkeyFolder
end library_HandlerMetadataFolder


--> Library | Folders | Prefs
-
function library_PrefFolder shortFile
   put pref_Folder() & "OPN/" into opnPreferenceFolder
   folder_CreateNested opnPreferenceFolder
   put shortFile after opnPreferenceFolder
   return opnPreferenceFolder
end library_PrefFolder

function pref_Folder
   -- "preference" folders are not standard on all operating systems.
   if the platform is "MacOS" then
      return specialfolderpath ("preferences") & "/"
   else if the platform is "Win32" then
      /*
      CSIDL_APPDATA (FOLDERID_RoamingAppData)
      version 4.71. The file system directory that serves as a common repository for application-specific data. 
      A typical path is C:\Documents and Settings\username\Application Data. 
      This CSIDL is supported by the redistributable Shfolder.dll for systems 
      that do not have the Microsoft internet Explorer 4.0 integrated shell installed.
      
      CSIDL_LOCAL_APPDATA (FOLDERID_LocalAppData)
      version 5.0. The file system directory that serves as a data repository for local (nonroaming) applications. 
      A typical path is C:\Documents and Settings\username\Local Settings\Application Data.
      
      CSIDL_APPDATA (0x001a)
      version 4.71. The file system directory that serves as a common repository for application-specific data. 
      A typical path is C:\Documents and Settings\username\Application Data. 
      This CSIDL is supported by the redistributable Shfolder.dll for systems that do not have the Microsoft internet Explorer 4.0 integrated shell installed.
      */
      put specialfolderpath(baseconvert("0x001a",16,10)) into preferenceFolder
      return preferenceFolder & "/"
      
      put specialfolderpath("0x001a") & "/MyProgram/" into myPreferences
      -- not tested
      breakpoint
      get specialfolderpath("Documents") & merge("/[[username]]/Application Data/")
      return it
   else
      return $HOME & "/Documents/"	# somewhere better?
      put specialfolderpath("Home") & "/.MyProgram/" into myPreferences
   end if
end pref_Folder
