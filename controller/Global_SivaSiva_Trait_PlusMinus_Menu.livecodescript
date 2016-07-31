script "Global_SivaSiva_Trait_PlusMinus_Menu"
--> MetaData
-
license: GPLv3
name: Global_SivaSiva_Trait_PlusMinus_Menu
type: controller
version: 0.1


--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | SivaSiva | Trait | PlusMinus | Menu
type: controller
version: 0.3

local LocalArray


--> Global | SivaSiva | Trait | PlusMinus | Menu | Props
-
getprop fit_ToStackWidth [plusMinusView]
   put the card_Margin of plusMinusView = 0 into someBoolean
   return someBoolean
end fit_ToStackWidth


--> Global | SivaSiva | Trait | PlusMinus | Menu
-
on submenu_Tools
   return "Global | View | Card | Tools | Menu"
end submenu_Tools

on submenu_Trait
   return "Global | Text | Square | Menu"
end submenu_Trait

on _
end _

on menu_SetStackRect plusMinusView
   put the stack_Object of plusMinusView into stackObject
   set the width of stackObject to 414
   set the height of stackObject to 736
   set the resizable of stackObject to false
end menu_SetStackRect

on menu_ResizeStack plusMinusView, someBoolean
   put the stack_Object of plusMinusView into stackObject
   set the resizable of stackObject to someBoolean
end menu_ResizeStack

on _
end _

on menu_DisplayChapter plusMinusView, chapterName
   put sivasiva_GetChapterNum (chapterName) into chapterNum
   set the chapter_Num of plusMinusView to chapterNum
   put the chapter_Array of plusMinusView into chapterArray
   
   set the displayed_SquareText of plusMinusView to the trait_Quote of plusMinusView
   set the displayed_PositiveLabel of plusMinusView to the positive_Label of plusMinusView
   set the displayed_NegativeLabel of plusMinusView to the negative_Label of plusMinusView
   
   put trait_GetSituation (chapterArray, situationNum) into traitSituation
   put trait_GetPositiveResponse (chapterArray, situationNum) into positiveResponse
   put trait_GetNegativeResponse (chapterArray, situationNum) into negativeResponse
   put trait_GetAssignment (chapterArray) into traitAssignment
   put trait_GetThoughtLabel (chapterArray) into thoughtLabel
   
end menu_DisplayChapter

on _
end _

on menu_SetPositiveLabel plusMinusView
   put the positive_Label of plusMinusView into someText
   put opn_Ask ("Edit the label...", someText) into someText
   set the positive_Label of plusMinusView to someText
end menu_SetPositiveLabel

on menu_SetNegativeLabel plusMinusView
   put the negative_Label of plusMinusView into someText
   put opn_Ask ("Edit the label...", someText) into someText
   set the negative_Label of plusMinusView to someText
end menu_SetNegativeLabel

on _
end _

on menu_FitToStackWidth plusMinusView, someBoolean
   lock screen
   --
   if someBoolean is true then
      set the card_Margin of plusMinusView to 0
      put the template_CardRect of plusMinusView into oRect
      set the margins of plusMinusView to 20
   else
      set the card_Margin of plusMinusView to 40
      put the template_CardRect of plusMinusView into oRect
      set the margins of plusMinusView to 20
   end if
   --
   set the rect of plusMinusView to oRect
   unlock screen
end menu_FitToStackWidth

on menu_ReplaceWithViews plusMinusView
   lock screen
   set the control_Type of the positive_View of plusMinusView to "View|Text|Trait"
   set the control_Type of the negative_View of plusMinusView to "View|Text|Trait"
   -- set the control_Type of the square_View of plusMinusView to "View|Text|Square"
   set the control_Type of the square_View of plusMinusView to "View|SivaSiva|Trait|Arrows|Horizontal"
   unlock screen
end menu_ReplaceWithViews

on menu_ReplaceWithPlaceholders plusMinusView
   lock screen
   set the control_Type of the positive_View of plusMinusView to "placeholder"
   set the control_Type of the negative_View of plusMinusView to "placeholder"
   set the control_Type of the square_View of plusMinusView to "placeholder"
   unlock screen
end menu_ReplaceWithPlaceholders

on _
end _

on menu_ReplacePositiveTrait plusMinusView
   set the control_Type of the positive_View of plusMinusView to "View|Text|Trait"
end menu_ReplacePositiveTrait

on menu_ReplaceNegativeTrait plusMinusView
   set the control_Type of the negative_View of plusMinusView to "View|Text|Trait"
end menu_ReplaceNegativeTrait

on menu_ReplaceSquareWithText plusMinusView
   set the control_Type of the square_View of plusMinusView to "View|Text|Square"
end menu_ReplaceSquareWithText

on menu_ReplaceSquareWithArrows plusMinusView
   set the control_Type of the square_View of plusMinusView to "View|SivaSiva|Trait|Arrows|Horizontal"
end menu_ReplaceSquareWithArrows

on _
end _

on submenu_Tools
   return "Global | View | Card | Tools | Menu"
end submenu_Tools

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | SivaSiva | Trait | PlusMinus | Menu | Props
-
getprop resize_Stack [plusMinusView]
   put the stack_Object of plusMinusView into stackObject
   put the resizable of stackObject into someBoolean
   return someBoolean
end resize_Stack

getprop chapter_Names
   put sivasiva_FetchChapters() into chapterNames
   return chapterNames
end chapter_Names


--> Dev | Menu
-
on menu_ParseAndSaveBook
   answer warning "Sure you want to parse and save the book array?" with "Cancel" or "OK"
   if it is "Cancel" then exit to top
   
   put sivasiva_GetXML() into xHtml
   put sivasiva_ParseXhtml (xHtml) into bookArray
   
   sivasiva_SaveBookArray bookArray
   
   put "Global | SivaSiva | Book | Parse | Menu" into titleMenu
   put "Global | SivaSiva | Book | Parse | Line | Menu" into titleLineMenu
   display_Array bookArray, "Character Traits Book Array", titleMenu, titleLineMenu
end menu_ParseAndSaveBook

on menu_DisplayChapterSeventeen plusMinusView
   -- there is a bug in chapter 17 import
   put sivasiva_GetChapterArray (17) into chapterArray
   display_Array chapterArray, "chapter 17"
   
   put sivasiva_GetChapterArray (16) into chapterArray
   display_Array chapterArray, "chapter 16"
   
   put sivasiva_GetChapterArray (18) into chapterArray
   display_Array chapterArray, "chapter 18"
end menu_DisplayChapterSeventeen

on _
end _

on menu_ResetPositiveTrait plusMinusView
   put the positive_View of plusMinusView into positiveView
   set the control_Type of positiveView to "placeholder"
   put the top_ControlNames of plusMinusView
end menu_ResetPositiveTrait

on menu_ResetNegativeTrait plusMinusView
   put the negative_View of plusMinusView into negativeView
   set the control_Type of negativeView to "placeholder"
   put the top_ControlNames of plusMinusView
end menu_ResetNegativeTrait

on menu_ResetInnerSquare plusMinusView
   put the square_View of plusMinusView into squareView
   set the control_Type of squareView to "placeholder"
   put the top_ControlNames of plusMinusView
end menu_ResetInnerSquare

on _
end _

on menu_DeletePositiveTrait plusMinusView
   put the positive_View of plusMinusView into positiveView
   delete positiveView
   put the top_ControlNames of plusMinusView
end menu_DeletePositiveTrait

on menu_DeleteNegativeTrait plusMinusView
   put the negative_View of plusMinusView into negativeView
   delete negativeView
   put the top_ControlNames of plusMinusView
end menu_DeleteNegativeTrait

on menu_DeleteInnerSquare plusMinusView
   put the square_View of plusMinusView into squareView
   delete squareView
   put the top_ControlNames of plusMinusView
end menu_DeleteInnerSquare

on menu_DeleteArrow plusMinusView
   put the arrow_View of plusMinusView into arrowView
   delete arrowView
   put the top_ControlNames of plusMinusView
end menu_DeleteArrow
