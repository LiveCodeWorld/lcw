script "Global_GIT_Settings_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Settings_Menu
type: controller
version: 0.1


--> Global | GIT | Settings | Menu
-
on menu_ConfigureGitLogin
   put user_GetLogin() into userName
   put opn_Ask("GIT user name...", userName) into userName
   put "git config --global user.name" && kwote(userName) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Text shellResult, "git config --list"
end menu_ConfigureGitLogin

on menu_ConfigureGitEmail
   put user_GetEmail() into userEmail
   put opn_Ask("GIT user email...", userEmail) into userEmail
   put "git config --global user.email" && kwote(userEmail) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Text shellResult, "git config --list"
end menu_ConfigureGitEmail

on menu_IgnoreWhiteSpace
   get git_ExecuteShellCommand("git config --global apply.whitespace nowarn")
   if it is not empty then opn_Notify it, true
   put git_ExecuteShellCommand("git config --list") into shellResult
   display_Text shellResult, "git config --list"
end menu_IgnoreWhiteSpace

on menu_DisplayGitConfig
   put git_ExecuteShellCommand("git config --list") into shellResult
   display_Text shellResult, "git config --list"
end menu_DisplayGitConfig

on _
end _

on menu_EditLocalGitIgnoreFile
   put git_LocalIgnoreFile() into ignoreFile
   if there is not a file ignoreFile then
      answer "Create and edit new global .ignore file in the $HOME directory?" with "Cancel" and "OK"
      if it is "Cancel" then exit to top
      git_CreateIgnoreFile true, pIgnoreType
   end if
   
   display_TextFile ignoreFile, "Git Ignore Files"
   edit_TextFile ignoreFile
end menu_EditLocalGitIgnoreFile

on menu_EditGlobalGitIgnoreFile
   put git_GlobalIgnoreFile() into ignoreFile
   if there is not a file ignoreFile then
      answer "Create and edit new global .ignore file in the $HOME directory?" with "Cancel" and "OK"
      if it is "Cancel" then exit to top
      git_CreateIgnoreFile true, pIgnoreType
   end if
   
   display_TextFile ignoreFile, "Git Ignore Files"
   edit_TextFile ignoreFile
end menu_EditGlobalGitIgnoreFile

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | GIT | Settings | Menu | Props
-
--> Menu | Props
-

--> Dev | Menu
-
on menu_OverwriteIgnoreFile mTarget, menuChoice
   set the cursor to watch
   switch menuChoice
      case "Global"
         git_CreateIgnoreFile true
         put the result into ignoreFile
         break
      case "Local"
         git_CreateIgnoreFile
         put the result into ignoreFile
         break
   end switch
   display_TextFile ignoreFile, "Git Ignore Files"
   git_RefreshDisplay
end menu_OverwriteIgnoreFile

on menu_TestIgnoreFile mTarget, menuChoice
   switch menuChoice
      case "Global"
         put git_GlobalIgnoreFile() into ignoreFile
         break
      case "Local"
         break
         put git_GlobalIgnoreFile() into ignoreFile
   end switch
   
   put url ("binfile:" & ignoreFile) into ignoreText
   put text_LineEndingPlatform (ignoreText) into somePlatform
   opn_Notify somePlatform, true
end menu_TestIgnoreFile

on menu_FixGitIgnoreFile
   put git_GlobalIgnoreFile() into ignoreFile
   
   put "binfile:" & ignoreFile into someUrl
   put url someUrl into ignoreText
   replace CR with empty in ignoreText
   put ignoreText into url someUrl
end menu_FixGitIgnoreFile


--> Dev | Menu | Props
-
command git_CreateIgnoreFile pIsGlobal, pIgnoreType
   put git_ConstructIgnoreText ("LF") into ignoreText
   if pIsGlobal is true then
      put git_GlobalIgnoreFile() into ignoreFile
   else
      put git_LocalIgnoreFile() into ignoreFile
   end if 
   put "binfile:" & ignoreFile into someUrl
   put ignoreText into url someUrl
   
   put ignoreFile into bashFile
   shell_BashParamEscape bashFile
   if pIsGlobal is true then
      put "git config --global core.excludesfile" && bashFile into someShell
   else
      put "touch" & bashFile into someShell
   end if
   git_ExecuteShell someShell
   return ignoreFile
end git_CreateIgnoreFile

function git_ConstructIgnoreText pIgnoreType
   switch pIgnoreType
      case "LF"
         put "*.gitignore" & LF after ignoreText
         -- put "*.DS_Store" & LF after ignoreText
         -- put "*.svn/*" & LF after ignoreText
         --put "opn_Plugins/opn_Third/*" & lineEnding after ignoreText
         return ignoreText
      default -- case "CR"
         put "*.gitignore" & LF after ignoreText
         put "*.DS_Store" & CR after ignoreText
         put ".svn*" & CR after ignoreText
         put "*.gitignore" & CR after ignoreText
         -- put "opn_Plugins/opn_Third/*" & lineEnding after ignoreText
         return ignoreText
   end switch
end git_ConstructIgnoreText

function text_LineEndingPlatform someText
   if someText contains CRLF then
      return "Windows"
   else if someText contains LF then
      return "Unix"
   else if someText contains CR then
      return "Mac"
   else
      return empty
   end if
end text_LineEndingPlatform
