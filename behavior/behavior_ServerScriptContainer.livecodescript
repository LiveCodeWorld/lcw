script "behavior_ServerScriptContainer"
on index
   fedwiki_ParseDropUrl $_POST_RAW
end index
   
on fedwikiLink
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   fedwiki_ParseFedwikiLink droppedURL, $_POST_RAW
end fedwikiLink
   
on transportAgain
   /*
   {"title":"Joseph Stalin","create":{"type":"create","item":{"story":"","title":"Assassination"},"date":1459264331300,"source":{"url":"https://en.wikipedia.org/wiki/Leon_trotsky#Assassination","repo":"https://github.com/LiveCodeWorld/lib_MediaWiki","transport":"https://livecode.world/mediawiki/transportAgain","rev":712216007,"date":1459264331300,"link_dictionary":{"wiki_links":{"Legacy":{"section_number":31,"section_level":3,"dot_number":1}},"default":{"transport":"https://livecode.world/mediawiki/importSection"}}}}}
   */
   -- put script_GetCommentAboveMe() into someJSON
   put $_POST_RAW into someJSON
   
   /*
   -- put json_Lint (someJSON) into someJSON
   put fedwiki_ConstructErrorJSON (someJSON, "JSON") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
   */
   
   put json_ToArray (someJSON) into createArray
   put createArray ["title"] into sectionTitle
   put createArray ["create"]["source"] into sourceArray
   if sourceArray is not an array then
   put fedwiki_ConstructErrorJSON ("This is not create JSON", "Error") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
end if
   
   put sourceArray ["transport"] into againTransportURL
   put sourceArray ["url"] into wikipediaURL
   
   put createArray ["create"]["item"]["title"] into parentTitle
   -- if we are 2 or more generations down this is not the pageTitle
   put sourceArray ["pageSlug"] into pageSlug
   put sourceArray ["pageTitle"] into pageTitle
   
   put sourceArray ["link_Dictionary"] into linkDictionary
   put linkDictionary ["wiki_links"][sectionTitle]["section_number"] into sectionNum
   if sectionNum is not a number then
   /*
   put "Can't find section number for" && sectionTitle & CR & CR & sectionNum into errorJSON
   put fedwiki_ConstructErrorJSON (errorJSON, "Not a defined section link") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
   */
   
   put fedwiki_FetchWikipediaSummaryPageJson (sectionTitle) into pageJSON
   fedwiki_ReturnJSON pageJSON
   return false
end if
   
   put linkDictionary ["default"]["transport"] into linkDefaultTransport
   put linkDictionary ["wiki_links"][sectionTitle]["transport"] into linkSpecificTransport
   
   switch linkDefaultTransport
   case "https://livecode.world/mediawiki/importSection"
   /*
   put linkDictionary ["wiki_links"][sectionTitle] into errorArray
   put json_FromArray (errorArray) into dictJSON
   put "Found section number" && sectionNum && "for page" && kwote (pageSlug) & CR & CR & dictJSON into errorJSON
   
   put fedwiki_ConstructErrorJSON (errorJSON, "A defined section link") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
   */
   
   put fedwikipedia_FetchSectionSummaryPageJson (pageSlug, sectionNum) into pageJSON
   fedwiki_ReturnJSON pageJSON
   return true
   default
   put linkDictionary ["wiki_links"][sectionTitle] into errorArray
   put json_FromArray (errorArray) into dictJSON
   put "Not a defined section link for" && pageSlug && sectionNum & CR & CR & dictJSON into errorJSON
   put fedwiki_ConstructErrorJSON (errorJSON, "Not a defined section link") into errorJSON
   
   fedwiki_ReturnJSON errorJSON
   return false
end switch
end transportAgain
   
on listImages
   -- put mediwiki_ExtractImageFileFromUrl (droppedURL) into shortImageFile
   put fedwiki_GetWikipediaPageSlug ($_POST_RAW) into pageTitle
   put mediawiki_ListPageImages (pageTitle) into pageImages
   put pageTitle && "Images" into imagePageTitle
   
   put imagePageTitle into pageArray ["title"]
   put fedwiki_ConstructStoryItemArray (pageImages, "markdown") into itemArray
   fedwiki_PageArrayAddToEnd itemArray, pageArray
   put json_FromArray (pageArray) into pageJSON
   
   fedwiki_ReturnJSON pageJSON
end listImages
   
on importSummary
   put fedwiki_GetDroppedUrl ($_POST_RAW) into wikipediaUrl
   put mediwiki_ExtractPageSlugFromUrl (wikipediaUrl) into pageSlug
   put fedwiki_FetchWikipediaSummaryPageJson (pageSlug) into pageJSON
   fedwiki_ReturnJSON pageJSON
end importSummary
   
on importPage
   put fedwiki_GetDroppedUrl ($_POST_RAW) into wikipediaUrl
   put fedwiki_FetchCoolWikipediaPageJson (wikipediaUrl) into someJSON
   fedwiki_ReturnJSON someJSON
end importPage
   
on importSection
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$" into someReg
   if matchText (droppedURL, someReg, someLang, pageTitle, sectionNum) is true then
   set the itemdelimiter to "&"
   put item 1 of sectionNum into sectionNum
   
   put fedwikipedia_FetchSectionSummaryPageJson (pageTitle, sectionNum) into pageJSON
   fedwiki_ReturnJSON pageJSON
   else
   put fedwiki_ConstructErrorJSON ("Not a Wikipedia edit link!") into pageJSON
   fedwiki_ReturnJSON pageJSON
end if
end importSection
   
on importImage
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put mediwiki_ExtractImageFileFromUrl (droppedURL) into shortImageFile
   put fedwiki_FetchWikipediaImagePageJson (shortImageFile) into someJSON
   fedwiki_ReturnJSON someJSON
end importImage
   
on importImages
   put fedwiki_GetWikipediaPageSlug ($_POST_RAW) into pageTitle
   put fedwiki_FetchWikipediaImagesPageJson (pageTitle, 6) into pageJSON
   fedwiki_ReturnJSON pageJSON
end importImages
   
command fedwiki_ParseDropUrl dropJSON
   put json_ToArray (dropJSON) into dropArray
   put dropArray ["text"] into droppedText
   put dropArray ["html"] into droppedHtml
   
   set the itemdelimiter to "/"
   switch
   case item -1 of droppedText begins with "File:" -- only one needed
   fedwiki_ParseDroppedWikipediaImage droppedText
   break
   case droppedText is empty and droppedHtml contains "https://upload.wikimedia.org/wikipedia/commons/thumb/"  -- a thumbnail
   fedwiki_ParseWikipediaThumbNail droppedHtml
   break
   case droppedText is empty  -- a Fedwiki flag, or Twins, or a Neighbour
   fedwiki_ParseFlag droppedHtml
   break
   case matchText (droppedText, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, sectionTitle, sectionNum)
   -- section edit link
   set the itemdelimiter to "&"
   put item 1 of sectionNum into sectionNum
   fedwiki_ParseWikipediaEditLink sectionTitle, sectionNum, droppedText, someLang
   break
   case droppedHtml is empty -- an external url like Wikipedia
   fedwiki_ParseExternalUrl droppedText
   break
   case char -5 to -1 of droppedText = ".html" -- test to see if it is a fedwiki standalone link?
   fedwiki_ParseFedwikiLink droppedText, dropJSON
   break
   default
   put "Not a link that I can parse." & CR & CR & dropJSON into someInfo
   put fedwiki_ConstructErrorJSON (someInfo) into someJSON -- "maybe a standalone fedwiki link"
   fedwiki_ReturnJSON someJSON
end switch
end fedwiki_ParseDropUrl
   
command fedwiki_ParseDroppedWikipediaImage droppedURL
   put mediwiki_ExtractImageFileFromUrl (droppedURL) into shortImageFile
   put wikicommons_FetchImagePageJson (shortImageFile) into someJSON
   fedwiki_ReturnJSON someJSON
end fedwiki_ParseDroppedWikipediaImage
   
command fedwiki_ParseWikipediaThumbNail droppedHtml
   -- <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"><img alt="" src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/220px-Bruce_Sterling_at_ARE_2010.jpg" width="220" height="147" class="thumbimage" srcset="//upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/330px-Bruce_Sterling_at_ARE_2010.jpg 1.5x, //upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/440px-Bruce_Sterling_at_ARE_2010.jpg 2x" data-file-width="3888" data-file-height="2592">
   -- if droppedHtml is empty then put script_GetCommentAboveMe() into droppedHTML
   put fedwikipedia_ExtractShortImageFile (droppedHTML) into shortImageFile
   
   put wikicommons_FetchBasicTwoImagePageArray (shortImageFile) into pageArray
   put json_FromArray (pageArray) into pageJSON
   
   fedwiki_ReturnJSON pageJSON
end fedwiki_ParseWikipediaThumbNail
   
command fedwiki_ParseFlag droppedHtml
   put "This is Fedwiki flag, or Twins, or a Neighbour." into someText
   put CR & CR & droppedHtml after someText
   put fedwiki_ConstructErrorJSON (someText) into errorJSON
   fedwiki_ReturnJSON errorJSON
end fedwiki_ParseFlag
   
command fedwiki_ParseExternalUrl someUrl
   -- see also mediwiki_ExtractPageSlugFromUrl
   url_Deconstruct someUrl, someProtocol, urlDomain, urlPath, shortName, fileExtension, uName, pWord
   switch
   case urlDomain ends with ".wikipedia.org"
   set the itemdelimiter to "/"
   if item 1 of urlPath is not "wiki" then return empty
   
   -- put fedwikipedia_FetchPageJson (someUrl) into pageJSON
   put mediwiki_ExtractPageSlugFromUrl (someUrl) into pageSlug
   put fedwiki_FetchWikipediaSummaryPageJson (pageSlug) into pageJSON
   
   fedwiki_ReturnJSON pageJSON
   break
   default
   html_FetchScraped someURL, tidyXML, xmlArray, treeID
   put xmlArray ["html"]["head"]["title"] into htmlTitle
   revDeleteXMLTree treeID
   
   put "Here is a wiki link for this external url that you can drag onto you page:" into someText
   put "- [ ] [" & someURL && htmlTitle & "]" after someText
   
   put fedwiki_ConstructErrorJSON (someText) into errorJSON
   fedwiki_ReturnJSON errorJSON
end switch
end fedwiki_ParseExternalUrl
   
command fedwiki_ParseFedwikiLink droppedURL, dropJSON
   -- http://plugin.fedwiki.org/test-transport.html
   -- put fedwiki_FetchTitle (droppedURL) into pageTitle -- does not work for ghost pages
   put fedwiki_FetchSitemapArray (droppedURL) into someArray
   if someArray is an array then -- let's test it
   set the itemDelimiter to "/"
   put item -1 of droppedURL into pageSlug
   replace ".html" with empty in pageSlug
   
   -- put pageSlug into pageTitle
   -- replace "-" with space in pageTitle
   -- put text_InitialCaps (pageTitle) into pageTitle
   -- put fedwikipedia_FetchPageArray (pageTitle) into fedwikiPageArray
   
   put fedwiki_FetchWikipediaSummaryPageArray (pageSlug) into fedwikiPageArray
   if fedwikiPageArray is an array then
   put json_FromArray (fedwikiPageArray) into pageJSON
   else
   put "The Wikipidia page for" && pageSlug && "is not one that I can parse." & CR & CR & dropJSON into someInfo
   put fedwiki_ConstructErrorJSON (someInfo) into someJSON
end if
   fedwiki_ReturnJSON pageJSON
   else
   put "The web page for url" && droppedURL && "is not one that I can parse." & CR & CR & dropJSON into someInfo
   put fedwiki_ConstructErrorJSON (someInfo) into someJSON
   fedwiki_ReturnJSON someJSON
end if
end fedwiki_ParseFedwikiLink
   
command fedwiki_ParseWikipediaEditLink pageSlug, sectionNum, wikipediaUrl, someLang
   put fedwiki_FetchWikipediaSectionArray (pageSlug, sectionNum, wikipediaUrl) into fedwikiPageArray
   put json_FromArray (fedwikiPageArray) into pageJSON
   fedwiki_ReturnJSON pageJSON
end fedwiki_ParseWikipediaEditLink
