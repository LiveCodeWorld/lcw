script "lib_Colour"
--> MetaData
-
license: GPLv3
name: lib_Colour
type: library
version: 0.1
copyright: David Bovill

/*
This library is for working with colour.
*/


--> Deps
-
getprop group_Above
   put the long id of the target into targetObject
   
   if word 1 of targetObject = "group" then
      put targetObject into groupObject
   else
      put targetObject into groupObject
      delete word 1 to 4 of groupObject
   end if
   
   put groupObject into groupAboveObject
   delete word 1 to 4 of groupAboveObject
   if exists(groupAboveObject) is false then put the card_Object of targetObject into groupAboveObject 
   return groupAboveObject
end group_Above

function opn_SwatchFolder swatchName, pDontCreate
   return library_PluginFolder ("opn_Text/colour/swatch/", pDontCreate) & swatchName
end opn_SwatchFolder

function opn_ColourFolder shortFileBit, pDontCreate
   return library_PluginFolder ("opn_Text/colour/", pDontCreate) & shortFileBit
end opn_ColourFolder


--> Colour
-
getprop colour_Name
   return the effective backgroundcolor of the target
end colour_Name

setprop colour_Name colourName
   set the backgroundcolor of the target to colourName
end colour_Name

getprop colour_Names
   return colour_BaseNames()
end colour_Names

getprop colour_Paths
   return colour_MenuOutline()
end colour_Paths

function colour_BaseNames
   put the the colornames into colourNames
   repeat for each line colourName in colourNames
      if last char of colourName is a number then next repeat
      put text_SplitCaps(colourName) into colourWord
      put colourWord & CR after colourWords
   end repeat
   delete last char of colourWords
   -- sort colourWords by the number of words of each
   sort colourWords by word -3 of each
   sort colourWords by word -2 of each
   sort colourWords by word -1 of each
   
   -- sort colourWords by the number of words of each
   -- sort colourWords by last word of each
   return colourWords
end colour_BaseNames

function colour_MenuOutline
   -- a quick hack (number of words does not correspond to level)
   put colour_BaseNames() into colourWords
   repeat for each line colourName in colourWords
      put the number of words of colourName - 1 into thisIndentLevel
      if thisIndentLevel = 0 then
         put colourName & CR after colourOutline
      else
         -- is the lastLine one level below?
         if thisIndentLevel > lastIndentLevel then
            put line -1 of colourOutline into lastline
            put tab & lastLine & CR after colourOutline
         end if
         put text_RepeatString(tab, thisIndentLevel) & colourName & CR after colourOutline
      end if
      put thisIndentLevel into lastIndentLevel
   end repeat
   -- delete last char of colourOutline
   put word 1 to -1 of colourOutline into colourOutline
   return "Ask,-,None" & CR & colourOutline
end colour_MenuOutline

function colour_BaseColourOutline
   put colour_BaseNames() into colourWords
   repeat for each line colourName in colourWords
      put the number of words of colourName - 1 into indentLevel
      put text_RepeatString(tab, indentLevel) & colourName & CR after colourOutline
   end repeat
   -- delete last char of colourOutline
   put word 1 to -1 of colourOutline into colourOutline
   return colourOutline
end colour_BaseColourOutline

on colour_FromMenuPath @someColour, pStripSpaces
   if pStripSpaces is true then replace space with empty in someColour
   
   set the itemdelimiter to "|"
   put item -1 of someColour into someColour
   
   if someColour is "ask" then
      answer color
      put it into someColour
   else if someColour is "none" then
      put empty into someColour
   end if
end colour_FromMenuPath

function colour_GetRandom
   -- was "randomColour"
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom


--> Colour | Palette
-
getprop colour_Palette
   -- a default
   put the long id of the target into targetObject
   if word 1 of targetObject = "group" then
      put targetObject into groupObject
   else
      delete word 1 to 4 of groupObject
   end if
   put the group_Above of targetObject into groupAboveObject
   put the stack_Object of targetObject into stackObject
   
   put the foregroundcolor of targetObject into colourPaletteArray[1]
   put the backgroundcolor of targetObject into colourPaletteArray[2]
   put the backgroundcolor of groupAboveObject into colourPaletteArray[3]
   if exists(groupObject) then
      put the backgroundcolor of groupObject into colourPaletteArray[4]
   else
      put empty into colourPaletteArray[4]
   end if
   put the linkcolor of stackObject into colourPaletteArray[5]
   return colourPaletteArray
end colour_Palette

setprop colour_Palette colourPaletteArray
   -- a default
   put the long id of the target into targetObject
   colour_SetObjectPalette targetObject, colourPaletteArray
end colour_Palette

on colour_SetObjectPalette targetObject, colourPaletteArray
   -- here so we can create custom properties that set child view palettes
   
   lock screen
   if word 1 of targetObject = "group" then
      put targetObject into groupObject
   else
      put targetObject into groupObject
      delete word 1 to 4 of groupObject
   end if
   put the group_Above of targetObject into groupAboveObject
   
   put the stack_Object of targetObject into stackObject
   
   set the foregroundcolor of targetObject to colourPaletteArray[1]
   set the backgroundcolor of targetObject to colourPaletteArray[2]
   if word 1 of groupObject = "group" then set the backgroundcolor of groupObject to colourPaletteArray[4]
   
   if word 1 of groupAboveObject is not "card" then set the backgroundcolor of groupAboveObject to colourPaletteArray[3]
   set the linkcolor of stackObject to colourPaletteArray[5]
   unlock screen
end colour_SetObjectPalette


--> Colour | Swatch | Model
-
function colour_GetSwatchArray swatchName
   put opn_SwatchFolder(swatchName) into swatchFile
   put url ("binfile:" & swatchFile) into encodedArray
   put arraydecode (encodedArray) into swatchArray
   return swatchArray
end colour_GetSwatchArray

on colour_SetSwatchArray swatchName, swatchArray, pAddModifiedDate
   if pAddModifiedDate is not false then
      -- put date_SixDigits (the date) into modifiedDate
      -- put modifiedDate into swatchArray ["themeItem"]["themeEditedAt"]
   end if
   
   put opn_SwatchFolder(swatchName) into swatchFile
   put arrayencode (swatchArray) into encodedArray
   put encodedArray into url ("binfile:" & swatchFile)
end colour_SetSwatchArray

on colour_DeleteSwatchArray swatchName
   put opn_SwatchFolder(swatchName) into swatchFile
   file_Delete swatchFile
end colour_DeleteSwatchArray

function colour_SwatchNames
   put opn_SwatchFolder() into someFolder
   put folder_ShortFiles(someFolder) into swatchNames
   return swatchNames
end colour_SwatchNames

on colour_DeleteSwatch swatchName
   put opn_SwatchFolder(swatchName) into someFile
   if there is a file someFile then
      file_Delete someFile
   end if
end colour_DeleteSwatch  


--> Colour | Conversion
-
command colour_RgbNormalise @someColour, pObject
    -- convert any colour to rgbColour
    switch
        case char 1 of someColour = "#"
            put colour_HexToRgb (someColour) into someColour
            break
        case the number of items of someColour = 3 and char 1 of someColour is a number
            break
        case char 1 of someColour is not a number
            put colour_NameToRgb (someColour, pObject) into someColour
            break
    end switch
end colour_RgbNormalise

command colour_HexNormalise @someColour, pObject
   -- convert any colour to web (hex) colour
   switch
      case char 1 of someColour = "#"
      break
      case the number of items of someColour = 3 and char 1 of someColour is a number
         put colour_RgbToHex (someColour) into someColour
      break
      case char 1 of someColour is not a number
         put colour_NameToRgb (someColour, pObject) into rgbColour
         if rgbColour is empty then
            put empty into someColour
         else
            put colour_RgbToHex (rgbColour) into someColour
         end if
      break
   end switch
end colour_HexNormalise

function colour_RgbToName rgbColour
   put revNumberToColor (rgbColour) into someColour
   if someColour is empty then 
      return rgbColour
   else
      return someColour
   end if
end colour_RgbToName

function colour_NameToRgb colourName, pObject
   put colourName into revColourName
   replace space with empty in revColourName
   -- put revColorToNumber (revColourName) into rgbColour -- no longer present in revLibrary / renamed
   
   if colour_IsRgb (colourName) is true then return colourName
   colour_ConvertEnglishName colourName
   put colour_TranslateName (colourName, pObject) into rgbColour
   return rgbColour
end colour_NameToRgb

function colour_TranslateName colourName, pOpenObject
   -- only works when the object is among the openstacks, not mainstacks or if used
   -- works even if object is not visible
   if pOpenObject is empty then
      -- put opn_MenuButton() into pOpenObject -- so lets use the opn_MenuButton
      put the long id of me into pOpenObject
   end if
   
   lock screen
   put the backcolor of pOpenObject into oColorName
   put the backpixel of pOpenObject into oBackPixel
   
   set the backcolor of pOpenObject to colourName
   get the effective backpixel of pOpenObject
   set the backcolor of pOpenObject to empty
   set the backpixel of pOpenObject to it
   put the backcolor of pOpenObject into tRGB
   
   -- set the backpixel of me to oBackPixel
   set the backcolor of pOpenObject to oColorName
   unlock screen
   return tRGB
end colour_TranslateName

function colour_IsRgb someColour
    if the number of items of someColour = 3 then
        repeat for each item someNumber in someColour
            if someNumber is not a number then
                return false
            else if someNumber > 256 or someNumber < 0 then
                return false
            end if
        end repeat
        return true
    else
        return false
    end if
end colour_IsRgb

command colour_ConvertEnglishName @colourName
    replace "grey" with "gray" in colourName
    switch colourName
        case "grey"
            put "gray" into colourName
            break
    end switch
end colour_ConvertEnglishName

on colour_InitialiseNameArray
    if "uOPN_ColourArray" is not among the lines of the custompropertysets of me then
        opn_Answer "Create colour lookup array?"
        colour_ConstructArray
    end if
    
    put the long id of me into modelObject
    return model_GetArrayKeys("uOPN_ColourArray", modelObject, "array")
end colour_InitialiseNameArray

command colour_ConstructArray pObject
    put the long id of me into modelObject
    
    put the colornames into colourNames
    put the backgroundcolor of modelObject into oColour
    repeat for each line colourName in colourNames
        -- set the backgroundcolor of me to colourName
        -- put the backgroundcolor of me into rgbColour
        put colour_TranslateName(colourName, pObject) into rgbColour
        set the uOPN_ColourArray [rgbColour] of modelObject to colourName
        set the uOPN_ColourArray [colourName] of modelObject to rgbColour
    end repeat
    set the backgroundcolor of modelObject to oColour
end colour_ConstructArray

function colour_Darken rgbColour, pDarkenPercent
   if rgbColour is empty then put "256,256,256" into rgbColour
   colour_RgbNormalise rgbColour
   if pDarkenPercent is empty then put 10 into pDarkenPercent
   put colour_RgbToHSV(rgbColour) into hsvColour
   put (100 - pDarkenPercent)/100 * item 3 of hsvColour into darkerV
   put min(darkerV, 100) into darkerV
   put max(darkerV, 0) into darkerV
   put darkerV into item 3 of hsvColour
   put colour_HsvToRgb(hsvColour) into newRgbColour
   
   -- return rgbColour
   return newRgbColour
end colour_Darken

function colour_RgbToHSV rgbColour
   -- was "rgb_2HSV"
   
   local maxv, minv, diff, s, rc, gc, bc, h
   -- display_ExecutionContexts "colour_RgbToHSV"
   
   put item 1 of rgbColour into r
   put item 2 of rgbColour into g
   put item 3 of rgbColour into b
   
   set the numberformat to "0.###############"
   put r / 255 into r
   put g / 255 into g
   put b / 255 into b
   put max(r,g,b) into maxv
   put min(r,g,b) into minv
   put maxv - minv into diff
   if maxv <> 0 and diff <> 0 then
      put diff / maxv into s
      put (maxv - r) / diff into rc
      put (maxv - g) / diff into gc
      put (maxv - b) / diff into bc
      if r = maxv then put bc - gc into h
      else if g = maxv then put 2 + rc - bc into h
      else if b = maxv then put 4 + gc - rc into h
      multiply h by 60
      if h < 0 then
         add 360 to h
      end if
   else
      put 0 into s
      put 0 into h
   end if
   return round(h),round(s * 100),round(maxv * 100)
end colour_RgbToHSV

function colour_HSVToRGB hsvColour
    -- was "hsv_2RGB"
    local rgb, i, f, p, q, t
    
    put item 1 of hsvColour into h
    put item 2 of hsvColour into s
    put item 3 of hsvColour into v
    
    set the numberformat to "0.###############"
    divide s by 100
    divide v by 100
    if s is 0 then put v,v,v into rgb
    else
        divide h by 60
        put trunc(h) into i
        put h - i into f
        put v * (1 - s) into p
        put v * (1 - s * f) into q
        put v * (1 - s * (1- f)) into t
        if i is 0 then put v,t,p into rgb
        if i is 1 then put q,v,p into rgb
        if i is 2 then put p,v,t into rgb
        if i is 3 then put p,q,v into rgb
        if i is 4 then put t,p,v into rgb
        if i is 5 then put v,p,q into rgb
    end if
    return round(item 1 of rgb * 255), round(item 2 of rgb * 255), round(item 3 of rgb * 255)
end colour_HSVToRGB

function colour_RgbToHex rgbColour
    -- was "colour_ConvertToWeb"
    
    put "#" into theWebColor -- leading "#"
    repeat for each item myItem in rgbColour -- numeric triplet -  R,G,B
        put format("%02X",myItem) after theWebColor
    end repeat
    return theWebColor
    
    -- alternative technique
    put "#" into theWebColor -- leading "#"
    repeat for each item myItem in rgbColour -- numeric triplet - R,G,B
        get baseconvert(myItem,10,16)
        if the length of it is 1 then put zero before it  -- each component must be 2-digit
        put it after theWebColor
    end repeat
    return theWebColor
end colour_RgbToHex

function colour_HexToRgb hexColour
   if char 1 of hexColour is not "#" then
      return empty
   else -- if the number of chars of hexColour = 7 then
      put baseconvert(char 2 to 3 of hexColour,16,10) into r
      put baseconvert(char 4 to 5 of hexColour,16,10) into g
      put baseconvert(char 6 to 7 of hexColour,16,10) into b
      return r,g,b
   else
      return empty
   end if
end colour_HexToRgb


--> Image
-
on image_PixelZoom source_Image, display_Image, maxPixelWidth, zoomPercentList
    put the short id of source_Image into source_ID 
    put the short id of display_Image into display_ID 
    put the number of source_Image into source_ControlNum 
     
    if zoomPercentList is empty then put "the kuler_ItemsPerPage of me,60,40,20,13,9,8,7,6,5,4,3,2,1,0.5,0.25" into zoomPercentList
    if maxPixelWidth is empty then put "6" into maxPixelWidth
     
    create invisible image "Temp"
    put it into temp_Image
     
    put the short id of temp_Image into temp_ID 
    put the number of temp_Image into temp_ControlNum 
     
    export image source_ControlNum to myVariable as PNG
    put myVariable into image id temp_ID
     
    put the formattedwidth of source_Image into oWidth
    put the formattedheight of source_Image into oHeight
     
    repeat for each item somePercent in zoomPercentList
        put round(somePercent/the kuler_ItemsPerPage of me * oWidth) into someWidth
        put round(somePercent/the kuler_ItemsPerPage of me * oHeight) into someHeight
         
        if someWidth < maxPixelWidth then exit repeat
         
        set the width of temp_Image to someWidth
        set the height of temp_Image to someHeight
         
        export image temp_ControlNum to myVariable as PNG
        put myVariable into image id display_ID
        wait 4 ticks
    end repeat
    delete temp_Image
end image_PixelZoom

on image_SetMaxDimensions @maxW, @maxH, imageObject
  put the formattedwidth of imageObject into originalWidth
  if originalWidth is 0 then
    put the width of imageObject into maxW
    put the height of imageObject into maxH
  else
    put the formattedheight of imageObject into originalHeight
    
    put maxW / originalWidth into x_ScaleFactor
    if maxH is empty then
      put round(x_ScaleFactor * originalHeight) into newHeight
      put round(x_ScaleFactor * originalWidth) into newWidth
    else
      put maxH / originalHeight into y_ScaleFactor
      -- choose the biggest
      if y_ScaleFactor > x_ScaleFactor then
        put y_ScaleFactor into sFactor
      else
        put x_ScaleFactor into sFactor
      end if
      
      put round(sFactor * originalHeight) into newHeight
      put round(sFactor * originalWidth) into newWidth
      
      if newHeight > maxH then
        put round(y_ScaleFactor * originalHeight) into newHeight
        put round(y_ScaleFactor * originalWidth) into newWidth
      else if newWidth > maxW then
        put round(x_ScaleFactor * originalHeight) into newHeight
        put round(x_ScaleFactor * originalWidth) into newWidth
      end if
    end if
    -- put maxW && maxH & return & newWidth && newHeight
    put newWidth into maxW
    put newHeight into maxH
  end if
end image_SetMaxDimensions


--> Image | Data | Pixel
-
function image_PixelToRGB binaryPixel
    -- was "binaryToRGBPixel"
    put chartonum(char 2 of binaryPixel) into redBit
    put chartonum(char 3 of binaryPixel) into greenBit
    put chartonum(char 4 of binaryPixel) into blueBit
    put redBit, greenBit, blueBit into rgbTriplet
    return rgbTriplet
end image_PixelToRGB

function image_RGBToPixel someColour
    put 0 into char 1 of binaryPixel
    put numtochar(item 1 of someColour) into char 2 of binaryPixel
    put numtochar(item 2 of someColour) into char 3 of binaryPixel
    put numtochar(item 3 of someColour) into char 4 of binaryPixel
    return binaryPixel
end image_RGBToPixel

function image_PixelColour pixelLoc, imageObject
  put image_PixelNum(pixelLoc, imageObject) into pixelNum
  return image_ColourFromPixelNum(pixelNum, imageObject)
end image_PixelColour

function image_ColourFromPixelNum pixelNum, imageObject
  put the imagedata of imageObject into someData
   
  put pixelNum - 1 into zeroedNum
  put chartonum(char ((4 *zeroedNum) + 2) of someData) into someRed
  put chartonum(char (4 * zeroedNum) + 3 of someData) into someGreen
  put chartonum(char (4 * zeroedNum) + 4 of someData) into someBlue
  return someRed,someGreen,someBlue
end image_ColourFromPixelNum

function image_PixelNum pixelLoc, imageObject
  put the width of imageObject into someWidth
  put the height of imageObject into someHeight 
  
  put item 1 of pixelLoc into lastPixels
  put item 2 of pixelLoc into lineNum
  put lastPixels + (someWidth * (lineNum - 1)) into pixelNum
  return pixelNum
end image_PixelNum

getprop image_PixelColour [someLoc]
    breakpoint
    put the image_PixelArray of the target into imagePixelArray
    return imagePixelArray [someLoc]
end image_PixelColour

getprop image_PixelTable
    put the long id of the target into imageObject
    if word 1 of imageObject is not "image" then return empty
    
    put the imagedata of imageObject into binaryData
    put the width of imageObject into maxX
    put the height of imageObject into maxY
    
    set the itemdelimiter to tab
    repeat with someY = 1 to maxY
        repeat with someX = 1 to maxX
            -- put (someY - 1) * maxX + someX into 
            put char 1 to 4 of binaryData into binaryPixel
            put image_PixelToRGB(binaryPixel) into rgbPixel
            put rgbPixel into item someX of line someY of imageTable
            delete char 1 to 4 of binaryData
        end repeat
    end repeat
    return imageTable
end image_PixelTable

setprop image_PixelTable pixelTable
    put the long id of the target into imageObject
    if word 1 of imageObject is not "image" then return empty
    
    put the width of imageObject into maxX
    put the height of imageObject into maxY
    
    set the itemdelimiter to tab
    put empty into binaryData
    repeat with someY = 1 to maxY
        repeat with someX = 1 to maxX
            put item someX of line someY of pixelTable into someColour
             
            put image_RGBToPixel(someColour) after binaryData
        end repeat
    end repeat
    
    set the imagedata of imageObject to binaryData
    return binaryData
end image_PixelTable

getprop image_PixelArray
    put the long id of the target into imageObject
    if word 1 of imageObject is not "image" then return empty
    
    return image_ConstructPixelArray(imageObject, 1, 1)
end image_PixelArray

function image_ConstructPixelArray imageObject, dimensionX, dimensionY
    -- was "makeImageBlockArray"
    put the imagedata of imageObject into binaryData
    put the width of imageObject into imagePixelWidth
    put the height of imageObject into imagePixelHeight
    repeat with pixelY = 1 to imagePixelHeight
        repeat with pixelX = 1 to imagePixelWidth
            -- set the cursor to busy
            put char 1 to 4 of binaryData into binaryPixel
            if binaryPixel is empty then
                answer rowNum
                return imageArray
            end if
            put image_PixelToRGB(binaryPixel) into rgbPixel
            -- put rgbPixel
            image_AddToPixelArray rgbPixel, pixelX, pixelY, dimensionX, dimensionY, imagePixelWidth, imagePixelHeight, imageArray
            delete char 1 to 4 of binaryData
        end repeat
    end repeat
    return imageArray
end image_ConstructPixelArray

private command image_AddToPixelArray rgbPixel, pixelX, pixelY, dimensionX, dimensionY, imagePixelWidth, imagePixelHeight, @imageArray
    put 1 + trunc(pixelX * dimensionX/imagePixelWidth) into blockX
    put 1 + trunc(pixelY * dimensionY/imagePixelHeight) into blockY
    put blockX && blockY into someKey
 
    put item 1 of rgbPixel into someRed
    put item 2 of rgbPixel into someGreen
    put item 3 of rgbPixel into someBlue
     
    put imageArray[someKey] into oldValues
    put someRed & "," after line 1 of oldValues
    put someGreen & "," after line 2 of oldValues
    put someBlue & "," after line 3 of oldValues
    put oldValues into imageArray[someKey]
end image_AddToPixelArray


--> Image | Data | Pixel | Average
-
function image_AverageBlockColour megaX, megaY, imageObject, dimensionX, dimensionY
  put image_ConstructPixelArray(imageObject, dimensionX, dimensionY) into someArray
  
  put megaX && megaY into someKey
  put someArray[someKey] into someMegaPixel
  put image_AveragePixel(someMegaPixel) into avColour
   
  return avColour
end image_AverageBlockColour

function image_AveragePixel firstMegaPixel
    get line 1 of firstMegaPixel
    delete last char of it
    put round(average(it)) into item 1 of blockPixel
     
    get line 2 of firstMegaPixel
    delete last char of it
    put round(average(it)) into item 2 of blockPixel
     
    get line 3 of firstMegaPixel
    delete last char of it
    put round(average(it)) into item 3 of blockPixel
    return blockPixel
end image_AveragePixel
