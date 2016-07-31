script "Global_Wiki_Menu"
--> MetaData
-
license: GPLv3
name: Global_Wiki_Menu
type: controller
version: 0.1


--> Global | Wiki | Menu
-
on menu_StartWiki
   set the cursor to watch
   open process wiki for update
   -- Federated Wiki server listening on 3000 in mode: development
   read from process wiki until "Federated Wiki server listening on 3000 in mode: development"
   put it into wikiInfoToParse
   
   put "http://localhost:3000" into localWikiURL
   launch url localWikiURL
end menu_StartWiki

on menu_StopWiki
   if the platform = "MacOS" then
      kill process wiki
   else
      close process wiki
   end if
   -- put the openprocesses
end menu_StopWiki

on _
end _

on menu_UpdateWiki
   set the cursor to watch
   put shell ("npm install -g wiki")
end menu_UpdateWiki

on _
end _

on menu_RevealWikiSiteFolder
   put wiki_GetSiteFolder() into wikiSiteFolder
   finder_Reveal wikiSiteFolder
end menu_RevealWikiSiteFolder

on menu_ShowHiddenFiles mTarget, someBoolean
   finder_SetShowInvisibleFiles someBoolean
   finder_Restart
end menu_ShowHiddenFiles

on menu_RevealWikiModulesFolder
   put wiki_GetModulesFolder() into wikiModulesFolder
   finder_Reveal wikiModulesFolder
end menu_RevealWikiModulesFolder


--> Global | Wiki | Menu | Props
-
getprop show_HiddenFiles
   put finder_GetShowInvisibleFiles() into someBoolean
   return someBoolean
end show_HiddenFiles


--> Global | Wiki | Menu | Disabled
-
getprop disabled_StartWiki
   put the openprocesses into oProcesses
   if "wiki" is among the lines of oProcesses then
      return "delete"
   else
      return false
   end if
end disabled_StartWiki
 
getprop disabled_StopWiki
   put the openprocesses into oProcesses
   if "wiki" is among the lines of oProcesses then
      return false
   else
      return "delete"
   end if
end disabled_StopWiki
