'Version: 0.2
'Author: Kippykip - http://kippykip.com
'License: Do whatever you want, I don't care.

'The main unicode type
Type TUniFont
	Field Font:TImage[255]	'Unicode Type ID image storage basically
	Field FontFilePrefix:String 'What file prefix before the two HEX letters? E.g. "unicode_page_"
	Field FontFolderPath:String 'Which folder is the group of files within? \ is already added at the end of the path
	Field FontFileType:String 'What filetype are the images? Default is ".png"
	Field FontWidth:Int 'How wide is each letter in the font?
	Field FontHeight:Int 'How high is each letter in the font?
	
	'This little bit here lets me only load unicode pages required, the more crazzzy diverse text you draw, the more fonts files it loads in the array overtime.
	'Basically returns a unicode font page as a TImage
	Function GetUniFont:TImage(TMP_Font:TUniFont, TMP_ID:Byte)
		'If the font image is already loaded
		If(TMP_Font.Font[TMP_ID])
			Return TMP_Font.Font[TMP_ID] 'Then just return the TImage that's already there
		Else 'Hasn't been loaded yet?????
			'Load it as an animated image with every section split into 16x16. 
			'A byte can store a max of 256 unique numbers. So that's also the max letters in each unicode PNG file.
			TMP_Font.Font[TMP_ID] = LoadAnimImage(TMP_Font.FontFolderPath + "\" + TMP_Font.FontFilePrefix + Mid(Hex(TMP_ID), 7, 2) + TMP_Font.FontFileType, TMP_Font.FontWidth, TMP_Font.FontHeight, 0, 256, 0)
			Return TMP_Font.Font[TMP_ID] 'Then return the TImage
		EndIf
	End Function
	
	'The main drawing functions

	'Draws text from a bank loaded from a unicode .TXT file
	Method DrawTextBank(TMP_TextBank:TBank, TMP_X:Float = 0, TMP_Y:Float = 0, TMP_XSpacing:Float = 1, TMP_YSpacing:Float = 1) 
		Local LineCount:Int = 0	'Multilines
		Local CharSkip:Int = 0 'Basically scrolls the X position backwards, it's used on multilines
		'This is what the 2 byte header equals in unicode text files. If it's not there then it's some other random file
		If Not(TMP_TextBank) Then RuntimeError("Bank doesn't exist!") 
		If(PeekShort(TMP_TextBank, 0) <> 65279) Then RuntimeError("Not a unicode .txt file!")
		
		'Loop through all the text. Since unicode text stores 2 bytes per letter, divide it by two. 
		'Also since there's a two byte header at the start, skip 2 bytes
		'And since we're counting from 0 we gotta take away 1 at the end of it all.
		'Wew, that's a lot of effort just to count the letters in a unicode file
		For Local TMP_Count:Int = 0 To (BankSize(TMP_TextBank) - 2) / 2 - 1
			Local TMP_Type:Byte = PeekByte(TMP_TextBank, 3 + (TMP_Count * 2)) 'Which unicode png does this particular letter need?
			Local TMP_Font:TImage = Self.GetUniFont(Self, TMP_Type:Byte) 'Store the font needed in a var so we can use it below
			Local TMP_Letter:Byte = PeekByte(TMP_TextBank, 2 + (TMP_Count * 2)) 'What letter/symbol is it in the index?
			
			'Newline, which is index 13 with Type 0 (ASCII=Type 0)
			If(TMP_Letter:Byte = 13 And TMP_Type:Byte = 0)
				LineCount = LineCount + 1 'Makes the text draw underneath the height of the font however many times
				TMP_Count = TMP_Count + 1 'For some reason, new lines are a full 4 bytes in unicode, since we've already done 2, lets skip the next 2.
				CharSkip = TMP_Count + 1 'This stops it from drawing the next line at the wrong X coordinate. quIK MAffs
			Else
				'In case the font file doesn't actually exist, draw nothing at all. Otherwise do some maths
				If (TMP_Font:TImage)
					DrawImage(TMP_Font:TImage, TMP_X:Int + (ImageWidth(TMP_Font:TImage) * TMP_XSpacing:Float * (TMP_Count - CharSkip)), TMP_Y:Int + (ImageHeight(TMP_Font:TImage) * TMP_YSpacing:Float * LineCount), TMP_Letter:Byte) 
				Else
					Print "Warning! - '" + Self.FontFolderPath:String + "\" + Self.FontFilePrefix:String + Mid(Hex(TMP_Type), 7, 2) + Self.FontFileType:String + "' is missing!"
				EndIf
			EndIf
		Next
	End Method
	
	'Draws plain unicode text from a quoted string.
	Method DrawText(Text:String, TMP_X:Float, TMP_Y:Float, TMP_XSpacing:Float = 1, TMP_YSpacing:Float = 1) 
		Local LineCount:Int = 0	'Multilines
		Local CharSkip:Int = 0 'Basically scrolls the X position backwards, it's used on multilines
		For Local TMP_Count:Int = 0 To Len(Text:String) - 1
			Local TMP_LetterIndex:Short = Asc(Mid:String(Text, TMP_Count + 1, 1)) 'Basically stores the two bytes as one short. We split it below for the Type var, and Letter var.
			Local TMP_Type:Byte = (TMP_LetterIndex:Short Shr 8) 'Which unicode png does this particular letter need?
			Local TMP_Font:TImage = Self.GetUniFont(Self, TMP_Type:Byte) 'Store the font needed in a var so we can use it below
			Local TMP_Letter:Byte = (TMP_LetterIndex:Short Shl 24 Shr 24) 'What letter/symbol is it in the index?

			'Newline, which is index 13 with Type 0 (ASCII=Type 0)
			If(TMP_Letter:Byte = 13 And TMP_Type:Byte = 0)
				LineCount = LineCount + 1 'Makes the text draw underneath the height of the font however many times
				CharSkip = TMP_Count + 1 'This stops it from drawing the next line at the wrong X coordinate. quIK MAffs
			Else
				If (TMP_Font:TImage)
					DrawImage(TMP_Font:TImage, TMP_X:Int + (ImageWidth(TMP_Font:TImage) * TMP_XSpacing:Float * (TMP_Count - CharSkip)), TMP_Y:Int + (ImageHeight(TMP_Font:TImage) * TMP_YSpacing:Float * LineCount), TMP_Letter:Byte) 
				Else
					Print "Warning! - '" + Self.FontFolderPath:String + "\" + Self.FontFilePrefix:String + Mid(Hex(TMP_Type), 7, 2) + Self.FontFileType:String + "' is missing!"
				EndIf
			EndIf
		Next
	End Method
End Type

'Function to load Unicode Fonts themselves.
'Example: 
'Global CoolFont:TUniFont = LoadUniFont("coolfont", "page_", 16, 32, ".png")
'Will load something like: "coolfont\page_00.png".
'"Incbin::" is also supported if you put it in the 'TMP_FolderPath' variable. 
Function LoadUniFont:TUniFont(TMP_FolderPath:String, TMP_FilePrefix:String, TMP_CellWidth:Int, TMP_CellHeight:Int, TMP_FileType:String = ".png")
	Local Font:TUniFont = New TUniFont
	Font.FontFolderPath = TMP_FolderPath
	Font.FontFilePrefix = TMP_FilePrefix
	Font.FontFileType = TMP_FileType
	Font.FontWidth = TMP_CellWidth
	Font.FontHeight = TMP_CellHeight
	Return Font
End Function