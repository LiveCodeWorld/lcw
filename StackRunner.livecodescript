script "StackRunner"
--> Metadata
-
license: GPLv3
name: StackRunner
type: project
version: 0.7

/*
This is the StackRunner Home stack.
It is designed to be a minimal script only stack that is run once at startup
It should be possible to be run from disk or loaded remotely using go url.
It should do everything that is needed to get the project up and running, but nothing more.
It should:

-  have no dependencies
-  not depend on script introspection
-  use robust file naming conventions
-  human readable and easy to parse in any language
-  a simple text stack that plays well with revision control

The stack should:

1. Load key minimal libraries for menus and shared dependencies (lib_MenuText, lib_MenuPop, and lib_Commony)
2. Open the Data|View module (provides StackRunner interface)
3. Provide initital startup greeting.
4. Provide a universal name-space reference that all project rely on.
4. Get out the way and not be used again after sartup

*/

--> Events
-
on preOpenStack
   -- shoulld only be called first time
   breakpoint
   if the short name of the defaultstack is not the short name of me then
      pass preOpenStack
   else
      lcw_Init
      -- env_RecursivelyLoadProjects 
   end if
end preOpenStack


--> LCW | Me
-
command lcw_Init
   -- First Init on startup
   -- if the long id of the target is not the long id of me then pass lcw_Init
   -- if "lib_StackRunner" is among the lines of the stacksinuse then return false
   
   # Based on filename for this stack 
   put the filename of me into homeFile
   
   # Use Deps
   put lcw_LibraryFile (homeFile) into libFile
   start using stack libFile
   --
   -- put lcw_ModelFile (homeFile) into modelFile
   -- start using stack modelFile
   
   # Initialise Environment
   -- env_AddToBash -- in "lib_LCW"
   
   # Load LCW
   put lcw_HomeFolder (homeFile) into homeFolder
   project_LoadFromFolder homeFolder
   
   # Do things that require everything loaded
   lcw_PostInit -- could send in 30 ticks
end lcw_Init

command lcw_PostInit
   # Set up Script Editor Hacks
   send "ide_InitLcw" to me in 30 ticks -- in library "lib_IDE"
   
   # Utility
   choose browse tool 
   close stack "revTools"
   
   # Make it pretty
   put the screenrect into stackRect
   add 100 to item 1 of stackRect
   add 100 to item 2 of stackRect
   subtract 100 from item 3 of stackRect
   subtract 100 from item 4 of stackRect
   
   set the rect of me to stackRect
   
   # Old
   -- project_LoadModules homeFile
   -- hkeyLine_LoadPlaceArray
   --  lcw_LoadCustomUserProject
end lcw_PostInit


--> Deps | For Standalone
-
function lcw_LibraryFile homeFile
   -- "lib_LCW" file
   set the itemdelimiter to slash
   put homeFile into libFile
   put "libraries/lib_LCW.livecodescript" into item -1 of libFile
   set the itemdelimiter to comma
   return libFile
end lcw_LibraryFile

function lcw_ModelFile homeFile
   -- "model_LCW" file
   set the itemdelimiter to slash
   put homeFile into modelLcwFile
   put "models/model_LCW.livecodescript" into item -1 of modelLcwFile
   set the itemdelimiter to comma
   return modelLcwFile
end lcw_ModelFile


--> Deps
-
function lcw_HomeFolder homeFile
   put homeFile into homeFolder
   set the itemdelimiter to slash
   put empty into item -1 of homeFolder
   set the itemdelimiter to comma
   return homeFolder
end lcw_HomeFolder

function dataStack_LibraryFile homeFile
   set the itemdelimiter to slash
   put homeFile into libFile
   put "libraries/lib_DataStack.livecodescript" into item -1 of libFile
   set the itemdelimiter to comma
   return libFile
end dataStack_LibraryFile

function dataStack_Name
   return "View|Data"
   return the short name of me
end dataStack_Name

command dataStack_SetDefaultFolder
   put default_FarmFolder() into farmFolder
   dataStack_SetValue "default_FarmFolder", farmFolder
end dataStack_SetDefaultFolder

function dataStack_GetValue propName
   put dataStack_Name() into dName
   return the uOPN [propName] of stack dName
end dataStack_GetValue

command dataStack_SetValue propName, propValue
   put dataStack_Name() into dName
   set the uOPN [propName] of stack dName to propValue
end dataStack_SetValue


