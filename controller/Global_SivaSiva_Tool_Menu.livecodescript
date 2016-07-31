script "Global_SivaSiva_Tool_Menu"
--> MetaData
-
license: GPLv3
name: Global_SivaSiva_Tool_Menu
type: controller
version: 0.1


--> Global | SivaSiva | Tool | Menu
-
on menu_SetChapter plusMinusView, cName
   dispatch "trait_SetChapter" to plusMinusView with cName
end menu_SetChapter

on menu_ChapterImage plusMinusView
   put the trait_Image of plusMinusView into imagePath
   -- display_Array chapterArray
   put imagePath
end menu_ChapterImage

on _
end _

on menu_ReplaceSquare plusMinusView, vName
   put the square_View of plusMinusView into squareView
   switch vName
      case "Trait"
         set the control_Type of squareView to "View|SivaSiva|Trait|PlusMinus"
         break
      case "Text"
         set the control_Type of squareView to "View|Text|Square"
         break
      case "Grid"
         set the control_Type of squareView to "View|Grid|Square"
         break
   end switch
end menu_ReplaceSquare

on menu_ReplaceWithViews plusMinusView
   lock screen
   set the control_Type of the positive_View of plusMinusView to "View|Text|Trait"
   set the control_Type of the negative_View of plusMinusView to "View|Text|Trait"
   -- set the control_Type of the square_View of plusMinusView to "View|Text|Square"
   set the control_Type of the square_View of plusMinusView to "View|SivaSiva|Trait|Arrows|Horizontal"
   unlock screen
end menu_ReplaceWithViews

on menu_ViewProperty someView, viewProp
   view_DoPropertyMenu viewProp, someView
end menu_ViewProperty

on menu_EditBehavior
   put the behavior of background "Trait Plus and Minus" of me into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_TestChapterNum
   put the chapter_Num of me
end menu_TestChapterNum


--> Menu | Props
-
getprop menu_Target
   put the plusMinus_View of me into plusMinusView
   return plusMinusView
end menu_Target


--> Global | Action | Menu | Props
-
getprop v_Names
   return "Trait,Text,Grid"
end v_Names

getprop view_Props [plusMinusView]
   put the view_PropertyMenu of plusMinusView into someMenu
   return someMenu
end view_Props

getprop c_Name [plusMinusView]
   put the chapter_Title of plusMinusView into chapterTitle
   return chapterTitle
end c_Name

getprop c_Names
   put sivasiva_FetchChapters() into chapterNames
   return chapterNames
end c_Names
