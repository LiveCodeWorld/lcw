script "lib_Wireframe"
--> MetaData
-
license: GPLv3
name: lib_Wireframe
type: library
version: 0.1


--> Display
-
command display_Wireframe shortFile
   put localhost_ConstructImageUrl (shortFile) into imageURL
   launch url imageURL
end display_Wireframe


--> Wireframe
-
command wireframe_SnapAndExport pSomeControl, pDisplaySnapShot
   if pSomeControl is empty then put the selObj into selObj
   if exists (pSomeControl) is false then
      put the topstack into stackName
      answer "Not done yet!"
      exit to top
      return empty
   else
      put the wireframe_ImageShortFile of pSomeControl into shortFile
      put the wireframe_Snap of pSomeControl into somePNG
      localhost_SavePng somePNG, shortFile
      put the result into imageFile
   end if
   
   if pDisplaySnapShot is true then
      display_Wireframe shortFile
   end if
   return imageFile
end wireframe_SnapAndExport

function wireframe_GetSnapPng someControl, newW
   -- let's scale the export to wiki width
   put 420 into newW
   
   put the rect of someControl into originalRect
   put scale_Height (originalRect, newW) into newH
   put newW,newH into exportDimensions
   
   export snapshot from someControl at size exportDimensions to someImage as PNG
   return someImage
end wireframe_GetSnapPng


--> Wireframe | Props
-
getprop wireframe_Snap [pDimensions]
   put the long id of the target into someControl
   
   -- should do something clever with pDimensions
   -- for now we just assume it is a new width if it is there
   if pDimensions is empty then
      put 420 into newW
   else
      put item 1 of pDimensions into newW
   end if
   put wireframe_GetSnapPng (someControl, newW) into somePNG
   return somePNG
end wireframe_Snap

getprop wireframe_StackSnap 
   put the long id of the target into someControl
   
   -- the stack needs to be open and visible, and on top
   put the stack_Name of someControl into stackName
   -- object_GoTo someControl -- this will go to the card
   -- toplevel stackName
   put the windowid of stack stackName into someWindowID
   
   -- export snapshot from rect someRect of window someWindowID to file imageFile as PNG
   -- set the defaultstack to stackName
   put the rect of card 1 of stack stackName into someRect
   export snapshot from rect someRect of window someWindowID to somePNG as PNG
   return somePNG
end wireframe_StackSnap

getprop wireframe_LocalhostURL
   put the wireframe_ImageShortFile of the target into shortFile
   put localhost_ConstructImageUrl (shortFile) into localhostURL
   return localhostURL
end wireframe_LocalhostURL

getprop wireframe_RemoteURL
   put the wireframe_ImageShortFile of the target into shortFile
   put lcw_ConstructImageURL (shortFile) into remoteURL
   return remoteURL
end wireframe_RemoteURL

getprop wireframe_ImageFile
   put the wireframe_ImageShortFile of the target into shortFile
   put localhost_ConstructImagePath (shortFile) into imageFile
   return imageFile
end wireframe_ImageFile

getprop wireframe_ImageShortFile
   put the card_Object of the target into cardObject
   put the short name of cardObject into tidyName
   replace space with "_" in tidyName
   put tidyName & ".png" into shortFile
   return shortfile
end wireframe_ImageShortFile


--> LCW
-
function lcw_ConstructImageURL shortFile
   put "note/" into imageFolderPathbit
   put "http://livecode.world/" & imageFolderPathbit & urlencode(shortFile) into imageURL 
   return imageURL
end lcw_ConstructImageURL


--> localhost
-
command localhost_SavePng somePNG, shortFile
    put localhost_ConstructImagePath (shortFile) into imageFile
   put somePNG into url ("binfile:" & imageFile)
   return imageFile
end localhost_SavePng

function localhost_ConstructImagePath shortFile
   put localhost_GetImageFolder() into imageFolder
   if there is not a folder imageFolder then return empty
   
   put imageFolder & shortFile into imageFile
   return imageFile
end localhost_ConstructImagePath

function localhost_GetImageFolder
   put pref_FetchValue ("localhost_GetImageFolder") into imageFolder
   if there is not a folder imageFolder then
      answer folder "Select a folder for your snapshots..."
      put it into imageFolder
      if imageFolder is empty then exit to top
      text_AddTrailing imageFolder, slash
      pref_SaveValue "localhost_GetImageFolder", imageFolder
   end if
   text_AddTrailing imageFolder, slash
   return imageFolder
end localhost_GetImageFolder

function localhost_ConstructImageUrl shortFile
   put "images/" into imageFolderPathbit
   put "http://localhost/" & imageFolderPathbit & shortFile into imageURL 
   return imageURL
end localhost_ConstructImageUrl
