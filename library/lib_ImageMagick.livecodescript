script "lib_ImageMagick"
--> MetaData
-
license: GPLv3
name: lib_ImageMagick
type: library
version: 0.1


function imageMagick_FetchGpsArray imageURL
   put merge ("wget -O - [[imageURL]] | identify -format '%[EXIF:GPS*]' -") into someShell
   put shell (someShell) into gpsArray
   filter gpsArray with "exif:*"
   replace "exif:" with empty in gpsArray
   split gpsArray with CR and "="
   return gpsArray
end imageMagick_FetchGpsArray

function imageMagick_FetchIdentityArray imageURL
   -- put merge ("wget -O - [[imageURL]] | identify -") into someShell
   put the tempname into imagePath
   put url imageURL into url ("binfile:" & imagePath)
   
   put imagePath into gpsArray ["imagePath"]
   put "identify" && imagePath into someShell
   put shell (someShell) into identityInfo
   put identityInfo into gpsArray ["identify"]
   return gpsArray
end imageMagick_FetchIdentityArray

