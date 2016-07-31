script "Global_SivaSiva_Book_Parse_Menu"
--> MetaData
-
license: GPLv3
name: Global_SivaSiva_Book_Parse_Menu
type: controller
version: 0.1


--> Global | SivaSiva | Book | Parse | Menu
-
on menu_Test displayView
   put the view_HtmlText of displayView into someHTML
   set the view_Utf8 of displayView to someHTML
end menu_Test

on menu_ParseDivArray mTarget
   put the displayed_Data of mTarget into someArray
   put the title_Text of mTarget into bookTitle
   display_IndexedBookArray someArray, bookTitle
end menu_ParseDivArray

on menu_DisplayArrayContentsAsText mTarget
   put the displayed_Data of mTarget into someArray
   put keys (someArray) into itemKeys
   sort numeric itemKeys
   
   repeat for each line indexNum in itemKeys
      put someArray [indexNum] into indexArray
      put indexArray ["@attributes"] into attributeArray
      delete variable indexArray ["@attributes"]
      
      switch
         case attributeArray ["class"] = "toc-text-test"
            put keys (indexArray) into spanKeys
            sort numeric spanKeys by token 3 of each
            put line 1 of spanKeys into spanKey
            put indexArray [spanKey} into tocLine
            put word 2 to -1 of tocLine into chapterTitle
            
            put chapterTitle & CR after orderedChapterTitleIndex
            put indexNum into chapterTitleArray [chapterTitle]
            break
         default
            -- breakpoint
      end switch
   end repeat
   delete char -1 of orderedChapterTitleIndex
   
   /*
   combine chapterTitleArray with comma and CR
   sort numeric lines of chapterTitleArray by item 1 of each
   set the columndelimiter to comma
   */
   
   -- project_SaveValue "chapterTitleArray", chapterTitleArray, "SivaSiva"
   -- project_SaveValue "orderedChapterTitleIndex", orderedChapterTitleIndex, "SivaSiva"
   
   put sivasiva_FetchChapters() into  orderedChapterTitleIndex
   
   opn_Notify (the number of lines of orderedChapterTitleIndex)
   put orderedChapterTitleIndex
   -- put keys (chapterTitleArray)
end menu_DisplayArrayContentsAsText 

on _
end _

on menu_EditBehavior mTarget
   put the behavior of the view_object of mTarget into bObject
   edit the script of bObject
end menu_EditBehavior
