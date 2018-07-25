'Include the module
Import kippykip.imagefont
Graphics(1024, 480, 0, 60) 'Do 2D graphics

Global CoolFont:TUniFont = LoadUniFont("minecraftfont", "unicode_page_", 16, 16) 'Load the font into a variable.
CoolFont.DrawText("Holy Hecc i'm DRAWING!!! ワ オ!", 0, 0, 0.5, 1.0) 'Draw it!

'You can use usual image functions too. Lets have green text and double the size!
SetColor(0, 255, 0)
SetScale(2, 2)
CoolFont.DrawText("GREEN HA!", 0, 16)

'Return to normal
SetScale(1, 1)

'Here's an example of drawing a text file via a Bank, good for having multiple lines.
Global TxtBank:TBank = LoadBank("MinecraftWithGadget.txt")
SetColor(255, 0, 0) 'Lets have red text
CoolFont.DrawTextBank(TxtBank:TBank, 0, 64, 0.5, 1.0) 'Draw from a bank

'Flip and wait
Flip
WaitKey