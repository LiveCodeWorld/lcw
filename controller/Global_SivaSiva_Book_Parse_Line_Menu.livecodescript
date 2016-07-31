script "Global_SivaSiva_Book_Parse_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_SivaSiva_Book_Parse_Line_Menu
type: controller
version: 0.1


--> Global | SivaSiva | Book | Parse | Line | Menu
-
on menu_TestLineArray mTarget
   put the selected_Value of mTarget into selectedArray
   put the displayed_Data of mTarget into bookArray
   put the title_Text of mTarget into bookTitle
   -- display_BookData selectedArray, bookTitle
   
   put word 1 to -1 of selectedArray ["descriptionXML"] into descriptionDiv
   
   put "Global | SivaSiva | Book | Parse | Menu" into menuTitle
   display_HTML descriptionDiv, "descriptionHTML", menuTitle
end menu_TestLineArray

function sivasiva_ParseDescriptionDiv
    put descriptionDiv into descriptionHTML
   delete line 1 of descriptionHTML
   delete line -1 of descriptionHTML
end sivasiva_ParseDescriptionDiv

command display_IndexedBookArray someArray, bookTitle
   local indexedArray, attributesArray
   
   book_ParseDivArray someArray, indexedArray, attributesArray
   put attributesArray ["class"] into divClass
   put attributesArray ["id"] into divID
   
   put divClass & comma & divID into bookTitle
   
   display_BookData indexedArray, bookTitle
end display_IndexedBookArray

command display_BookData indexedArray, bookTitle
   put "Global | SivaSiva | Book | Parse | Menu" into titleMenu
   put "Global | SivaSiva | Book | Parse | Line | Menu" into titleLineMenu
   display_Array indexedArray, bookTitle, titleMenu, titleLineMenu
   put the result into displayView
   set the tree_SortType of displayView to "numeric"
end display_BookData
