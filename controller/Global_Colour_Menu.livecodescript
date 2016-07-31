script "Global_Colour_Menu"
--> MetaData
-
license: GPLv3
name: Global_Colour_Menu
type: controller
version: 0.1


--> Global | Colour | Menu
-
on menu_DisplayColourNames menuChoice
    put the colour_Tree of me into treeView
    switch menuChoice
        case "Base colour outline"
            put colour_BaseColourOutline() into colourOutline
            break
        case "Base colour words"
            put colour_BaseNames() into colourOutline
            break
        case "Base colours"
            put the the colornames into colourNames
            repeat for each line colourName in colourNames
                if last char of colourName is a number then next repeat
                put colourName & CR after colourOutline
            end repeat
            delete last char of colourOutline
            sort colourOutline by the number of words of each
            break
        case "All"
            put the colornames into colourOutline
            break 
    end switch
    set the tree_Display [menuChoice] of treeView to colourOutline
end menu_DisplayColourNames

on _
end _

on menu_CreateColourDictionary
    colour_InitialiseNameArray
    put the result
end menu_CreateColourDictionary
