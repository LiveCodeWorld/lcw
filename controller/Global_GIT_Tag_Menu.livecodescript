script "Global_GIT_Tag_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Tag_Menu
type: controller
version: 0.1


--> Global | GIT | Tag | Menu
-
on menu_AddTag
   put opn_Ask ("What do you want to call this tag...") into tagName
   put opn_Ask ("Describe this tag...") into tagMessage
   
   put "git tag -a" && kwote(tagName) into someShell
   put space & "-m" && kwote(tagMessage) after someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   
   if shellResult is not empty then
      beep
      opn_Notify shellResult
   end if
end menu_AddTag

on menu_ShowTaggedFiles tagName
   put "git show" && kwote(tagName) into someShell
   put git_ExecuteShellCommand("git ls-files") into shellResult
   display_Text shellResult
end menu_ShowTaggedFiles


--> Global | GIT | Tag | Menu | Props
-
getprop tag_Names
   put git_ExecuteShellCommand("git tag -l") into tagNames
   return tagNames
end tag_Names


--> Global | GIT | Tag | Menu | Disabled
-
--> Menu | Props
-

