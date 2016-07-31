script "lib_Git"
--> MetaData
-
name: lib_Git
type: library
copyright: David Bovill
license: GPLv3
version: 0.7

/*
A library for working with GIT.
It has not been tested on unix (should work fine), or Windows machines (beware of line ending issues).
*/


--> Currently Working On
-
--> Git | Apply
-
function git_ApplyTestPatch gitUnifiedDiff, pGitRootFolder, pTestDirectory
   if pGitRootFolder is empty then put git_GetRootFolder() into pGitRootFolder
   if pTestDirectory is empty then
      put the tempName & "/" into pTestDirectory
      create folder pTestDirectory
   else
      folder_Format pTestDirectory
   end if
   
   -- finder_Reveal pTestDirectory
   
   put git_ConstructDiffArray (gitUnifiedDiff) into diffArray
   put diffArray ["header"]["original path"] into originalFile
   put diffArray ["header"]["new path"] into newFile
   
   set the itemdelimiter to "/"
   
   delete item 1 of originalFile
   put pGitRootFolder before originalFile
   delete item 1 of newFile
   put pGitRootFolder before newFile
   
   put item -1 of originalFile into originalShortFile
   put item -1 of newFile into newShortFile
   
   put pTestDirectory & "patch.txt" into patchFile
   put gitUnifiedDiff into url ("binfile:" & patchFile)
   -- put gitUnifiedDiff into url ("file:" & patchFile)
   
   put pTestDirectory & originalShortFile into originalTempFile
   put url ("binfile:" & originalFile) into url ("binfile:" & originalTempFile)
   -- put url ("file:" & originalFile) into url ("file:" & originalTempFile)
   
   shell_BashParamEscape patchFile
   shell_BashParamEscape pTestDirectory
   
   put the number of items of pGitRootFolder into pNum
   -- this works I think but complains of "patch unexpectedly ends in middle of line"
   -- put merge("patch --reverse --strip=[[pNum]] --directory=[[pTestDirectory]] --input=[[patchFile]] -o [[pUpdatedFile]]") into someShell
   put merge("patch --reverse --strip=[[pNum]] --directory=[[pTestDirectory]] --input=[[patchFile]]") into someShell
   
   -- put merge("git apply directory=[[pTestDirectory]] [[patchFile]]") into someShell
   -- put merge("git apply directory=[[pTestDirectory]] originalShortFile.patch") into someShell
   
   put shell (someShell) into shellResult
   
   put url ("file:" & originalTempFile) into reversePatchedResult
   
   put pTestDirectory & originalShortFile & ".orig" into originalBackupFile
   put url ("file:" & originalBackupFile) into originalBackupResult
   
   return reversePatchedResult
end git_ApplyTestPatch

command git_ApplyPatchFile patchFile, pOriginalFile, pUpdatedFile
   /*
   --directory=<root>
   Prepend <root> to all filenames. 
   If a "-p" argument was also passed, it is applied before prepending the new root.
   
   For example, a patch that talks about updating a/git-gui.sh to b/git-gui.sh 
   can be applied to the file in the working tree modules/git-gui/git-gui.sh 
   by running git apply --directory=modules/git-gui.
   */
   
   shell_BashParamEscape patchFile
   
   if pUpdatedFile is empty then
      put "-" into pUpdatedFile
   else
      shell_BashParamEscape pUpdatedFile
   end if
   
   if pOriginalFile is empty then
      put merge("patch [[pOriginalFile]] -i [[patchFile]]") into someShell
   else
      shell_BashParamEscape pUpdatedfile
      put merge("git apply directory=[[testDirectory]] [[patchFile]]") into someShell
      --directory=modules/git-gui
      end if
   put shell (someShell) into shellResult
   return shellResult
end git_ApplyPatchFile

function git_ConstructDiffArray unifiedDiff
   local diffArray, headerA, parentNum, oStartNum, oEndNum, nStartNum, nEndNum, pBitNum
   /*
   Chunk header format is modified to prevent people from accidentally feeding it to patch -p1. Combined diff format was created for review of merge commit changes, and was not meant for apply. The
   change is similar to the change in the extended index header:
   
   @@@ <from-file-range> <from-file-range> <to-file-range> @@@
   There are (number of parents + 1) @ characters in the chunk header for combined diff format.
   Unlike the traditional unified diff format, which shows two files A and B with a single column that has - (minus -- appears in A but removed in B), + (plus -- missing in A but added to B), or " " (space
   -- unchanged) prefix, this format compares two or more files file1, file2,... with one file X, and shows how X differs from each of fileN. One column for each of fileN is prepended to the output line to
   note how X's line is different from it.
   */
   
   -- @@ -1,16 +1,36 @@
   git_StripDiffHeader unifiedDiff, headerA
   put headerA into diffArray ["header"]
   repeat for each line someLine in unifiedDiff
      git_DeconstructAtLine someLine, parentNum, oStartNum, oEndNum, nStartNum, nEndNum
      if the result is true then
         if pBitNum is not empty then
            put patchChunk into diffArray ["data"][pBitNum]["patchChunk"]
            put empty into patchChunk
         end if
         add 1 to pBitNum
         put parentNum into diffArray ["data"][pBitNum]["parentNum"]
         put oStartNum into diffArray ["data"][pBitNum]["oStartNum"]
         put oEndNum into diffArray ["data"][pBitNum]["oEndNum"]
         put nStartNum into diffArray ["data"][pBitNum]["nStartNum"]
         put nEndNum into diffArray ["data"][pBitNum]["nEndNum"]
         -- put someLine & CR after patchChunk
      else
         put someLine & CR after patchChunk
      end if
   end repeat
   put patchChunk into diffArray ["data"][pBitNum]["patchChunk"]
   
   return diffArray
end git_ConstructDiffArray

private command git_DeconstructAtLine @someLine, @parentNum, @oStartNum, @oEndNum, @nStartNum, @nEndNum
   put word 1 of someLine into testFirst
   replace "@" with empty in testFirst
   if testFirst is not empty then return false -- a bug or problem in the format
   
   put word 1 of someLine into testFirst
   put wordoffset (testFirst, someLine, 1) into endWordNum
   if endWordNum = 0 then return false -- a bug or problem in the format
   
   -- first char is a space for some reason - thought it should be a CR (ie new line)??? 
   put word 1 to (endWordNum + 1) of someLine into diffBit
   delete char 1 to (the number of chars of diffBit) of someLine
   -- delete word 1 to (endWordNum + 1) of someLine
   
   -- it's OK - lets deconstruct
   put the number of chars of testFirst - 1 into parentNum
   
   -- put token 2 of diffBit into minusToken
   put token 3 of diffBit into oStartNum
   -- put token 4 of diffBit into firstComma
   put token 5 of diffBit into oEndNum
   
   -- put token 6 of diffBit into plusToken
   put token 7 of diffBit into nStartNum
   -- put token 8 of diffBit into secondComma
   put token 9 of diffBit into nEndNum
   return true
end git_DeconstructAtLine

private command git_DeconstructOtherLine @someLine, @diffArray
   switch char 1 of someLine
      case "+"
         -- an added line
         delete char 1 of someLine
         put someLine into diffArray ["added"]
         break
      case "-"
         -- an deleted line
         delete char 1 of someLine
         put someLine into diffArray ["deleted"]
         break
      case " "
         -- line not changed
         delete char 1 of someLine
         put someLine into diffArray ["unchanged"]
         break
   end switch
end git_DeconstructOtherLine

command git_StripDiffHeader @unifiedDiff, @headerA   
   /* -p option produces is slightly different from the traditional diff format.
   1.  It is preceded with a "git diff" header, that looks like this:  diff --git a/file1 b/file2
   The a/ and b/ filenames are the same unless rename/copy is involved.
   */
   
   put line 1 of unifiedDiff into diffCommand
   put diffCommand into headerA ["diff command"]
   delete line 1 of unifiedDiff
   
   /*
   2.  It is followed by one or more extended header lines:
   
   old mode <mode>
   new mode <mode>
   deleted file mode <mode>
   new file mode <mode>
   copy from <path>
   copy to <path>
   rename from <path>
   rename to <path>
   similarity index <number>
   dissimilarity index <number>
   index <hash>..<hash> <mode>
   */
   repeat
      put line 1 of unifiedDiff into someLine
      if word 1 of someLine = "---" then exit repeat
      
      put word 1 of someLine into gitProp
      put word 2 to -1 of someLine into gitValue
      put gitValue into headerA [gitProp]
      delete line 1 of unifiedDiff
      if unifiedDiff is empty then return false -- should not reach this!
   end repeat
   
   diff_StripHeader unifiedDiff, headerA
end git_StripDiffHeader


--> Diff
-
command diff_StripHeader @unifiedDiff, @headerA
   /*
   --- /path/to/original ''timestamp''
   +++ /path/to/new      ''timestamp''
   
   --- a/opn_Plugins/opn_Text/rev/object/libOPN_Menus/card_1560/script.txt
   +++ b/opn_Plugins/opn_Text/rev/object/libOPN_Menus/card_1560/script.txt
   */
   
   -- put word 1 line 1 of unifiedDiff into originalPath
   -- put word 2 line 1 of unifiedDiff into timeStamp
   put line 1 of unifiedDiff into originalPath
   delete word 1 of originalPath
   put originalPath into headerA ["original path"]
   
   put line 2 of unifiedDiff into newPath
   delete word 1 of newPath
   put newPath into headerA ["new path"]
   
   delete line 1 to 2 of unifiedDiff
end diff_StripHeader


--> Git | Script | Diff
-
getprop git_ScriptDiff [pStripGitHeaders]
   -- put the script_RelativeFile of the target into someFile
   put the script_File of the target into someFile
   put git_GetDiff (someFile, pStripGitHeaders) into unifiedDiff
   if word 1 to 3 of unifiedDiff = "fatal: ambiguous argument" then
      if file_IsWithinOpn (someFile) then
         git_AddFile someFile
         put git_GetDiff (someFile, pStripGitHeaders) into unifiedDiff
      end if
   end if
   return unifiedDiff
end git_ScriptDiff

function git_GetDiff someFile, pStripGitHeaders
   /*
   I use to git diff to generate patches that can be applied to remote server to update a project.
   Locally, I run:
   *    git diff --no-prefix HEAD~1 HEAD > example.patch
   Upload example.patch to remote server and run:
   *    patch --dry-run -p0 < example.patch
   If dry-run is successful, I run:
   *    patch -p0 < example.patch
   */
   
   put "git diff" into someShell
   put space & "-u" after someShell
   if pStripGitHeaders is true then put space & "--no-prefix" after someShell
   -- put space & "--text" after someShell  -- Treat all files as text.
   -- put space & "--ignore-space-at-eol" after someShell
   
   git_SetRelativePath someFile
   put space & someFile after someShell
   
   put git_ExecuteShellCommand (someShell) into shellResult
   -- text_UnixToMac shellResult
   return shellResult
end git_GetDiff


--> Git | Script | Revision
-
getprop git_RevisionScript [gitHashOrNum]
   put the script_RelativeFile of the target into objectFile
   put git_GetRevisionScript (objectFile, gitHashOrNum) into someScript
   return someScript
end git_RevisionScript

getprop git_LastCommit
   put the script_File of the target into someFile
   put git_ShowFileHead (someFile) into previousExport
   return previousExport
end git_LastCommit 

getprop git_LastScript [pBackNum]
   put the script_File of the target into relativeFile
   put git_GetLastRevision (relativeFile, pBackNum) into revisionScript
   return revisionScript
end git_LastScript

function git_GetLastRevision relativePath, gitHashOrNum
   /*
   drdave: “ is shell substitution operator. Shell runs the command inside and pastes its stdout over it and then runs the whole command.
   <drdave>	k
   <Ilari>	drdave: And that first one had one ' where there should have been `
   <drdave>	I'm going to need to pass an actual path somewhere - can you give us an example with a path in it?
   <Ilari>	drdave: For instance 'echo foo`echo bar`baz' prints 'foobarbaz'.
   <Ilari>	drdave: git show `git rev-list -1 HEAD -- builtin-mv.c`^:builtin-mv.c
   <drdave>	thanks.... will wrap my head round it :) Not quite got logic of shell substitution operator yet :)
   <Ilari>	drdave: There's also another substitution operator: '$()'. That one can also be nested (and presumably has some other differences as well).
   <drdave>	k
   <drdave>	How would git show `git rev-list -1 HEAD -- builtin-mv.c`^:builtin-mv.c be written long hand then
   <Ilari>	Quite useful to have nested substitutions when playing with commit-tree...
   <drdave>	true
   <drdave>	ah... think I'm getting it - its a sort of merge
   <wshimmy>	arg
   
   <Ilari>	drdave: On my git.git copy (bit out of date), the rev-list resolves to 5aed3c6ab834367292bd7a9b0894177a07afd910, 
   so the shell runs 'git show 5aed3c6ab834367292bd7a9b0894177a07afd910^:builtin-mv.c', 
   which is equivalent to 'git show c8ba6b1b199bf00f227e8fdad4adb5a2147c8160:builtin-mv.c', 
   which resolves to 'git show bce9959293e30925c4b16c40ac33a3f2e0474e30'
   
   <Gitbot>	[git 5aed3c6ab]: http://tinyurl.com/q8ac93 -- builtin-mv.c: check for unversionned files before looking at the destination.
   <drdave>	everything between `xxxxxx` gets run and subsitituted - then the outer shell command is run - something like that ?
   <Ilari>	drdave: Yes.
   */
   
   git_SetRelativePath relativePath
   
   if gitHashOrNum is empty then put 0 into gitHashOrNum
   if gitHashOrNum = 0 then
      put merge("git show HEAD:[[relativePath]]") into someShell
   else if gitHashOrNum = 1 then
      -- put git_GetLastCommitHash(relativePath) into lastCommitHash -- seems really slow
      put merge("git show `git rev-list -1 HEAD -- [[relativePath]]`^:[[relativePath]]") into someShell
   else if gitHashOrNum is a number and gitHashOrNum < 99 then
      put git_GetCommitFileHash (relativePath, gitHashOrNum) into someHash
      put merge("git show [[someHash]]:[[relativePath]]") into someShell
   else
      -- assume it is a hash
      put merge("git show [[gitHashOrNum]]:[[relativePath]]") into someShell
   end if
   
   /*
   put "git show" into someShell
   put space & "HEAD~" & pBackNum & ":" & kwote(relativePath) after someShell
   */
   
   -- display_Lines someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   -- text_UnixToMac shellResult
   return shellResult
end git_GetLastRevision

function git_HashRevision relativePath, someHash
   git_SetRelativePath relativePath
   
   put merge("git show [[someHash]]:[[relativePath]]") into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   -- text_UnixToMac shellResult
   return shellResult
end git_HashRevision

function git_ShowFileHead someFile
   git_SetRelativePath someFile
   shell_BashParamEscape someFile
   put merge("git show HEAD:[[someFile]]") into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   -- text_UnixToMac shellResult
   return shellResult
end git_ShowFileHead

function git_GetRevisionScript relativePath, gitHashOrNum
   if gitHashOrNum is a number then
      return git_GetLastRevision (relativePath, gitHashOrNum)
   else if gitHashOrNum is empty then
      put empty into pGitHash
      put empty into pBeforeTipNum
   else
      put gitHashOrNum into pGitHash
      put empty into pBeforeTipNum
   end if
   
   put merge("git show") into someShell
   put space & git_ConstructFileRevision(relativePath, pGitHash, pBeforeTipNum) after someShell
   
   -- display_Lines someShell, "Shell command"
   put git_ExecuteShellCommand(someShell) into oldScript
   text_UnixToMac oldScript
   return oldScript
end git_GetRevisionScript

function git_ConstructFileRevision objectFile, pGitHash, pBeforeTipNum
   if pGitHash is not empty then
      return pGitHash & ":" & kwote(objectFile)
   else if pBeforeTipNum is a number then
      return kwote(objectFile) & "~" & pBeforeTipNum
   else
      return "master:" & kwote(objectFile)
   end if
end git_ConstructFileRevision

command git_SparseCheckOut
   /*
   is there a way to clone/pull only one directory from remote?
   not really possible
   after you fetch all of the history, then with some effort you can checkout only one directory look for sparse checkout if the latter interests you
      */
end git_SparseCheckOut


--> Git | Props
-
getprop script_CommitComment
   put the long id of the target into scriptObject
   put autoCommitComment (scriptObject) into commitComment
   return commitComment
end script_CommitComment

getprop git_CheckoutFolder
   put the mainstack_File of the target  into objectFile
   put git_GetCheckoutFolder (objectFile) into repoRootFolder
   return repoRootFolder
end git_CheckoutFolder

getprop git_WithinCheckoutFolder [pDontUseGit]
   -- timer_Start word 1 of the params
   put the script_File of the target into someFile
   if pDontUseGit is true then
      put git_FindDotGitFolder (someFile) into checkoutFolder -- slightly faster (2 ticks)
   else
      put git_GetCheckoutFolder (someFile) into checkoutFolder -- uses GIT to check things (3 ticks)
   end if
   -- timer_Stop word 1 of the params
   return checkoutFolder is not empty
end git_WithinCheckoutFolder

getprop git_FileIsTracked
   -- not sure the fastest way to do this
   -- timer_Start "git_FileIsTracked"
   put the git_CheckoutFolder of the target into checkoutFolder
   -- put git_FileLog (someFile) is empty into someBoolean -- takes about a second
   -- timer_Stop "git_FileIsTracked"
   return someBoolean
end git_FileIsTracked

setprop git_FileIsTracked someBoolean
   put the script_File of the target into someFile
   if someBoolean is true then
      git_AddFile someFile
   else
      -- can't undo it?
   end if
end git_FileIsTracked

getprop stack_IsLoaded
   put the stack_Object of the target into stackObject
   put stack_GetIsLoaded (stackObject) into someBoolean
   return someBoolean
end stack_IsLoaded

getprop stack_IsUsed
   put the stack_Name of the target into stackName
   put stack_GetIsUsed (stackName) into someBoolean
   return someBoolean
end stack_IsUsed

getprop git_MetaDataArray
   put the git_CommitHash of the target into commitHash
   put git_BlobHashInfo (commitHash) into logText
   put git_ExtractLogMetadataArray (logText) into metadataArray
   return metadataArray
end git_MetaDataArray

getprop git_LastLog
   put the long id of the target into someObject
   get git_GetRevisionHistory (empty, someObject)
   return it
end git_LastLog

getprop git_StackHashLog [commitHash]
   put the stack_RelativeFile of the target into relativeFile
   put git_StackHashLog (relativeFile, commitHash) into gitLog
   return gitLog
end git_StackHashLog

getprop git_CommitHash [pBackNum]
   put the stack_RelativeFile of the target into relativePath
   put git_GetCommitFileHash (relativePath, pBackNum) into commitHash
   opn_Notify git_HashType (commitHash)
   return commitHash
end git_CommitHash

getprop git_ScriptHash [pBackNum]
   -- will often be commited at the same time as the stack
   -- so often eqauls git_CommitHash
   
   put the script_RelativeFile of the target into relativePath
   put git_GetCommitFileHash (relativePath, pBackNum) into commitHash
   opn_Notify git_HashType (commitHash)
   return commitHash
end git_ScriptHash

getprop git_ScriptFileLog
   put the script_File of the target into someFile
   put git_FileLog (someFile) into someLog
   return someLog
end git_ScriptFileLog

getprop git_BlobHash [commitHash]
   put the git_StackTreeish [commitHash] of the target into stackTreeish
   put git_BlobHashFromTreeish (stackTreeish) into blobHash
   return blobHash
end git_BlobHash

getprop git_StackTreeish [commitHash]
   put the stack_RelativeFile of the target into relativePath
   if commitHash is empty then
      return relativePath
   else
      return commitHash & ":" & relativePath
   end if
end git_StackTreeish

getprop git_RevisionStack [gitHashOrNum]
   put the stack_Object of the target into stackObject
   put the filename of stackObject into someFile
   if someFile is empty then return empty
   
   put git_GetRootFolder() into baseFolder
   file_SetRelativePath someFile, baseFolder
   put git_GetLastRevision (someFile, gitHashOrNum) into binaryStackData
   return binaryStackData
end git_RevisionStack

getprop git_Project
   put the git_CheckoutFolder of the target into gitRootFolder
   put git_GetProjectArray() into gitProjectArray
   put gitProjectArray [gitRootFolder]["project name"] into projectName
   return projectName
end git_Project


--> Git
-
function git_GetCheckoutFolder pFolderOrFile
   -- see also "git_WithinCheckoutFolder"
   put the defaultFolder into oFolder
   if pFolderOrFile is empty then
      put the defaultFolder into pFolderOrFile
   else
      if there is a file pFolderOrFile then
         set the itemdelimiter to "/"
         delete item -1 of pFolderOrFile
      end if
      set the defaultFolder to pFolderOrFile
   end if
   
   put git_Version() into someVersion
   if someVersion begins with "1.7." then
      put "git rev-parse --show-toplevel" into someShell
      put git_PathToCommandLine() into gitPath
      shell_BashParamEscape gitPath
      put gitPath before someShell
      put shell (someShell) into shellResult
      
      set the itemdelimiter to ":"
      if item 1 of shellResult = "fatal" then
         set the defaultFolder to oFolder
         return empty
      end if
      
      put word 1 to -1 of shellResult & "/" into gitRootFolder
   else
      put "git rev-parse --show-cdup" into someShell
      put git_PathToCommandLine() into gitPath
      shell_BashParamEscape gitPath
      put gitPath before someShell
      put shell (someShell) into shellResult
      
      set the itemdelimiter to ":"
      if item 1 of shellResult = "fatal" then
         set the defaultFolder to oFolder
         return empty
      end if
      
      put word 1 to -1 of shellResult into someChars
      put the number of chars of someChars/3 into upCount
      
      set the itemdelimiter to "/"
      put -1 - upCount into minusItem
      put (item 1 to minusItem of pFolderOrFile) into gitRootFolder
      put "/" after gitRootFolder
   end if
   
   -- put git_FindDotGitFolder (someFile) into gitRootFolder -- an older verison could use
   
   set the defaultFolder to oFolder
   return gitRootFolder
end git_GetCheckoutFolder

function stack_GetIsUsed stackName
   set the wholematches to true
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_GetIsUsed

function git_Version
   git_ExecuteShell "git --version"
   put word 3 of the result into someVersion
   return someVersion
end git_Version

command git_Pull
   -- TO PULL A new BRANCH FROM A REMOTE REPOSITORY
   -- put merge("git pull origin [[remoteBranch]]:[[newLocalBranch]]") into someShell
   -- put "git pull" into someShell
   -- put "git pull origin master" into someShell
   put git_CurrentBranchName() into currentBranchName
   put "git pull origin" && kwote (currentBranchName) into someShell
   
   put git_ExecuteShellCommand (someShell) into shellResult
   display_Lines shellResult, someShell
   put the result into displayView
   set the menu_Title of displayView to "Global | Git | Pull | Menu"
end git_Pull

command git_CommitScriptFile scriptObject
   put the script of scriptObject into someScript
   put autoCommitComment (scriptObject) into pCommitComment
   if the optionkey is "Down" then
      put opn_Ask ("Describe your changes...", pCommitComment, false) into pCommitComment
   end if
   file_CreateBinary someScript, scriptFile
   return scriptFile
end git_CommitScriptfile


--> GIT | Stack
-
command stack_RevertLoaded pStackNames, pLockMessages
   -- this needs work!!!
   -- important handler to get robustly right
   -- could be fine tuned to simply act on the stack
   
   if pStackNames is empty then put revLoadedStacks("application") into pStackNames
   if pLockMessages is not false then set the lockmessages to true
   put the defaultstack into oDefault
   repeat for each line stackName in pStackNames
      -- set the defaultstack to stackName
      toplevel stack stackName
      revert
   end repeat
   if pLockMessages is not false then set the lockmessages to false
   library_StopEnvironment
   library_StartEnvironment
   set the defaultstack to oDefault
end stack_RevertLoaded

command git_RevertStack someObject, pCommitHash
   put the stack_Object of someObject into stackObject
   put the stack_RelativeFile of stackObject into relativePath
   
   git_CheckoutRevision relativePath, pCommitHash
   put the result into shellResult
   
   stack_RevertLoaded someFile
   put the result into revertedArray
   return newName
end git_RevertStack

command git_DisplayTempStackFromTreeish treeish, pToFile
   git_ExportFileRevision relativePath, treeish
   put the result into toFile
   
   set lockmessages to true
   put the name of stack toFile into oName
   set the name of stack toFile to (oName && treeish)
   go to stack toFile
   set lockmessages to false
   
   set the destroystack of stack toFile to true
   set the destroywindow of stack toFile to true
end git_DisplayTempStackFromTreeish

command git_RestoreFile relativePath
   /*
   $ git checkout HEAD^ path/to/file
   replaces path/to/file by the contents it had in the commit HEAD^, 
   and also updates the index to match. It does not change branches.
   */
   
   put "git checkout HEAD^" && kwote(relativePath) into someShell
   
   git_SetFull
   put git_GetCheckoutFolder (someFile) into pGitRootFolder
   put git_ExecuteShellCommand (someShell, pGitRootFolder) into shellResult
   return shellResult
end git_RestoreFile

command git_CheckoutRevision relativePath, commitHash
   -- check out and old version of a file or entire folder
   -- put "git checkout" && commitHash && kwote(relativePath) into someShell
   put git_ConstructCheckoutCommand (relativePath, commitHash) into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   return shellResult
end git_CheckoutRevision

function git_ConstructCheckoutCommand relativePath, commitHash
   -- needs to be called from git root
   -- or relatveipath needs to be relative to current folder
   -- git checkout 0f3165fea876ebfa537e5a16f5c505a846e2c7ee -- opn_Plugins/opn_Text/rev/template/
   shell_BashParamEscape relativePath
   put "git checkout" && commitHash && "--" && relativePath into someShell
   return someShell
end git_ConstructCheckoutCommand

command git_DisplayTempStackRevision someObject, commitHash 
   put the stack_Object of someObject into stackObject
   put the filename of stackObject into thisFile
   
   put thisFile into relativePath
   git_SetRelativePath relativePath
   put the short name of stack stackObject into oName
   
   set lockmessages to true
   git_ExportFileRevision relativePath, commitHash
   put the result into toFile
   
   try
      set the name of stack thisFile to ("tempStackName" && oName)
      set the name of stack toFile to (oName && commitHash)
      go to stack toFile
      set the name of stack thisFile to oName
      
      set the destroystack of stack toFile to true
      set the destroywindow of stack toFile to true
      set lockmessages to false
   catch e
      breakpoint
      -- set the name of stack thisFile to oName
      set the name of stackObject to oName
      put url ("binfile:" & toFile)
      answer warning merge ("Problem opening versioned [[stackObject]]!")
      exit to top
   end try
   -- finder_Reveal toFile
end git_DisplayTempStackRevision

command git_ExportFileRevision relativePath, commitHash, pToFile
   if pToFile is empty then
      set the itemdelimiter to "/"
      put the tempName & "/" into someFolder
      folder_CreateNested someFolder
      put someFolder & item -1 of relativePath into pToFile
   end if
   
   put kwote(relativePath) into relativePath
   put merge("git show [[commitHash]]:[[relativePath]]") into someShell
   put space & ">" && kwote(pToFile) after someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult 
   return pToFile
end git_ExportFileRevision


--> GIT | Stash
-
function git_ListStashes
   put git_StashArray() into stashArray
   return keys(stashArray)
end git_ListStashes

function git_StashArray
   /*
   List the stashes that you currently have. 
   Each stash is listed with its name (e.g. stash@{0} is the latest stash, stash@{1}  is the one before, etc.), 
   the name of the branch that was current when the stash was made, 
   and a short description of the commit the stash was based on.
   
   stash@{0}: WIP on submit: 6ebd0e2... Update git-stash documentation
   stash@{1}: On master: 9cc0589... Add git-stash
   
   The command takes options applicable to the git log command to control what is shown and how. See git-log(1).
   */
   
   git_ExecuteShell "git stash list"
   put the result into gitResult
   repeat for each line stashLine in gitResult
      set the itemdelimiter to ":"
      put item 1 of stashLine into stashName
      put word 1 to -1 of item 2 of stashLine into stashArray [stashName]["stashBranch"]
      put word 1 to -1 of item 2 of stashLine into stashArray [stashName]["stashComment"]
   end repeat
   return stashArray
end git_StashArray


--> GIT
-
function git_CurrentBranchName
   -- was "current_BranchName"
   put git_ExecuteShellCommand("git branch") into shellResult
   repeat for each line someLine in shellResult
      if word 1 of someLine = "*" then
         return word 2 to -1 of someLine
      end if
   end repeat
   return empty
end git_CurrentBranchName

function git_SearchRepository grepString
   put "git grep --text -i" && kwote (grepString, "'") into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   return shellResult
end git_SearchRepository

function git_Searchlog @searchString
   /*
   -S<string>
   Look for differences that introduce or remove an instance of <string>. Note that this is different
   than the string simply appearing in diff output; see the pickaxe entry in gitdiffcore(7) for more
   details.
   */
   
   if searchString is empty then put opn_Ask("Search log for string...") into searchString
   put "git log --pretty=oneline -S" & kwote(searchString, "'") into someShell
   -- display_Lines someShell
   set the cursor to watch
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_Searchlog


--> GIT | Files
-
command git_DeleteFile someFile, pForce
   /*
   git rm Documentation/\*.txt
   Removes all *.txt files from the index that are under the Documentation directory and any of its subdirectories.
   
   Note that the asterisk * is quoted from the shell in this example; this lets git, and not the shell, expand the pathnames of files and subdirectories under the Documentation/ directory.
   
   git rm -f git-*.sh
   Because this example lets the shell expand the asterisk (i.e. you are listing the files explicitly), it does not remove subdir/git-foo.sh.
   */
   
   put someFile into bashedFile
   shell_BashParamEscape bashedFile
   
   if pForce is true then
      -- put "git rm --cached" && kwote(mTarget) into someShell
      put merge("git rm --force [[bashedFile]]") into someShell
   else
      put merge("git rm [[bashedFile]]") into someShell
   end if
   put git_ExecuteShellCommand(someShell) into shellResult
   if shellResult begins with "fatal: pathspec '" or shellResult begins with "error:" then
      -- fatal: pathspec 'opn_Plugins/opn_Text/colour/swatch/Beach' did not match any files
      -- assume it is untracked (could check before) ?
      if there is a file someFile then
         delete file someFile
      end if
      -- beep
   end if
   return shellResult
end git_DeleteFile

command git_RenameFile sourceFile, destFile
   -- will do folders as well
   put sourceFile into bashSourceFile
   shell_BashParamEscape bashSourceFile
   put destFile into bashDestFile
   shell_BashParamEscape bashDestFile
   
   put "git mv" into someShell
   put space & bashSourceFile after someShell
   put space & bashDestFile after someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   
   if shellResult is not empty then opn_Notify shellResult, true
   if shellResult begins with "fatal: " or shellResult begins with "error:" then
      -- assume it is untracked (could check before) ?
      if there is a file sourceFile and there is not a file destFile then
         rename file sourceFile to destFile
      end if
   end if
   return shellResult
end git_RenameFile

command git_RenameFolder sourceFolder, destFolder
   folder_Format sourceFolder
   folder_Format destFolder
   git_SetRelativePath sourceFolder
   git_SetRelativePath destFolder
   
   put "git mv" into someShell
   -- put space &  "-f" after someShell -- Force renaming or moving of a file even if the target exists
   -- put space &  "-n" after someShell -- Do nothing; only show what would happen
   
   -- put space & kwote (sourceFolder) after someShell
   -- put space & kwote (destFolder) after someShell
   put space & sourceFolder after someShell
   put space & destFolder after someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   if shellResult is not empty then opn_Notify shellResult, true
   return shellResult
end git_RenameFolder

command git_DeleteFolder someFolder, pForce
   /*
   git rm Documentation/\*.txt
   Removes all *.txt files from the index that are under the Documentation directory and any of its subdirectories.
   
   Note that the asterisk * is quoted from the shell in this example; this lets git, and not the shell, expand the pathnames of files and subdirectories under the Documentation/ directory.
   
   git rm -f git-*.sh
   Because this example lets the shell expand the asterisk (i.e. you are listing the files explicitly), it does not remove subdir/git-foo.sh.
   */
   
   if there is not a folder someFolder then return "Error, folder does not exists!"
   put someFolder into bashFolder
   shell_BashParamEscape bashFolder
   
   if pForce is true then
      put merge("git rm -fr -- [[bashFolder]]") into someShell
   else
      put merge("git rm -r -- [[bashFolder]]") into someShell
   end if
   put git_ExecuteShellCommand(someShell) into shellResult
   
   if shellResult begins with "fatal: pathspec '" or shellResult begins with "error:" then
      -- fatal: pathspec 'opn_Plugins/opn_Text/colour/swatch/Beach' did not match any files
      -- assume it is untracked (could check before) ?
      if there is a folder someFolder then
         -- delete folder someFolder
         revDeleteFolder someFolder
      end if
      -- beep
   end if
   
   return shellResult
end git_DeleteFolder

function git_ScriptFile shortFileBit
   put git_GetRootFolder() into rootFolder
   return repository_ConstructScriptPath(shortFileBit, rootFolder)
end git_ScriptFile


--> GIT | Show
-
function git_HashInfo someHash
   put git_HashType (someHash) into hashType
   
   -- if hashType = "blob" then -- will return the data of the file
   -- else describes tree
   put "git cat-file" into someShell
   put space & hashType after someShell
   put space & someHash after someShell
   
   put git_ExecuteShellCommand(someShell) into hashInfo
   return hashInfo
end git_HashInfo

function git_Show treeish
   -- see also "git_ExportFileRevision"
   git_NormalizeTreeish treeish
   
   put "git show" && treeish into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   -- text_UnixToMac shellResult
   return shellResult
end git_Show

command git_NormalizeTreeish @treeish
   set the itemdelimiter to ":"
   put item 1 of treeish into someHash
   put item 2 of treeish into someFile
   if someFile is not empty then
      git_SetRelativePath someFile
      shell_BashParamEscape someFile
      put someFile into item 2 of treeish
   end if
end git_NormalizeTreeish


--> GIT | Hash
-
function git_GetLastCommitHash relativePath
   -- seems slow
   shell_BashParamEscape relativePath
   put merge("git rev-list -1 HEAD -- [[relativePath]]") into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_GetLastCommitHash

function git_BlobHashFromTreeish treeish
   put "git rev-parse" into someShell
   put space & "--verify" after someShell
   put space & treeish after someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_BlobHashFromTreeish

function git_CommitLogEntry someHash
   -- needs to be a commit, or maybe a tree?
   put "git log --stat -n1" into someShell
   put space & someHash after someShell
   put git_ExecuteShellCommand(someShell) into logText
   return logText
end git_CommitLogEntry

function git_CommitedFiles commitHash, pHashOutline
   -- put merge("git diff --name-only [[commitHash]]^ [[commitHash]]") into someShell
   put "git show --name-status --format=%b" && commitHash into someShell
   put git_ExecuteShellCommand(someShell) into logText
   -- display_Lines logText
   
   repeat for each line relativeFile in logText
      put word 1 of relativeFile into modType
      if modType is among the items of "M,A,D" then
         delete word 1 of relativeFile
         if pHashOutline is true then
            put kwote(commitHash & ":" & relativeFile) into treeish
            put git_BlobHashFromTreeish (treeish) into blobHash
            put html_ConstructNameLink(relativeFile, blobHash) & CR after commitedFiles
         else
            put relativeFile & CR after commitedFiles
         end if
      end if
   end repeat
   delete char -1 of commitedFiles
   return commitedFiles
end git_CommitedFiles

function git_GetCommitFileHash relativePath, pBackNum
   if pBackNum is empty then put "1" into pBackNum
   put git_ReverseFileHashes(relativePath, pBackNum) into shellResult
   return line - 1 of shellResult
end git_GetCommitFileHash

function git_ListFiles
   put "git ls-files --stage" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_ListFiles

function git_ReverseFileHashes relativePath, pMaxNum
   if pMaxNum is empty then put "10" into pMaxNum
   put merge("git rev-list -[[pMaxNum]] HEAD --") && kwote(relativePath) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_ReverseFileHashes

function git_UntrackedFiles
   put git_StatusArray() into someArray
   put someArray ["Untracked files:"] into untrackedFiles
   return untrackedFiles
end git_UntrackedFiles

command git_AddFile someFile
   shell_BashParamEscape someFile
   
   put "git add" into someShell
   put space & someFile after someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_AddFile

command git_AddChanged someFile
   /*
   -u, --update
   Update only files that git already knows about, staging modified content for commit and marking
   deleted files for removal. This is similar to what "git commit -a" does in preparation for making a
   commit, except that the update is limited to paths specified on the command line. If no paths are
   specified, all tracked files in the current directory and its subdirectories are updated.
   */
   
   put "git add --update" into someShell
   if someFile is not empty then
      shell_BashParamEscape someFile
      put space & "--" && someFile after someShell
   end if
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_AddChanged

command git_CommitChanges someComment, pAddIfNew, pViewDiff
   repository_SetCommitComment someComment
   
   put "git commit" into someShell
   if pAddIfNew is not false then put space & "-a" after someShell
   if pViewDiff is not false then put space & "-v" after someShell
   put space & "-m '" & someComment & "'" after someShell
   
   -- opn_Notify someShell, true
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_CommitChanges

command git_HardReset
   put "git reset --hard HEAD" into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   return shellResult
end git_HardReset

command git_CommitFile someFile, someComment, pAddIfNew, pViewDiff
   shell_BashParamEscape someFile
   repository_SetCommitComment someComment
   
   put "git commit" into someShell
   -- if pAddIfNew is not false then put space & "-a" after someShell
   if pViewDiff is not false then put space & "-v" after someShell
   put space & "-m '" & someComment & "'" after someShell
   put space & someFile after someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_CommitFile


--> GIT | Display
-
command git_RefreshDisplay pTreeTitle
   put the git_TreeField of me into gitTreeField
   if pTreeTitle is empty then put the title_Text of gitTreeField into pTreeTitle
   
   switch pTreeTitle
      case "Files in Repository"
         set the cursor to watch
         put git_ExecuteShellCommand ("git ls-files") into commitedFiles
         put file_IndexToOutline (commitedFiles, "outline") into someOutline
         set the tree_Display [pTreeTitle] of gitTreeField to someOutline
         break
      case "Log"
         put "git log --pretty=oneline" into someShell
         -- put space & "-n30" after someShell
         put git_ExecuteShellCommand(someShell) into simpleLog
         put git_LogLinkOutline(simpleLog) into someOutline
         set the tree_Display ["Log"] of gitTreeField to someOutline
         break
      default
         put git_FetchStatusTable() into gitTable
         put git_ConstructStatusOutline(gitTable, pTreeTitle, gitHelp) into someOutline
         set the tree_Display [pTreeTitle] of gitTreeField to someOutline
   end switch
   return someOutline
end git_RefreshDisplay


--> Git | Status
-
function git_StatusArray
   put git_StatusOutline() into someOutline
   put array_FromOutline(someOutline) into someArray
   return someArray
end git_StatusArray

function git_StatusOutline
   put git_FetchStatusTable() into gitTable
   put git_ConstructStatusOutline(gitTable, gitTitle, gitHelp) into someOutline
   return someOutline
end git_StatusOutline

function git_ConstructStatusOutline gitTable,@gitTitle, @gitHelp
   -- display_Text gitTable
   
   filter gitTable without "#   *"
   filter gitTable without "#"
   -- replace (CR & "#" & CR) with ("#" & CR) in gitTable
   replace ("#" & tab & "modified:   ") with tab in gitTable
   replace ("# ") with empty in gitTable
   replace (CR & "#" & tab) with (CR & tab) in gitTable
   
   put line 1 of gitTable into gitTitle
   if word 1 to 2 of gitTitle = "On branch" then
      delete line 1 of gitTable
      put line -1 of gitTable into gitHelp
      -- opn_Notify ("gitHelp:" && gitHelp)
      -- delete line -1 of gitTable
   end if
   
   return gitTable
end git_ConstructStatusOutline

function git_FetchStatusTable pCheckoutFolder
   git_ExecuteShell "git status", pCheckoutFolder
   return the result
end git_FetchStatusTable


--> Git | Log
-
function git_LogLinkOutline simpleLog
   repeat for each line someLine in simpleLog
      put word 1 of someLine into someHash
      put word 2 to -1 of someLine into firstCommentLine
      put html_ConstructNameLink (firstCommentLine, someHash) & CR after someOutline
   end repeat
   delete char -1 of someOutline
   return someOutline
end git_LogLinkOutline

function git_LogLinkArray simpleLog
   repeat for each line someLine in simpleLog
      put word 1 of someLine into someHash
      put word 2 to -1 of someLine into firstCommentLine
      put someHash into logLinkArray [firstCommentLine]
   end repeat
   return logLinkArray
end git_LogLinkArray

function git_FileLogOutline someFile, pHowMany, pAllBranches
   put git_FileLog (someFile, pHowMany, pAllBranches) into simpleLog
   put git_LogLinkOutline (simpleLog) into someOutline
   return someOutline
end git_FileLogOutline

function git_FileCommitHashArray someFile, pHowMany, pAllBranches
   put git_FileLog (someFile, pHowMany, pAllBranches) into simpleLog
   put git_LogLinkArray(simpleLog) into commitHashArray
   return commitHashArray
end git_FileCommitHashArray

function git_HashType someHash
   put "git cat-file -t" into someShell
   put space & someHash after someShell
   
   put git_ExecuteShellCommand (someShell) into hashType
   return hashType
end git_HashType

function git_StackHashLog pRelativeFile, pCommitHash, pLogFormat, pHowMany
   if pLogFormat is empty then put "oneline" into pLogFormat
   
   put "git log" into someShell
   put space & "--pretty=" & pLogFormat after someShell
   
   -- if pHowMany is empty then put "1" into pHowMany
   if pHowMany is not empty then put space &  "-n" & pHowMany after someShell
   
   if pCommitHash is not empty then put space & pCommitHash after someShell
   if pRelativeFile is not empty then
      shell_BashParamEscape pRelativeFile
      put space & "--" && pRelativeFile after someShell
   end if
   
   put git_ExecuteShellCommand (someShell) into logText
   return logText
end git_StackHashLog

function git_FileLog someFile, pHowMany, pAllBranches, pLogFormat
   put "git log" into someShell
   if pAllBranches is not false then put space & "--all" after someShell
   if pLogFormat is empty then put "oneline" into pLogFormat
   if pLogFormat is not empty then put space & "--pretty=" & pLogFormat after someShell
   if pHowMany is not empty then put space & "-n" & pHowMany after someShell
   if someFile is not empty then put space & "--" && kwote(someFile, "'") after someShell
   
   put git_ExecuteShellCommand (someShell) into simpleLog
   return simpleLog
end git_FileLog

function git_GetRevisionHistory gitHash, pObject, pShowDiff
   put "git log --stat -n1" into someShell
   if pShowDiff is not false then put space & "-p" after someShell
   -- put space & "--graph" after someShell
   
   if gitHash is not empty then put space & gitHash after someShell
   if pObject is not empty then
      put the script_RelativeFile of pObject into objectFile
      put space & kwote(objectFile) after someShell
   end if
   
   put git_ExecuteShellCommand(someShell) into logText
   return logText
end git_GetRevisionHistory

function git_LogFormats
   /*
   --pretty[=<format>]
   Pretty-print the contents of the commit logs in a given format, where <format> can be one of oneline,
   short, medium, full, fuller, email, raw and format:<string>. When omitted, the format defaults to
   medium.
   
   Note: you can specify the default pretty format in the repository configuration (see git-config(1)).
   */
   return "oneline,short,medium,full,fuller,email,raw"
end git_LogFormats

function git_ExtractLogMetadataArray logText
   set the itemdelimiter to ":"
   put word 2 of line 1 of logText into metadataArray ["commitHash"]
   put word 1 to -1 of item 2 of line 2 of logText into metadataArray ["commitAuthor"]
   put word 1 to -1 of item 2 of line 3 of logText into metadataArray ["commitDate"]
   
   return metadataArray
end git_ExtractLogMetadataArray


--> GIT | List
-
function git_ListCommitHashes
   put "git rev-list --all" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_ListCommitHashes


--> GIT | List | Tree
-
function git_List treeish
   -- more or less same as "ls"
   /*
   returns something like:
   
   100644 blob 7f111638f983c6a775fbb7eaf12131390e1962f4	.gitignore
   100755 blob a20f8ec233c42d28d68a80b9608d789a22d9cd34	opn.rev
   040000 tree 5ccc83a953bdf3261bbee2b28fad8f9260ea92b1	opn_Plugins
   */
   put "git ls-tree" && treeish into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end git_List


--> GIT | Treeish
-
function git_ConstructTreeish relativePath, gitHashOrNum
   put merge("git show [[gitHashOrNum]]:[[relativePath]]") into someShell
   return someShell
end git_ConstructTreeish


--> GIT | Execute
-
command git_ExecuteShell someShell, pGitRootFolder
   put git_PathToCommandLine() into gitPath
   if pGitRootFolder is empty then put git_GetRootFolder() into pGitRootFolder
   put shell_ExecuteAtRoot (someShell, pGitRootFolder, gitPath) into shellResult
   return word 1 to -1 of shellResult
end git_ExecuteShell

function git_ExecuteShellCommand someShell, pCheckoutFolder
   git_ExecuteShell someShell, pCheckoutFolder
   return the result
end git_ExecuteShellCommand


--> GIT | Projects
-
command git_CloneAndFetch gitURL, pNewRepoFolder
   /*
   Clones a repository into a newly created directory, creates remote-tracking branches for each branch in the cloned repository (visible
   using git branch -r), and creates and checks out an initial branch that is forked from the cloned repository's currently active branch.
   
   After the clone, a plain git fetch without arguments will update all the remote-tracking branches, and a git pull without arguments will
      in addition merge the remote master branch into the current master branch, if any (this is untrue when "--single-branch" is given; see
      below).
      
      This default configuration is achieved by creating references to the remote branch heads under refs/remotes/origin and by initializing
      remote.origin.url and remote.origin.fetch configuration variables.
      */
      
      if pNewRepoFolder is empty then
         answer folder "Choose Git Folder" with git_GetRootFolder()
         if the result is "Cancel" then exit to top
         put it into pNewRepoFolder
      else
         folder_Create pNewRepoFolder
      end if
      set the defaultfolder to pNewRepoFolder
      
      put the folders into oFolders
      
      put "git clone" && gitURL into someShell
      put git_ExecuteShellCommand (someShell, pNewRepoFolder) into shellResult
      if shellResult is not empty then
         opn_Notify shellResult, true
         -- display_Lines shellResult, "GIT clone result"
         -- exit to top
      end if
      
      put the folders into nFolders
      put empty into clonedFolder
      repeat for each line testFolder in nFolders
         if testFolder is not among the lines of oFolders then
            # Changes the active directory in the prompt to the newly cloned "Spoon-Knife" directory
            -- cd Spoon-Knife
            put the defaultfolder & slash & testFolder & slash into clonedFolder
            set the defaultfolder to clonedFolder
            exit repeat
         end if
      end repeat
      if clonedFolder is empty then
         answer warning "Failed to find new cloned repository folder!"
         breakpoint
         -- exit to top
      end if
      
      # Assigns the original repository to a remote called "upstream"
      put "git remote add upstream" && gitURL into someShell
      put git_ExecuteShellCommand (someShell, clonedFolder) into shellResult
      if shellResult is not empty then
         display_Lines shellResult, "GIT error adding upstream remote"
         breakpoint
         -- exit to top
      end if
      
      # Pulls in changes not present in your local repository, without modifying your files
      put "git fetch upstream" into someShell
      put git_ExecuteShellCommand (someShell, clonedFolder) into shellResult
      if shellResult is not empty then
         display_Lines shellResult, "GIT fetching upstream remote"
         -- exit to top
      end if
end git_CloneAndFetch

command git_InitFolder gitRootFolder, pDontAdd
   put the defaultfolder into oDefault
   set the defaultfolder to gitRootFolder
   
   put git_PathToCommandLine() into gitPath
   put gitPath & "git init" into someShell
   put shell(someShell) into shellResult
   opn_Notify shellResult, true
   
   get word 1 to 5 of shellResult
   if it is not "Initialized empty Git repository in" and it is not "Reinitialized existing Git repository in" then
      opn_Notify shellResult, true
      set the defaultfolder to oDefault
      exit to top
   end  if
   
   if pDontAdd is not true then
      git_AddEverything
      if the result is not empty then
         opn_Notify shellResult, true
         breakpoint
         -- exit to top
      end if
   end if
   
   git_SetRootFolder gitRootFolder
   git_AddRootFolderToIndex gitRootFolder
   
   set the defaultfolder to oDefault
   -- git_RefreshDisplay "Git Status"
   return gitRootFolder
end git_InitFolder

command git_AddEverything pSomeFolder
   put the defaultfolder into oDefault
   if pSomeFolder is not empty then set the defaultfolder to pSomeFolder
   
   put gitPath & "git add ." into someShell
   put shell (someShell) into shellResult
   set the defaultfolder to oDefault
   return shellResult
end git_AddEverything


--> GIT | Model
-
function git_TranslateProjectName projectName
   put git_GetProjectArray() into gitProjectArray
   repeat for each key gitFolder in gitProjectArray
      if projectName = gitProjectArray [gitFolder]["project name"] then
         return gitFolder
      end if
   end repeat
   return empty
end git_TranslateProjectName

function git_ListProjectFolders
   put git_GetProjectArray() into gitProjectArray
   put keys(gitProjectArray) into folderIndex
   return folderIndex
end git_ListProjectFolders

command git_AddRootFolderToIndex gitRootFolder, pProjectName
   put git_GetCheckoutFolder (gitRootFolder) into gitRootFolder
   if gitRootFolder is empty then return "Error:  folder is not within a git repository"
   
   if pProjectName is empty then
      set the itemdelimiter to "/"
      put item -1 of gitRootFolder into pProjectName
   end if
   put git_GetProjectArray() into gitProjectArray
   put pProjectName into gitProjectArray [gitRootFolder]["project name"]
   git_SetProjectArray gitProjectArray
   return empty
end git_AddRootFolderToIndex

command git_RemoveProject gitRootFolder
   put git_GetProjectArray() into gitProjectArray
   delete variable gitProjectArray [gitRootFolder]
   return keys(gitProjectArray)
end git_RemoveProject

function git_GetProject pGitRootFolder
   if pGitRootFolder is empty then put git_GetRootFolder() into pGitRootFolder
   put git_GetProjectArray() into gitProjectArray
   put gitProjectArray [gitRootFolder]["project name"] into projectName
   return projectName
end git_GetProject

command git_SetProject projectName
   put git_TranslateProjectName (projectName) into longGitFolder
   git_SetRootFolder longGitFolder
   return longGitFolder
end git_SetProject


--> GIT | Checkout Folder
-
function git_FindDotGitFolder someFile
   if someFile is empty then return false
   
   put someFile into folderAbove
   set the itemdelimiter to "/"
   put the directory into oDirectory
   repeat
      delete item -1 of folderAbove
      if folderAbove is empty then exit repeat
      
      set the directory to folderAbove
      put the folders into shortFolders
      if ".git" is among the lines of shortFolders then
         set the directory to oDirectory
         return folderAbove & "/.git"
      end if
   end repeat
   set the directory to oDirectory
   return empty
end git_FindDotGitFolder

function git_GetRootFolder
   put pref_GetValue ("gitRootFolder") into gitRootFolder
   if gitRootFolder is empty then put revEnvironmentUserPluginsPath() & "/" into gitRootFolder -- a default
   return gitRootFolder
end git_GetRootFolder

command git_SetRootFolder gitRootFolder
   folder_Format gitRootFolder
   pref_SetValue "gitRootFolder", gitRootFolder
   return the result
end git_SetRootFolder


--> GIT | More
-
function git_GetProjectArray
   put library_FetchArray ("GitProjectArray") into gitProjectArray
   return gitProjectArray
end git_GetProjectArray

command git_SetProjectArray gitProjectArray
   library_StoreArray "GitProjectArray", gitProjectArray
end git_SetProjectArray


--> Git | Files
-
command git_SetRelativePath @fileOrFolder
   if char 1 of fileOrFolder is not "/" then return false
   put git_GetRootFolder() into baseFolder
   file_SetRelativePath fileOrFolder, baseFolder
   shell_BashParamEscape fileOrFolder
   return true
end git_SetRelativePath

command git_SetFullPath @relativeFileOrFolder
   if char 1 of fileOrFolder is "/" then return false
   put git_GetRootFolder() into baseFolder
   put baseFolder & relativeFileOrFolder into relativeFileOrFolder
   return true
end git_SetFullPath

function git_LocalIgnoreFile
   put git_GetRootFolder() & ".gitignore" into ignoreFile
   return ignoreFile
end git_LocalIgnoreFile

function git_GlobalIgnoreFile
   put $HOME & "/.gitignore" into ignoreFile
   return ignoreFile
end git_GlobalIgnoreFile

function git_PathToCommandLine
   return empty
   
   put pref_GetValue ("gitPath") into gitPath
   return gitPath
   
   -- put "/opt/local/bin/" into gitPath
   return gitPath
end git_PathToCommandLine


--> Repo
-
function repo_FetchStatusOutline
   put url "http://www.rev-co.de/cgi-bin/git_Status.cgi" into someOutline
   return someOutline
end repo_FetchStatusOutline

function repository_ConstructScriptPath shortFileBit, rootFolder
   put rootFolder & "opn_Plugins/" into opnPluginsFolder
   put opnPluginsFolder & "opn_Text/rev/" into revTextFolder
   put revTextFolder & shortFileBit into scriptTextFile
   
   set the itemdelimiter to "/"
   if char -1 of scriptTextFile = "/" then
      put scriptTextFile into testFolder
   else
      put item 1 to -2 of scriptTextFile into testFolder
   end if
   folder_CreateNested testFolder
   
   return scriptTextFile
end repository_ConstructScriptPath

command repository_SetCommitComment @someComment
   if someComment is empty then
      ask "Give a comment to this commit..." with "auto opn commit"
      if it is empty then
         -- opn_Notify "Sorry, I did not commit these changes as the comment was empty!"
         exit to top
      end if
      put it into someComment
   end if
end repository_SetCommitComment


--> Repository | Local | Event | Helpers
-
command repository_Add someFile, fileIsNew, pCommitComment
   -- file has been created or updated
   switch repository_GetType()
      case "svn"
         if fileIsNew is true then svn_Add someFile
         break
      case "git"
         if pCommitComment is empty then put "opn auto-commit" into pCommitComment
         
         -- if fileIsNew is true then git_AddFile someFile
         git_CommitFile someFile, pCommitComment
         -- opn_Notify pCommitComment, true
         -- git_CommitChanges pCommitComment
         -- send "git_RefreshDisplay" to the target in 2 ticks
         break
   end switch
end repository_Add


--> Deps
-
function stack_GetIsLoaded stackObject
   if there is a stackObject then
      return true
   else
      return false
   end if
   if stackObject is empty then return false
   
   put stack_LoadedPaths() into stackNamePaths
   put word -1 of stackObject into theStackPath
   replace quote with empty in theStackPath
   if theStackPath is among the lines of stackNamePaths then
      return true
   else
      return false
   end if
end stack_GetIsLoaded

function stack_LoadedPaths
   put the mainstacks into stackNames
   repeat for each line stackName in stackNames
      put the filename of stack stackName into theFilePath
      if theFilePath is empty then put stackName into theFilePath
      put theFilePath & CR after stackNamePaths
   end repeat
   delete char -1 of stackNamePaths
   return stackNamePaths
end stack_LoadedPaths


--> File
-
command file_CreateBinary binaryText, pFile
   /*
   Rev uses unix style text internally (numToChar(10) for line endings)
   That is "fld "Text" contains numtochar(10) = true"
   
   If written to a file on a Mac, using URL "file:", they're automatically translated to Macs native numToChar(13).
   if using URL "binfile:", no translation happens, so numToChar(10) is preserved. 
   */
   
   if pFile is empty then
      put the tempname into pFile
   end if
   put folder_Above (pFile) into someFolder
   folder_CreateNested someFolder
   put binaryText into url ("binfile:" & pFile)
   return pFile
end file_CreateBinary

command file_CreateText someText, pFile
   if pFile is empty then
      put the tempname into pFile
   end if
   put folder_Above (pFile) into someFolder
   folder_CreateNested someFolder
   put someText into url ("file:" & pFile)
   return pFile
end file_CreateText

command file_Delete someFile
   -- could check if versioned and use built in repository commands to delete file
   delete file someFile
   return the result
end file_Delete

function file_IsWithinOpn someFile
   put library_PluginFolder() into rootFolder
   return someFile contains rootFolder
end file_IsWithinOpn

function file_IsVersioned someFile
   -- was "file_IsUnderSvn"
   switch repository_GetType() 
      case "svn"
         put svn_GetRootFolder() into rootFolder
         return someFile contains rootFolder
      case "git"
         put git_GetRootFolder() into rootFolder
         return someFile contains rootFolder
      default
         return false
   end switch
end file_IsVersioned

command stack_GoLocal someObject
   put the mainstack of the stack_Object of someObject into mainStackName
   stack_RevertToLocalVersion mainStackName
end stack_GoLocal

command stack_RevertToLocalVersion mainStackName
   stack_RemoveFromMemory mainStackName
   
   put opn_GetFileName(mainStackName) into someFile
   go to stack someFile
   if the result is empty then
      return stackFile
   else
      opn_Notify (the result & CR & someFile), true
      return empty
   end if
end stack_RevertToLocalVersion

command stack_SaveEdited pType, pDisplayObject
   put rev_ListEditedStackNames() into stackNames
   repeat for each line stackName in stackNames
      set the cursor to busy
      _DisplayStackSave stackName, pDisplayObject
      put the result into stackObject
      if stackObject is empty then next repeat
      
      stack_Save stackObject
   end repeat
end stack_SaveEdited

command stack_SaveLoaded pDisplayObject
   put revLoadedStacks ("application") into stackNames
   repeat for each line stackName in stackNames
      set the cursor to busy
      _DisplayStackSave stackName, pDisplayObject
      put the result into stackObject
      if stackObject is empty then next repeat
      
      stack_Save stackObject
   end repeat
end stack_SaveLoaded

private command _DisplayStackSave stackName, pDisplayObject
   if exists(stack stackName) is false then
      opn_Notify merge("Cannot find stack '[[stackName]]'!"), true
      return empty
   else
      put the name of stack stackName into stackObject
      if exists (pDisplayObject) then
         dispatch "display_StackSave stackObject" to pDisplayObject 
      else
         opn_Notify merge("Saved stack '[[stackName]]'!"), false
      end if
   end if
   return stackObject
end _DisplayStackSave

command stack_CloseLoaded
   put revLoadedStacks("application") into stackNames
   repeat for each line stackName in stackNames
      if exists(stack stackName) is false then
         -- shouldn't be!
         breakPoint
         beep
         put merge("exists(stack '[[stackName]]') is false") into someError
         log_Error "stack_CloseLoaded", someError
         next repeat
      end if
      
      if stackName is "OPN" then
         save stack stackName
         stop using stack stackName
         next repeat
      end if
      
      save stack stackName
      -- stack_RemoveFromMemory stackName
      if the owner of stack stackName is empty then
         delete stack stackname
      else
         -- shouldn't be!
         breakPoint
         beep
      end if
   end repeat
end stack_CloseLoaded


--> Private
-
private function autoCommitComment scriptObject, textLine
   put the internet date into someDate
   delete word -1 of someDate
   put someDate & ":  changed script" && the mobile_Name of scriptObject into someSuggestion
   put CR after someSuggestion
   put CR after someSuggestion
   
   if textLine is empty then put "OPN auto-commit" into textLine
   put textLine after someSuggestion
   return someSuggestion
end autoCommitComment
