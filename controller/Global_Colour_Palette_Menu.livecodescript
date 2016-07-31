script "Global_Colour_Palette_Menu"
--> MetaData
-
license: GPLv3
name: Global_Colour_Palette_Menu
type: controller
version: 0.1


--> Global | Colour | Palette | Menu
-
on menu_DisplayMyColours
   colour_DisplayMyPalettes
end menu_DisplayMyColours

on menu_DisplayColourPalette swatchName
   put colour_GetSwatchArray (swatchName) into swatchArray
   display_Array swatchArray
end menu_DisplayColourPalette

on menu_NewColourPalette
   put opn_Ask("What do you want to call this swatch") into swatchName
   colour_SetSwatchArray swatchName, swatchArray
end menu_NewColourPalette

on menu_DeleteColourPalette swatchName
  colour_DeleteSwatch swatchName 
end menu_DeleteColourPalette


--> Global | Colour | Palette | Menu | Props
-
getprop swatch_Names
   return colour_SwatchNames()
end swatch_Names
