; <COMPILER: v1.1.32.00>
#Persistent
#SingleInstance, force
SetTitleMatchMode 2
SendMode Input
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
if ((x != "") && (y != ""))
VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")
if (w = "") ||(h = "")
WinGetPos,,, w, h, ahk_id %hwnd%
return DllCall("UpdateLayeredWindow"
, Ptr, hwnd
, Ptr, 0
, Ptr, ((x = "") && (y = "")) ? 0 : &pt
, "int64*", w|h<<32
, Ptr, hdc
, "int64*", 0
, "uint", 0
, "UInt*", Alpha<<16|1<<24
, "uint", 2)
}
BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdi32\BitBlt"
, Ptr, dDC
, "int", dx
, "int", dy
, "int", dw
, "int", dh
, Ptr, sDC
, "int", sx
, "int", sy
, "uint", Raster ? Raster : 0x00CC0020)
}
StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdi32\StretchBlt"
, Ptr, ddc
, "int", dx
, "int", dy
, "int", dw
, "int", dh
, Ptr, sdc
, "int", sx
, "int", sy
, "int", sw
, "int", sh
, "uint", Raster ? Raster : 0x00CC0020)
}
SetStretchBltMode(hdc, iStretchMode=4)
{
return DllCall("gdi32\SetStretchBltMode"
, A_PtrSize ? "UPtr" : "UInt", hdc
, "int", iStretchMode)
}
SetImage(hwnd, hBitmap)
{
SendMessage, 0x172, 0x0, hBitmap,, ahk_id %hwnd%
E := ErrorLevel
DeleteObject(E)
return E
}
SetSysColorToControl(hwnd, SysColor=15)
{
WinGetPos,,, w, h, ahk_id %hwnd%
bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
SetImage(hwnd, hBitmap)
Gdip_DeleteBrush(pBrushClear)
Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
return 0
}
Gdip_BitmapFromScreen(Screen=0, Raster="")
{
if (Screen = 0)
{
Sysget, x, 76
Sysget, y, 77
Sysget, w, 78
Sysget, h, 79
}
else if (SubStr(Screen, 1, 5) = "hwnd:")
{
Screen := SubStr(Screen, 6)
if !WinExist( "ahk_id " Screen)
return -2
WinGetPos,,, w, h, ahk_id %Screen%
x := y := 0
hhdc := GetDCEx(Screen, 3)
}
else if (Screen&1 != "")
{
Sysget, M, Monitor, %Screen%
x := MLeft, y := MTop, w := MRight-MLeft, h := MBottom-MTop
}
else
{
StringSplit, S, Screen, |
x := S1, y := S2, w := S3, h := S4
}
if (x = "") || (y = "") || (w = "") || (h = "")
return -1
chdc := CreateCompatibleDC(), hbm := CreateDIBSection(w, h, chdc), obm := SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GetDC()
BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
ReleaseDC(hhdc)
pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
return pBitmap
}
Gdip_BitmapFromHWND(hwnd)
{
WinGetPos,,, Width, Height, ahk_id %hwnd%
hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
PrintWindow(hwnd, hdc)
pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
return pBitmap
}
CreateRectF(ByRef RectF, x, y, w, h)
{
VarSetCapacity(RectF, 16)
NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}
CreateRect(ByRef Rect, x, y, w, h)
{
VarSetCapacity(Rect, 16)
NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint"), NumPut(w, Rect, 8, "uint"), NumPut(h, Rect, 12, "uint")
}
CreateSizeF(ByRef SizeF, w, h)
{
VarSetCapacity(SizeF, 8)
NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float")
}
CreatePointF(ByRef PointF, x, y)
{
VarSetCapacity(PointF, 8)
NumPut(x, PointF, 0, "float"), NumPut(y, PointF, 4, "float")
}
CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
hdc2 := hdc ? hdc : GetDC()
VarSetCapacity(bi, 40, 0)
NumPut(w, bi, 4, "uint")
, NumPut(h, bi, 8, "uint")
, NumPut(40, bi, 0, "uint")
, NumPut(1, bi, 12, "ushort")
, NumPut(0, bi, 16, "uInt")
, NumPut(bpp, bi, 14, "ushort")
hbm := DllCall("CreateDIBSection"
, Ptr, hdc2
, Ptr, &bi
, "uint", 0
, A_PtrSize ? "UPtr*" : "uint*", ppvBits
, Ptr, 0
, "uint", 0, Ptr)
if !hdc
ReleaseDC(hdc2)
return hbm
}
PrintWindow(hwnd, hdc, Flags=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("PrintWindow", Ptr, hwnd, Ptr, hdc, "uint", Flags)
}
DestroyIcon(hIcon)
{
return DllCall("DestroyIcon", A_PtrSize ? "UPtr" : "UInt", hIcon)
}
PaintDesktop(hdc)
{
return DllCall("PaintDesktop", A_PtrSize ? "UPtr" : "UInt", hdc)
}
CreateCompatibleBitmap(hdc, w, h)
{
return DllCall("gdi32\CreateCompatibleBitmap", A_PtrSize ? "UPtr" : "UInt", hdc, "int", w, "int", h)
}
CreateCompatibleDC(hdc=0)
{
return DllCall("CreateCompatibleDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}
SelectObject(hdc, hgdiobj)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
}
DeleteObject(hObject)
{
return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}
GetDC(hwnd=0)
{
return DllCall("GetDC", A_PtrSize ? "UPtr" : "UInt", hwnd)
}
GetDCEx(hwnd, flags=0, hrgnClip=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("GetDCEx", Ptr, hwnd, Ptr, hrgnClip, "int", flags)
}
ReleaseDC(hdc, hwnd=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}
DeleteDC(hdc)
{
return DllCall("DeleteDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}
Gdip_LibraryVersion()
{
return 1.45
}
Gdip_LibrarySubVersion()
{
return 1.47
}
Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
{
Static FName = "ObjRelease"
if !BRAFromMemIn
return -1
Loop, Parse, BRAFromMemIn, `n
{
if (A_Index = 1)
{
StringSplit, Header, A_LoopField, |
if (Header0 != 4 || Header2 != "BRA!")
return -2
}
else if (A_Index = 2)
{
StringSplit, Info, A_LoopField, |
if (Info0 != 3)
return -3
}
else
break
}
if !Alternate
StringReplace, File, File, \, \\, All
RegExMatch(BRAFromMemIn, "mi`n)^" (Alternate ? File "\|.+?\|(\d+)\|(\d+)" : "\d+\|" File "\|(\d+)\|(\d+)") "$", FileInfo)
if !FileInfo
return -4
hData := DllCall("GlobalAlloc", "uint", 2, Ptr, FileInfo2, Ptr)
pData := DllCall("GlobalLock", Ptr, hData, Ptr)
DllCall("RtlMoveMemory", Ptr, pData, Ptr, &BRAFromMemIn+Info2+FileInfo1, Ptr, FileInfo2)
DllCall("GlobalUnlock", Ptr, hData)
DllCall("ole32\CreateStreamOnHGlobal", Ptr, hData, "int", 1, A_PtrSize ? "UPtr*" : "UInt*", pStream)
DllCall("gdiplus\GdipCreateBitmapFromStream", Ptr, pStream, A_PtrSize ? "UPtr*" : "UInt*", pBitmap)
If (A_PtrSize)
%FName%(pStream)
Else
DllCall(NumGet(NumGet(1*pStream)+8), "uint", pStream)
return pBitmap
}
Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}
Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
Gdip_ResetClip(pGraphics)
Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
Gdip_ResetClip(pGraphics)
return E
}
Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}
Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipDrawBezier"
, Ptr, pgraphics
, Ptr, pPen
, "float", x1
, "float", y1
, "float", x2
, "float", y2
, "float", x3
, "float", y3
, "float", x4
, "float", y4)
}
Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipDrawArc"
, Ptr, pGraphics
, Ptr, pPen
, "float", x
, "float", y
, "float", w
, "float", h
, "float", StartAngle
, "float", SweepAngle)
}
Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipDrawPie", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}
Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipDrawLine"
, Ptr, pGraphics
, Ptr, pPen
, "float", x1
, "float", y1
, "float", x2
, "float", y2)
}
Gdip_DrawLines(pGraphics, pPen, Points)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
StringSplit, Points, Points, |
VarSetCapacity(PointF, 8*Points0)
Loop, %Points0%
{
StringSplit, Coord, Points%A_Index%, `,
NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
}
return DllCall("gdiplus\GdipDrawLines", Ptr, pGraphics, Ptr, pPen, Ptr, &PointF, "int", Points0)
}
Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipFillRectangle"
, Ptr, pGraphics
, Ptr, pBrush
, "float", x
, "float", y
, "float", w
, "float", h)
}
Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
Region := Gdip_GetClipRegion(pGraphics)
Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
Gdip_SetClipRegion(pGraphics, Region, 0)
Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
Gdip_SetClipRegion(pGraphics, Region, 0)
Gdip_DeleteRegion(Region)
return E
}
Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
StringSplit, Points, Points, |
VarSetCapacity(PointF, 8*Points0)
Loop, %Points0%
{
StringSplit, Coord, Points%A_Index%, `,
NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
}
return DllCall("gdiplus\GdipFillPolygon", Ptr, pGraphics, Ptr, pBrush, Ptr, &PointF, "int", Points0, "int", FillMode)
}
Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipFillPie"
, Ptr, pGraphics
, Ptr, pBrush
, "float", x
, "float", y
, "float", w
, "float", h
, "float", StartAngle
, "float", SweepAngle)
}
Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
}
Gdip_FillRegion(pGraphics, pBrush, Region)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipFillRegion", Ptr, pGraphics, Ptr, pBrush, Ptr, Region)
}
Gdip_FillPath(pGraphics, pBrush, Path)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipFillPath", Ptr, pGraphics, Ptr, pBrush, Ptr, Path)
}
Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
StringSplit, Points, Points, |
VarSetCapacity(PointF, 8*Points0)
Loop, %Points0%
{
StringSplit, Coord, Points%A_Index%, `,
NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
}
if (Matrix&1 = "")
ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
else if (Matrix != 1)
ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
if (sx = "" && sy = "" && sw = "" && sh = "")
{
sx := 0, sy := 0
sw := Gdip_GetImageWidth(pBitmap)
sh := Gdip_GetImageHeight(pBitmap)
}
E := DllCall("gdiplus\GdipDrawImagePointsRect"
, Ptr, pGraphics
, Ptr, pBitmap
, Ptr, &PointF
, "int", Points0
, "float", sx
, "float", sy
, "float", sw
, "float", sh
, "int", 2
, Ptr, ImageAttr
, Ptr, 0
, Ptr, 0)
if ImageAttr
Gdip_DisposeImageAttributes(ImageAttr)
return E
}
Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
if (Matrix&1 = "")
ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
else if (Matrix != 1)
ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
if (sx = "" && sy = "" && sw = "" && sh = "")
{
if (dx = "" && dy = "" && dw = "" && dh = "")
{
sx := dx := 0, sy := dy := 0
sw := dw := Gdip_GetImageWidth(pBitmap)
sh := dh := Gdip_GetImageHeight(pBitmap)
}
else
{
sx := sy := 0
sw := Gdip_GetImageWidth(pBitmap)
sh := Gdip_GetImageHeight(pBitmap)
}
}
E := DllCall("gdiplus\GdipDrawImageRectRect"
, Ptr, pGraphics
, Ptr, pBitmap
, "float", dx
, "float", dy
, "float", dw
, "float", dh
, "float", sx
, "float", sy
, "float", sw
, "float", sh
, "int", 2
, Ptr, ImageAttr
, Ptr, 0
, Ptr, 0)
if ImageAttr
Gdip_DisposeImageAttributes(ImageAttr)
return E
}
Gdip_SetImageAttributesColorMatrix(Matrix)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
VarSetCapacity(ColourMatrix, 100, 0)
Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", "", 1), "[^\d-\.]+", "|")
StringSplit, Matrix, Matrix, |
Loop, 25
{
Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
}
DllCall("gdiplus\GdipCreateImageAttributes", A_PtrSize ? "UPtr*" : "uint*", ImageAttr)
DllCall("gdiplus\GdipSetImageAttributesColorMatrix", Ptr, ImageAttr, "int", 1, "int", 1, Ptr, &ColourMatrix, Ptr, 0, "int", 0)
return ImageAttr
}
Gdip_GraphicsFromImage(pBitmap)
{
DllCall("gdiplus\GdipGetImageGraphicsContext", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
return pGraphics
}
Gdip_GraphicsFromHDC(hdc)
{
DllCall("gdiplus\GdipCreateFromHDC", A_PtrSize ? "UPtr" : "UInt", hdc, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
return pGraphics
}
Gdip_GetDC(pGraphics)
{
DllCall("gdiplus\GdipGetDC", A_PtrSize ? "UPtr" : "UInt", pGraphics, A_PtrSize ? "UPtr*" : "UInt*", hdc)
return hdc
}
Gdip_ReleaseDC(pGraphics, hdc)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipReleaseDC", Ptr, pGraphics, Ptr, hdc)
}
Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
{
return DllCall("gdiplus\GdipGraphicsClear", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", ARGB)
}
Gdip_BlurBitmap(pBitmap, Blur)
{
if (Blur > 100) || (Blur < 1)
return -1
sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
dWidth := sWidth//Blur, dHeight := sHeight//Blur
pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
G1 := Gdip_GraphicsFromImage(pBitmap1)
Gdip_SetInterpolationMode(G1, 7)
Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)
Gdip_DeleteGraphics(G1)
pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
G2 := Gdip_GraphicsFromImage(pBitmap2)
Gdip_SetInterpolationMode(G2, 7)
Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)
Gdip_DeleteGraphics(G2)
Gdip_DisposeImage(pBitmap1)
return pBitmap2
}
Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
SplitPath, sOutput,,, Extension
if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
return -1
Extension := "." Extension
DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
VarSetCapacity(ci, nSize)
DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
if !(nCount && nSize)
return -2
If (A_IsUnicode){
StrGet_Name := "StrGet"
Loop, %nCount%
{
sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
if !InStr(sString, "*" Extension)
continue
pCodec := &ci+idx
break
}
} else {
Loop, %nCount%
{
Location := NumGet(ci, 76*(A_Index-1)+44)
nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
VarSetCapacity(sString, nSize)
DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
if !InStr(sString, "*" Extension)
continue
pCodec := &ci+76*(A_Index-1)
break
}
}
if !pCodec
return -3
if (Quality != 75)
{
Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
if Extension in .JPG,.JPEG,.JPE,.JFIF
{
DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
VarSetCapacity(EncoderParameters, nSize, 0)
DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
Loop, % NumGet(EncoderParameters, "UInt")
{
elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
{
p := elem+&EncoderParameters-pad-4
NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
break
}
}
}
}
if (!A_IsUnicode)
{
nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, 0, "int", 0)
VarSetCapacity(wOutput, nSize*2)
DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, &wOutput, "int", nSize)
VarSetCapacity(wOutput, -1)
if !VarSetCapacity(wOutput)
return -4
E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &wOutput, Ptr, pCodec, "uint", p ? p : 0)
}
else
E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", p ? p : 0)
return E ? -5 : 0
}
Gdip_GetPixel(pBitmap, x, y)
{
DllCall("gdiplus\GdipBitmapGetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "uint*", ARGB)
return ARGB
}
Gdip_SetPixel(pBitmap, x, y, ARGB)
{
return DllCall("gdiplus\GdipBitmapSetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "int", ARGB)
}
Gdip_GetImageWidth(pBitmap)
{
DllCall("gdiplus\GdipGetImageWidth", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Width)
return Width
}
Gdip_GetImageHeight(pBitmap)
{
DllCall("gdiplus\GdipGetImageHeight", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Height)
return Height
}
Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
DllCall("gdiplus\GdipGetImageWidth", Ptr, pBitmap, "uint*", Width)
DllCall("gdiplus\GdipGetImageHeight", Ptr, pBitmap, "uint*", Height)
}
Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
{
Gdip_GetImageDimensions(pBitmap, Width, Height)
}
Gdip_GetImagePixelFormat(pBitmap)
{
DllCall("gdiplus\GdipGetImagePixelFormat", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", Format)
return Format
}
Gdip_GetDpiX(pGraphics)
{
DllCall("gdiplus\GdipGetDpiX", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpix)
return Round(dpix)
}
Gdip_GetDpiY(pGraphics)
{
DllCall("gdiplus\GdipGetDpiY", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpiy)
return Round(dpiy)
}
Gdip_GetImageHorizontalResolution(pBitmap)
{
DllCall("gdiplus\GdipGetImageHorizontalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpix)
return Round(dpix)
}
Gdip_GetImageVerticalResolution(pBitmap)
{
DllCall("gdiplus\GdipGetImageVerticalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpiy)
return Round(dpiy)
}
Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
{
return DllCall("gdiplus\GdipBitmapSetResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float", dpix, "float", dpiy)
}
Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
, PtrA := A_PtrSize ? "UPtr*" : "UInt*"
SplitPath, sFile,,, ext
if ext in exe,dll
{
Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
BufSize := 16 + (2*(A_PtrSize ? A_PtrSize : 4))
VarSetCapacity(buf, BufSize, 0)
Loop, Parse, Sizes, |
{
DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", A_LoopField, "int", A_LoopField, PtrA, hIcon, PtrA, 0, "uint", 1, "uint", 0)
if !hIcon
continue
if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, &buf)
{
DestroyIcon(hIcon)
continue
}
hbmMask  := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
hbmColor := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, &buf))
{
DestroyIcon(hIcon)
continue
}
break
}
if !hIcon
return -1
Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3)
{
DestroyIcon(hIcon)
return -2
}
VarSetCapacity(dib, 104)
DllCall("GetObject", Ptr, hbm, "int", A_PtrSize = 8 ? 104 : 84, Ptr, &dib)
Stride := NumGet(dib, 12, "Int"), Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0))
DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, Ptr, Bits, PtrA, pBitmapOld)
pBitmap := Gdip_CreateBitmap(Width, Height)
G := Gdip_GraphicsFromImage(pBitmap)
, Gdip_DrawImage(G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapOld)
DestroyIcon(hIcon)
}
else
{
if (!A_IsUnicode)
{
VarSetCapacity(wFile, 1024)
DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sFile, "int", -1, Ptr, &wFile, "int", 512)
DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &wFile, PtrA, pBitmap)
}
else
DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &sFile, PtrA, pBitmap)
}
return pBitmap
}
Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, Palette, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
return pBitmap
}
Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
{
DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hbm, "int", Background)
return hbm
}
Gdip_CreateBitmapFromHICON(hIcon)
{
DllCall("gdiplus\GdipCreateBitmapFromHICON", A_PtrSize ? "UPtr" : "UInt", hIcon, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
return pBitmap
}
Gdip_CreateHICONFromBitmap(pBitmap)
{
DllCall("gdiplus\GdipCreateHICONFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hIcon)
return hIcon
}
Gdip_CreateBitmap(Width, Height, Format=0x26200A)
{
DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, A_PtrSize ? "UPtr" : "UInt", 0, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
Return pBitmap
}
Gdip_CreateBitmapFromClipboard()
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
if !DllCall("OpenClipboard", Ptr, 0)
return -1
if !DllCall("IsClipboardFormatAvailable", "uint", 8)
return -2
if !hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
return -3
if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
return -4
if !DllCall("CloseClipboard")
return -5
DeleteObject(hBitmap)
return pBitmap
}
Gdip_SetBitmapToClipboard(pBitmap)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
hdib := DllCall("GlobalAlloc", "uint", 2, Ptr, 40+NumGet(oi, off1, "UInt"), Ptr)
pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)
DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr, NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), Ptr), Ptr, NumGet(oi, off1, "UInt"))
DllCall("GlobalUnlock", Ptr, hdib)
DllCall("DeleteObject", Ptr, hBitmap)
DllCall("OpenClipboard", Ptr, 0)
DllCall("EmptyClipboard")
DllCall("SetClipboardData", "uint", 8, Ptr, hdib)
DllCall("CloseClipboard")
}
Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
{
DllCall("gdiplus\GdipCloneBitmapArea"
, "float", x
, "float", y
, "float", w
, "float", h
, "int", Format
, A_PtrSize ? "UPtr" : "UInt", pBitmap
, A_PtrSize ? "UPtr*" : "UInt*", pBitmapDest)
return pBitmapDest
}
Gdip_CreatePen(ARGB, w)
{
DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
return pPen
}
Gdip_CreatePenFromBrush(pBrush, w)
{
DllCall("gdiplus\GdipCreatePen2", A_PtrSize ? "UPtr" : "UInt", pBrush, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
return pPen
}
Gdip_BrushCreateSolid(ARGB=0xff000000)
{
DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
return pBrush
}
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
{
DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
return pBrush
}
Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
, PtrA := A_PtrSize ? "UPtr*" : "UInt*"
if !(w && h)
DllCall("gdiplus\GdipCreateTexture", Ptr, pBitmap, "int", WrapMode, PtrA, pBrush)
else
DllCall("gdiplus\GdipCreateTexture2", Ptr, pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, PtrA, pBrush)
return pBrush
}
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
CreatePointF(PointF1, x1, y1), CreatePointF(PointF2, x2, y2)
DllCall("gdiplus\GdipCreateLineBrush", Ptr, &PointF1, Ptr, &PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
return LGpBrush
}
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
{
CreateRectF(RectF, x, y, w, h)
DllCall("gdiplus\GdipCreateLineBrushFromRect", A_PtrSize ? "UPtr" : "UInt", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
return LGpBrush
}
Gdip_CloneBrush(pBrush)
{
DllCall("gdiplus\GdipCloneBrush", A_PtrSize ? "UPtr" : "UInt", pBrush, A_PtrSize ? "UPtr*" : "UInt*", pBrushClone)
return pBrushClone
}
Gdip_DeletePen(pPen)
{
return DllCall("gdiplus\GdipDeletePen", A_PtrSize ? "UPtr" : "UInt", pPen)
}
Gdip_DeleteBrush(pBrush)
{
return DllCall("gdiplus\GdipDeleteBrush", A_PtrSize ? "UPtr" : "UInt", pBrush)
}
Gdip_DisposeImage(pBitmap)
{
return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
}
Gdip_DeleteGraphics(pGraphics)
{
return DllCall("gdiplus\GdipDeleteGraphics", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}
Gdip_DisposeImageAttributes(ImageAttr)
{
return DllCall("gdiplus\GdipDisposeImageAttributes", A_PtrSize ? "UPtr" : "UInt", ImageAttr)
}
Gdip_DeleteFont(hFont)
{
return DllCall("gdiplus\GdipDeleteFont", A_PtrSize ? "UPtr" : "UInt", hFont)
}
Gdip_DeleteStringFormat(hFormat)
{
return DllCall("gdiplus\GdipDeleteStringFormat", A_PtrSize ? "UPtr" : "UInt", hFormat)
}
Gdip_DeleteFontFamily(hFamily)
{
return DllCall("gdiplus\GdipDeleteFontFamily", A_PtrSize ? "UPtr" : "UInt", hFamily)
}
Gdip_DeleteMatrix(Matrix)
{
return DllCall("gdiplus\GdipDeleteMatrix", A_PtrSize ? "UPtr" : "UInt", Matrix)
}
Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
{
IWidth := Width, IHeight:= Height
RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
RegExMatch(Options, "i)NoWrap", NoWrap)
RegExMatch(Options, "i)R(\d)", Rendering)
RegExMatch(Options, "i)S(\d+)(p*)", Size)
if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
PassBrush := 1, pBrush := Colour2
if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
return -1
Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
Loop, Parse, Styles, |
{
if RegExMatch(Options, "\b" A_loopField)
Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
}
Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
Loop, Parse, Alignments, |
{
if RegExMatch(Options, "\b" A_loopField)
Align |= A_Index//2.1
}
xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
if !PassBrush
Colour := "0x" (Colour2 ? Colour2 : "ff000000")
Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12
hFamily := Gdip_FontFamilyCreate(Font)
hFont := Gdip_FontCreate(hFamily, Size, Style)
FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
hFormat := Gdip_StringFormatCreate(FormatStyle)
pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
if !(hFamily && hFont && hFormat && pBrush && pGraphics)
return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
CreateRectF(RC, xpos, ypos, Width, Height)
Gdip_SetStringFormatAlign(hFormat, Align)
Gdip_SetTextRenderingHint(pGraphics, Rendering)
ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
if vPos
{
StringSplit, ReturnRC, ReturnRC, |
if (vPos = "vCentre") || (vPos = "vCenter")
ypos += (Height-ReturnRC4)//2
else if (vPos = "Top") || (vPos = "Up")
ypos := 0
else if (vPos = "Bottom") || (vPos = "Down")
ypos := Height-ReturnRC4
CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
}
if !Measure
E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)
if !PassBrush
Gdip_DeleteBrush(pBrush)
Gdip_DeleteStringFormat(hFormat)
Gdip_DeleteFont(hFont)
Gdip_DeleteFontFamily(hFamily)
return E ? E : ReturnRC
}
Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
if (!A_IsUnicode)
{
nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, 0, "int", 0)
VarSetCapacity(wString, nSize*2)
DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
}
return DllCall("gdiplus\GdipDrawString"
, Ptr, pGraphics
, Ptr, A_IsUnicode ? &sString : &wString
, "int", -1
, Ptr, hFont
, Ptr, &RectF
, Ptr, hFormat
, Ptr, pBrush)
}
Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
VarSetCapacity(RC, 16)
if !A_IsUnicode
{
nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, "uint", 0, "int", 0)
VarSetCapacity(wString, nSize*2)
DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
}
DllCall("gdiplus\GdipMeasureString"
, Ptr, pGraphics
, Ptr, A_IsUnicode ? &sString : &wString
, "int", -1
, Ptr, hFont
, Ptr, &RectF
, Ptr, hFormat
, Ptr, &RC
, "uint*", Chars
, "uint*", Lines)
return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}
Gdip_SetStringFormatAlign(hFormat, Align)
{
return DllCall("gdiplus\GdipSetStringFormatAlign", A_PtrSize ? "UPtr" : "UInt", hFormat, "int", Align)
}
Gdip_StringFormatCreate(Format=0, Lang=0)
{
DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, A_PtrSize ? "UPtr*" : "UInt*", hFormat)
return hFormat
}
Gdip_FontCreate(hFamily, Size, Style=0)
{
DllCall("gdiplus\GdipCreateFont", A_PtrSize ? "UPtr" : "UInt", hFamily, "float", Size, "int", Style, "int", 0, A_PtrSize ? "UPtr*" : "UInt*", hFont)
return hFont
}
Gdip_FontFamilyCreate(Font)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
if (!A_IsUnicode)
{
nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, "uint", 0, "int", 0)
VarSetCapacity(wFont, nSize*2)
DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, Ptr, &wFont, "int", nSize)
}
DllCall("gdiplus\GdipCreateFontFamilyFromName"
, Ptr, A_IsUnicode ? &Font : &wFont
, "uint", 0
, A_PtrSize ? "UPtr*" : "UInt*", hFamily)
return hFamily
}
Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
{
DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, A_PtrSize ? "UPtr*" : "UInt*", Matrix)
return Matrix
}
Gdip_CreateMatrix()
{
DllCall("gdiplus\GdipCreateMatrix", A_PtrSize ? "UPtr*" : "UInt*", Matrix)
return Matrix
}
Gdip_CreatePath(BrushMode=0)
{
DllCall("gdiplus\GdipCreatePath", "int", BrushMode, A_PtrSize ? "UPtr*" : "UInt*", Path)
return Path
}
Gdip_AddPathEllipse(Path, x, y, w, h)
{
return DllCall("gdiplus\GdipAddPathEllipse", A_PtrSize ? "UPtr" : "UInt", Path, "float", x, "float", y, "float", w, "float", h)
}
Gdip_AddPathPolygon(Path, Points)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
StringSplit, Points, Points, |
VarSetCapacity(PointF, 8*Points0)
Loop, %Points0%
{
StringSplit, Coord, Points%A_Index%, `,
NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
}
return DllCall("gdiplus\GdipAddPathPolygon", Ptr, Path, Ptr, &PointF, "int", Points0)
}
Gdip_DeletePath(Path)
{
return DllCall("gdiplus\GdipDeletePath", A_PtrSize ? "UPtr" : "UInt", Path)
}
Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
return DllCall("gdiplus\GdipSetTextRenderingHint", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", RenderingHint)
}
Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
{
return DllCall("gdiplus\GdipSetInterpolationMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", InterpolationMode)
}
Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
return DllCall("gdiplus\GdipSetSmoothingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", SmoothingMode)
}
Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
{
return DllCall("gdiplus\GdipSetCompositingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", CompositingMode)
}
Gdip_Startup()
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
DllCall("LoadLibrary", "str", "gdiplus")
VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
return pToken
}
Gdip_Shutdown(pToken)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
DllCall("FreeLibrary", Ptr, hModule)
return 0
}
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
{
return DllCall("gdiplus\GdipRotateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", Angle, "int", MatrixOrder)
}
Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
return DllCall("gdiplus\GdipScaleWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}
Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
return DllCall("gdiplus\GdipTranslateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}
Gdip_ResetWorldTransform(pGraphics)
{
return DllCall("gdiplus\GdipResetWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}
Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
{
pi := 3.14159, TAngle := Angle*(pi/180)
Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
if ((Bound >= 0) && (Bound <= 90))
xTranslation := Height*Sin(TAngle), yTranslation := 0
else if ((Bound > 90) && (Bound <= 180))
xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
else if ((Bound > 180) && (Bound <= 270))
xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
else if ((Bound > 270) && (Bound <= 360))
xTranslation := 0, yTranslation := -Width*Sin(TAngle)
}
Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
pi := 3.14159, TAngle := Angle*(pi/180)
if !(Width && Height)
return -1
RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}
Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
{
return DllCall("gdiplus\GdipImageRotateFlip", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", RotateFlipType)
}
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
{
return DllCall("gdiplus\GdipSetClipRect",  A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}
Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipSetClipPath", Ptr, pGraphics, Ptr, Path, "int", CombineMode)
}
Gdip_ResetClip(pGraphics)
{
return DllCall("gdiplus\GdipResetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}
Gdip_GetClipRegion(pGraphics)
{
Region := Gdip_CreateRegion()
DllCall("gdiplus\GdipGetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics, "UInt*", Region)
return Region
}
Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("gdiplus\GdipSetClipRegion", Ptr, pGraphics, Ptr, Region, "int", CombineMode)
}
Gdip_CreateRegion()
{
DllCall("gdiplus\GdipCreateRegion", "UInt*", Region)
return Region
}
Gdip_DeleteRegion(Region)
{
return DllCall("gdiplus\GdipDeleteRegion", A_PtrSize ? "UPtr" : "UInt", Region)
}
Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
CreateRect(Rect, x, y, w, h)
VarSetCapacity(BitmapData, 16+2*(A_PtrSize ? A_PtrSize : 4), 0)
E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, &Rect, "uint", LockMode, "int", PixelFormat, Ptr, &BitmapData)
Stride := NumGet(BitmapData, 8, "Int")
Scan0 := NumGet(BitmapData, 16, Ptr)
return E
}
Gdip_UnlockBits(pBitmap, ByRef BitmapData)
{
Ptr := A_PtrSize ? "UPtr" : "UInt"
return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, &BitmapData)
}
Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
{
Numput(ARGB, Scan0+0, (x*4)+(y*Stride), "UInt")
}
Gdip_GetLockBitPixel(Scan0, x, y, Stride)
{
return NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")
}
Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
{
static PixelateBitmap
Ptr := A_PtrSize ? "UPtr" : "UInt"
if (!PixelateBitmap)
{
if A_PtrSize != 8
MCode_PixelateBitmap =
		(LTrim Join
		558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
		397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
		8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
		4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
		C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
		8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
		148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
		B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
		F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
		038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
		1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
		FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
		D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
		45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
		89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
		0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
		75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
		8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
		B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
		451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
		75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
		8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
)
else
MCode_PixelateBitmap =
		(LTrim Join
		4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
		448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
		4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
		C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
		24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
		004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
		0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
		DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
		024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
		99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
		8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
		4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
		000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
		ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
		4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
		99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
		8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
		2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
		FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
		83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
		F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
		0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
		413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
)
VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
Loop % StrLen(MCode_PixelateBitmap)//2
NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "UChar")
DllCall("VirtualProtect", Ptr, &PixelateBitmap, Ptr, VarSetCapacity(PixelateBitmap), "uint", 0x40, A_PtrSize ? "UPtr*" : "UInt*", 0)
}
Gdip_GetImageDimensions(pBitmap, Width, Height)
if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
return -1
if (BlockSize > Width || BlockSize > Height)
return -2
E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
if (E1 || E2)
return -3
E := DllCall(&PixelateBitmap, Ptr, Scan01, Ptr, Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)
Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapOut, BitmapData2)
return 0
}
Gdip_ToARGB(A, R, G, B)
{
return (A << 24) | (R << 16) | (G << 8) | B
}
Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
{
A := (0xff000000 & ARGB) >> 24
R := (0x00ff0000 & ARGB) >> 16
G := (0x0000ff00 & ARGB) >> 8
B := 0x000000ff & ARGB
}
Gdip_AFromARGB(ARGB)
{
return (0xff000000 & ARGB) >> 24
}
Gdip_RFromARGB(ARGB)
{
return (0x00ff0000 & ARGB) >> 16
}
Gdip_GFromARGB(ARGB)
{
return (0x0000ff00 & ARGB) >> 8
}
Gdip_BFromARGB(ARGB)
{
return 0x000000ff & ARGB
}
StrGetB(Address, Length=-1, Encoding=0)
{
if Length is not integer
Encoding := Length,  Length := -1
if (Address+0 < 1024)
return
if Encoding = UTF-16
Encoding = 1200
else if Encoding = UTF-8
Encoding = 65001
else if SubStr(Encoding,1,2)="CP"
Encoding := SubStr(Encoding,3)
if !Encoding
{
if (Length == -1)
Length := DllCall("lstrlen", "uint", Address)
VarSetCapacity(String, Length)
DllCall("lstrcpyn", "str", String, "uint", Address, "int", Length + 1)
}
else if Encoding = 1200
{
char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "uint", 0, "uint", 0, "uint", 0, "uint", 0)
VarSetCapacity(String, char_count)
DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "str", String, "int", char_count, "uint", 0, "uint", 0)
}
else if Encoding is integer
{
char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", 0, "int", 0)
VarSetCapacity(String, char_count * 2)
char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", &String, "int", char_count * 2)
String := StrGetB(&String, char_count, 1200)
}
return String
}
class JSON
{
class Load extends JSON.Functor
{
Call(self, ByRef text, reviver:="")
{
this.rev := IsObject(reviver) ? reviver : false
this.keys := this.rev ? {} : false
static quot := Chr(34), bashq := "\" . quot
, json_value := quot . "{[01234567890-tfn"
, json_value_or_array_closing := quot . "{[]01234567890-tfn"
, object_key_or_object_closing := quot . "}"
key := ""
is_key := false
root := {}
stack := [root]
next := json_value
pos := 0
while ((ch := SubStr(text, ++pos, 1)) != "") {
if InStr(" `t`r`n", ch)
continue
if !InStr(next, ch, 1)
this.ParseError(next, text, pos)
holder := stack[1]
is_array := holder.IsArray
if InStr(",:", ch) {
next := (is_key := !is_array && ch == ",") ? quot : json_value
} else if InStr("}]", ch) {
ObjRemoveAt(stack, 1)
next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"
} else {
if InStr("{[", ch) {
static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
(ch == "{")
? ( is_key := true
, value := {}
, next := object_key_or_object_closing )
: ( value := json_array ? new json_array : []
, next := json_value_or_array_closing )
ObjInsertAt(stack, 1, value)
if (this.keys)
this.keys[value] := []
} else {
if (ch == quot) {
i := pos
while (i := InStr(text, quot,, i+1)) {
value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")
static tail := A_AhkVersion<"2" ? 0 : -1
if (SubStr(value, tail) != "\")
break
}
if (!i)
this.ParseError("'", text, pos)
value := StrReplace(value,  "\/",  "/")
, value := StrReplace(value, bashq, quot)
, value := StrReplace(value,  "\b", "`b")
, value := StrReplace(value,  "\f", "`f")
, value := StrReplace(value,  "\n", "`n")
, value := StrReplace(value,  "\r", "`r")
, value := StrReplace(value,  "\t", "`t")
pos := i
i := 0
while (i := InStr(value, "\",, i+1)) {
if !(SubStr(value, i+1, 1) == "u")
this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))
uffff := Abs("0x" . SubStr(value, i+2, 4))
if (A_IsUnicode || uffff < 0x100)
value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
}
if (is_key) {
key := value, next := ":"
continue
}
} else {
value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)
static number := "number", integer :="integer"
if value is %number%
{
if value is %integer%
value += 0
}
else if (value == "true" || value == "false")
value := %value% + 0
else if (value == "null")
value := ""
else
this.ParseError(next, text, pos, i)
pos += i-1
}
next := holder==root ? "" : is_array ? ",]" : ",}"
}
is_array? key := ObjPush(holder, value) : holder[key] := value
if (this.keys && this.keys.HasKey(holder))
this.keys[holder].Push(key)
}
}
return this.rev ? this.Walk(root, "") : root[""]
}
ParseError(expect, ByRef text, pos, len:=1)
{
static quot := Chr(34), qurly := quot . "}"
line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
,     (expect == "")     ? "Extra data"
: (expect == "'")    ? "Unterminated string starting at"
: (expect == "\")    ? "Invalid \escape"
: (expect == ":")    ? "Expecting ':' delimiter"
: (expect == quot)   ? "Expecting object key enclosed in double quotes"
: (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
: (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
: (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
: InStr(expect, "]") ? "Expecting JSON value or array closing ']'"
:                      "Expecting JSON value(string, number, true, false, null, object or array)"
, line, col, pos)
static offset := A_AhkVersion<"2" ? -3 : -4
throw Exception(msg, offset, SubStr(text, pos, len))
}
Walk(holder, key)
{
value := holder[key]
if IsObject(value) {
for i, k in this.keys[value] {
v := this.Walk(value, k)
if (v != JSON.Undefined)
value[k] := v
else
ObjDelete(value, k)
}
}
return this.rev.Call(holder, key, value)
}
}
class Dump extends JSON.Functor
{
Call(self, value, replacer:="", space:="")
{
this.rep := IsObject(replacer) ? replacer : ""
this.gap := ""
if (space) {
static integer := "integer"
if space is %integer%
Loop, % ((n := Abs(space))>10 ? 10 : n)
this.gap .= " "
else
this.gap := SubStr(space, 1, 10)
this.indent := "`n"
}
return this.Str({"": value}, "")
}
Str(holder, key)
{
value := holder[key]
if (this.rep)
value := this.rep.Call(holder, key, ObjHasKey(holder, key) ? value : JSON.Undefined)
if IsObject(value) {
static type := A_AhkVersion<"2" ? "" : Func("Type")
if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
if (this.gap) {
stepback := this.indent
this.indent .= this.gap
}
is_array := value.IsArray
if (!is_array) {
for i in value
is_array := i == A_Index
until !is_array
}
str := ""
if (is_array) {
Loop, % value.Length() {
if (this.gap)
str .= this.indent
v := this.Str(value, A_Index)
str .= (v != "") ? v . "," : "null,"
}
} else {
colon := this.gap ? ": " : ":"
for k in value {
v := this.Str(value, k)
if (v != "") {
if (this.gap)
str .= this.indent
str .= this.Quote(k) . colon . v . ","
}
}
}
if (str != "") {
str := RTrim(str, ",")
if (this.gap)
str .= stepback
}
if (this.gap)
this.indent := stepback
return is_array ? "[" . str . "]" : "{" . str . "}"
}
} else
return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
}
Quote(string)
{
static quot := Chr(34), bashq := "\" . quot
if (string != "") {
string := StrReplace(string,  "\",  "\\")
, string := StrReplace(string, quot, bashq)
, string := StrReplace(string, "`b",  "\b")
, string := StrReplace(string, "`f",  "\f")
, string := StrReplace(string, "`n",  "\n")
, string := StrReplace(string, "`r",  "\r")
, string := StrReplace(string, "`t",  "\t")
static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
while RegExMatch(string, rx_escapable, m)
string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
}
return quot . string . quot
}
}
Undefined[]
{
get {
static empty := {}, vt_empty := ComObject(0, &empty, 1)
return vt_empty
}
}
class Functor
{
__Call(method, ByRef arg, args*)
{
if IsObject(method)
return (new this).Call(method, arg, args*)
else if (method == "")
return (new this).Call(arg, args*)
}
}
}
ImageIdentify(image:="", search:="", options:=""){
return Vis2.ImageIdentify(image, search, options)
}
OCR(image:="", language:="", options:=""){
return Vis2.OCR(image, language, options)
}
class Vis2 {
class ImageIdentify extends Vis2.functor {
call(self, image:="", search:="", options:=""){
return (image != "") ? (new Vis2.provider.GoogleCloudVision()).ImageIdentify(image, search, options)
: Vis2.core.returnText({"provider":(new Vis2.provider.GoogleCloudVision(search)), "tooltip":"Image Identification Tool", "splashImage":true})
}
}
class OCR extends Vis2.functor {
call(self, image:="", language:="", options:=""){
return (image != "") ? (new Vis2.provider.Tesseract()).OCR(image, language, options)
: Vis2.core.returnText({"provider":(new Vis2.provider.Tesseract(language)), "tooltip":"Optical Character Recognition Tool", "textPreview":true})
}
google(){
return (image != "") ? (new Vis2.provider.Tesseract()).OCR(image, language, options).google()
: Vis2.core.returnText({"provider":(new Vis2.provider.Tesseract(language)), "tooltip":"Any selected text will be Googled.", "textPreview":true, "noCopy":true}).google()
}
}
class core {
returnText(obj := ""){
obj := IsObject(obj) ? obj : {}
obj.callback := "returnText"
if (Vis2.core.ux.start(obj) == "") {
while !(EXITCODE := Vis2.obj.EXITCODE)
Sleep 1
text := Vis2.obj.database
Vis2.obj.callbackConfirmed := true
text.base.google := ObjBindMethod(Vis2.Text, "google")
text.base.clipboard := ObjBindMethod(Vis2.Text, "clipboard")
return (EXITCODE > 0) ? text : ""
}
}
class ux {
start(obj := ""){
static void := ObjBindMethod({}, {})
if (Vis2.obj != "")
return "Already in use."
Vis2.Graphics.Startup()
Vis2.stdlib.setSystemCursor(32515)
Hotkey, LButton, % void, On
Hotkey, ^LButton, % void, On
Hotkey, !LButton, % void, On
Hotkey, +LButton, % void, On
Hotkey, RButton, % void, On
Hotkey, Escape, % void, On
Vis2.obj := IsObject(obj) ? obj : {}
Vis2.obj.EXITCODE := 0
Vis2.obj.selectMode := "Quick"
Vis2.obj.area := new Vis2.Graphics.Area("Vis2_Aries", "0x7FDDDDDD")
Vis2.obj.image := new Vis2.Graphics.Image("Vis2_Kitsune").Hide()
Vis2.obj.subtitle := new Vis2.Graphics.Subtitle("Vis2_Hermes")
Vis2.obj.style1_back := {"x":"center", "y":"83%", "padding":"1.35%", "color":"DD000000", "radius":8}
Vis2.obj.style1_text := {"q":4, "size":"2.23%", "font":"Arial", "z":"Arial Narrow", "justify":"left", "color":"White"}
Vis2.obj.style2_back := {"x":"center", "y":"83%", "padding":"1.35%", "color":"FF88EAB6", "radius":8}
Vis2.obj.style2_text := {"q":4, "size":"2.23%", "font":"Arial", "z":"Arial Narrow", "justify":"left", "color":"Black"}
Vis2.obj.subtitle.render(Vis2.obj.tooltip, Vis2.obj.style1_back, Vis2.obj.style1_text)
return Vis2.core.ux.waitForUserInput()
}
waitForUserInput(){
static escape := ObjBindMethod(Vis2.core.ux, "escape")
static waitForUserInput := ObjBindMethod(Vis2.core.ux, "waitForUserInput")
static selectImage := ObjBindMethod(Vis2.core.ux.process, "selectImage")
static textPreview := ObjBindMethod(Vis2.core.ux.process, "textPreview")
if (GetKeyState("Escape", "P")) {
Vis2.obj.EXITCODE := -1
SetTimer, % escape, -9
return
}
else if (GetKeyState("LButton", "P")) {
SetTimer, % selectImage, -10
if (Vis2.obj.textPreview)
SetTimer, % textPreview, -25
else
Vis2.obj.subtitle.render("Waiting for user selection...", Vis2.obj.style2_back, Vis2.obj.style2_text)
}
else {
Vis2.obj.area.origin()
SetTimer, % waitForUserInput, -10
}
return
}
class process {
selectImage(){
static selectImage := ObjBindMethod(Vis2.core.ux.process, "selectImage")
if (GetKeyState("Escape", "P")) {
Vis2.obj.EXITCODE := -1
return Vis2.core.ux.process.finale(A_ThisFunc)
}
if (Vis2.obj.selectMode == "Quick")
Vis2.core.ux.process.selectImageQuick()
if (Vis2.obj.selectMode == "Advanced")
Vis2.core.ux.process.selectImageAdvanced()
if (Vis2.core.ux.overlap()) {
if (Vis2.obj.textPreview && Vis2.obj.dialogue != Vis2.obj.dialogue_past) {
Vis2.obj.dialogue_past := Vis2.obj.dialogue
Vis2.obj.style1_back.y := (Vis2.obj.style1_back.y == "83%") ? "2.07%" : "83%"
Vis2.obj.subtitle.render(Vis2.obj.dialogue, Vis2.obj.style1_back, Vis2.obj.style1_text)
}
else if !(Vis2.obj.textPreview) {
Vis2.obj.style2_back.y := (Vis2.obj.style2_back.y == "83%") ? "2.07%" : "83%"
Vis2.obj.subtitle.render("Still patiently waiting for user selection...", Vis2.obj.style2_back, Vis2.obj.style2_text)
}
}
if !(Vis2.obj.unlock.1 ~= "^Vis2.core.ux.process.selectImage" || Vis2.obj.unlock.2 ~= "^Vis2.core.ux.process.selectImage")
SetTimer, % selectImage, -10
return
}
selectImageQuick(){
if (GetKeyState("LButton", "P")) {
if (GetKeyState("Control", "P") || GetKeyState("Alt", "P") || GetKeyState("Shift", "P"))
Vis2.core.ux.process.selectImageTransition()
else if (GetKeyState("RButton", "P")) {
Vis2.obj.area.move()
if (!Vis2.obj.area.isMouseOnCorner() && Vis2.obj.area.isMouseStopped())
Vis2.obj.area.draw()
}
else
Vis2.obj.area.draw()
}
else
Vis2.core.ux.process.finale(A_ThisFunc)
}
selectImageTransition(){
static void := ObjBindMethod({}, {})
DllCall("SystemParametersInfo", "uInt",0x57, "uInt",0, "uInt",0, "uInt",0)
Hotkey, Space, % void, On
Hotkey, ^Space, % void, On
Hotkey, !Space, % void, On
Hotkey, +Space, % void, On
Vis2.obj.note_01 := Vis2.Graphics.Subtitle.Render("Advanced Mode", "time: 2500, xCenter y75% p1.35% cFFB1AC r8", "c000000 s2.23%")
Vis2.obj.tokenMousePressed := 1
Vis2.obj.selectMode := "Advanced"
Vis2.obj.key := {}
Vis2.obj.action := {}
}
selectImageAdvanced(){
static void := ObjBindMethod({}, {})
if ((Vis2.obj.area.width() < -25 || Vis2.obj.area.height() < -25) && !Vis2.obj.note_02)
Vis2.obj.note_02 := Vis2.Graphics.Subtitle.Render("Press Alt + LButton to create a new selection anywhere on screen", "time: 6250, x: center, y: 67%, p1.35%, c: FCF9AF, r8", "c000000 s2.23%")
Vis2.obj.key.LButton := GetKeyState("LButton", "P") ? 1 : 0
Vis2.obj.key.RButton := GetKeyState("RButton", "P") ? 1 : 0
Vis2.obj.key.Space   := GetKeyState("Space", "P")   ? 1 : 0
Vis2.obj.key.Control := GetKeyState("Control", "P") ? 1 : 0
Vis2.obj.key.Alt     := GetKeyState("Alt", "P")     ? 1 : 0
Vis2.obj.key.Shift   := GetKeyState("Shift", "P")   ? 1 : 0
Vis2.obj.action.Control_LButton := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.Control && Vis2.obj.key.LButton)
? 1 : (Vis2.obj.key.Control && Vis2.obj.key.LButton) ? Vis2.obj.action.Control_LButton : 0
Vis2.obj.action.Shift_LButton   := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.Shift && Vis2.obj.key.LButton)
? 1 : (Vis2.obj.key.Shift && Vis2.obj.key.LButton) ? Vis2.obj.action.Shift_LButton : 0
Vis2.obj.action.LButton         := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.LButton)
? 1 : (Vis2.obj.key.LButton) ? Vis2.obj.action.LButton : 0
Vis2.obj.action.RButton         := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.RButton)
? 1 : (Vis2.obj.key.RButton) ? Vis2.obj.action.RButton : 0
Vis2.obj.action.Control_Space   := (Vis2.obj.key.Control && Vis2.obj.key.Space)
? ((!Vis2.obj.action.Control_Space) ? 1 : -1) : 0
Vis2.obj.action.Alt_Space       := (Vis2.obj.key.Alt && Vis2.obj.key.Space)
? ((!Vis2.obj.action.Alt_Space) ? 1 : -1) : 0
Vis2.obj.action.Shift_Space     := (Vis2.obj.key.Shift && Vis2.obj.key.Space)
? ((!Vis2.obj.action.Shift_Space) ? 1 : -1) : 0
Vis2.obj.action.Alt_LButton     := (Vis2.obj.key.Alt && Vis2.obj.key.LButton)
? ((!Vis2.obj.action.Alt_LButton) ? 1 : -1) : 0
Vis2.obj.action.Space := (Vis2.obj.key.Space && !Vis2.obj.key.Control && !Vis2.obj.key.Alt && !Vis2.obj.key.Shift)
? ((!Vis2.obj.action.Space) ? 1 : -1) : 0
if (Vis2.obj.action.Control_Space = 1){
Vis2.obj.image.render(Vis2.obj.provider.getPreprocessImage(), 0.5)
Vis2.obj.image.toggleVisible()
} else if (Vis2.obj.action.Alt_Space = 1){
Vis2.obj.area.toggleCoordinates()
} else if (Vis2.obj.action.Shift_Space = 1){
} else if (Vis2.obj.action.Space = 1)
Vis2.core.ux.process.finale(A_ThisFunc)
if (Vis2.obj.action.Control_LButton)
Vis2.obj.area.resizeCorners()
else if (Vis2.obj.action.Alt_LButton = 1)
Vis2.obj.area.origin()
else if (Vis2.obj.action.Alt_LButton = -1)
Vis2.obj.area.draw()
else if (Vis2.obj.action.Shift_LButton)
Vis2.obj.area.resizeEdges()
else if (Vis2.obj.action.LButton || Vis2.obj.action.RButton)
Vis2.obj.area.move()
else {
Vis2.obj.area.hover()
if Vis2.obj.area.isMouseInside() {
Hotkey, LButton, % void, On
Hotkey, RButton, % void, On
} else {
Hotkey, LButton, % void, Off
Hotkey, RButton, % void, Off
}
}
}
textPreview(bypass:=""){
static textPreview := ObjBindMethod(Vis2.core.ux.process, "textPreview")
if (!Vis2.obj.unlock.1 || bypass) {
if (coordinates := Vis2.obj.Area.ScreenshotRectangle()) {
(overlap := Vis2.core.ux.overlap()) ? Vis2.obj.subtitle.hide() : ""
pBitmap := Gdip_BitmapFromScreen(coordinates)
(overlap) ? Vis2.obj.subtitle.show() : ""
if !(coordinates == Vis2.obj.coordinates && Vis2.stdlib.Gdip_isBitmapEqual(pBitmap, Vis2.obj.pBitmap)) {
Gdip_DisposeImage(Vis2.obj.pBitmap)
Vis2.obj.coordinates := coordinates
Vis2.obj.pBitmap := pBitmap
try {
if (Vis2.obj.provider.file != "")
Gdip_SaveBitmapToFile(pBitmap, Vis2.obj.provider.file, Vis2.obj.provider.jpegQuality)
if (Vis2.obj.provider.base64 != "")
Vis2.obj.provider.base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, Vis2.obj.provider.ext, Vis2.obj.provider.jpegQuality)
Vis2.obj.provider.preprocess()
if (Vis2.obj.image.isVisible() == true)
Vis2.obj.image.render(Vis2.obj.provider.getPreprocessImage(), 0.5)
Vis2.obj.provider.convert()
Vis2.obj.database := Vis2.obj.provider.getText()
}
catch e {
}
dialogue := ""
i := 1
Loop, Parse, % Vis2.obj.database, `r`n
{
data := RegExReplace(A_LoopField, "^\s*(.*?)\s*$", "$1")
if (data != "") {
dialogue .= (dialogue) ? ("`n" . data) : data
i++
}
} until (i > 3)
if (dialogue != "") {
Vis2.obj.firstDialogue := true
Vis2.obj.dialogue := dialogue
}
else
Vis2.obj.dialogue := (Vis2.obj.firstDialogue == true) ? "ERROR: No Text Data Found" : "Searching for text..."
if !(bypass)
Vis2.obj.Subtitle.Render(Vis2.obj.dialogue, Vis2.obj.style1_back, Vis2.obj.style1_text)
}
else {
Gdip_DisposeImage(pBitmap)
}
}
}
if (Vis2.obj.unlock.1)
return Vis2.core.ux.process.finale(A_ThisFunc)
else
SetTimer, % textPreview, -100
return
}
finale(key){
static escape := ObjBindMethod(Vis2.core.ux, "escape")
(IsObject(Vis2.obj.unlock) && key != Vis2.obj.unlock.1) ? Vis2.obj.unlock.push(key) : (Vis2.obj.unlock := [key])
if (key ~= "^Vis2.core.ux.process.selectImage") {
Vis2.obj.Area.ChangeColor(0x01FFFFFF)
if (!Vis2.obj.textPreview)
Vis2.core.ux.process.textPreview("bypass")
}
if (Vis2.obj.unlock.MaxIndex() == 2) {
if (Vis2.obj.area.screenshotRectangle() != Vis2.obj.coordinates)
Vis2.core.ux.process.textPreview("bypass")
if (Vis2.obj.database != "" && Vis2.obj.EXITCODE == 0) {
if (Vis2.obj.noCopy != true) {
clipboard := Vis2.obj.database
t := 2500
if (Vis2.obj.splashImage == true) {
t := 5000
w := Gdip_GetImageWidth(Vis2.obj.pBitmap)
h := Gdip_GetImageHeight(Vis2.obj.pBitmap)
Vis2.Graphics.Subtitle.Render("", {"time":t, "x":((A_ScreenWidth-w)/2)-10, "y":((A_ScreenHeight-h)/2)-10, "w":w+20, "h":h+20, "color":"Black"})
Vis2.Graphics.Image.Render(Vis2.obj.pBitmap, 1, t).Border()
}
Vis2.obj.Subtitle.Hide()
Vis2.Graphics.Subtitle.Render(Vis2.obj.dialogue
, {"time":t, "x":"center", "y":"83%", "padding":"1.35%", "color":"Black", "radius":8}, {"q":4, "size":"2.23%", "font":"Arial", "z":"Arial Narrow", "justify":"left", "color":"White"})
Vis2.Graphics.Subtitle.Render("Saved to Clipboard.", "time: " t ", x: center, y: 75%, p: 1.35%, c: F9E486, r: 8", "c: 0x000000, s:2.23%, f:Arial")
}
Vis2.obj.EXITCODE := 1
}
Vis2.obj.EXITCODE := (Vis2.obj.EXITCODE == 0) ? -1 : Vis2.obj.EXITCODE
SetTimer, % escape, -9
}
return
}
}
escape(){
static escape := ObjBindMethod(Vis2.core.ux, "escape")
static void := ObjBindMethod({}, {})
if (Vis2.obj.callback) {
if !(Vis2.obj.callbackConfirmed) {
SetTimer, % escape, -9
return
}
}
Gdip_DisposeImage(Vis2.obj.pBitmap)
Vis2.obj.provider.cleanup()
Vis2.obj.area.destroy()
Vis2.obj.image.destroy()
Vis2.obj.subtitle.destroy()
Vis2.obj.note_01.hide()
Vis2.obj.note_02.destroy()
Vis2.obj := ""
Vis2.Graphics.Shutdown()
if WinActive("ahk_id" Vis2.obj.area.hwnd) {
KeyWait Control
KeyWait Alt
KeyWait Shift
KeyWait RButton
KeyWait LButton
KeyWait Space
KeyWait Escape
}
Hotkey, LButton, % void, Off
Hotkey, ^LButton, % void, Off
Hotkey, !LButton, % void, Off
Hotkey, +LButton, % void, Off
Hotkey, RButton, % void, Off
Hotkey, Escape, % void, Off
Hotkey, Space, % void, Off
Hotkey, ^Space, % void, Off
Hotkey, !Space, % void, Off
Hotkey, +Space, % void, Off
return DllCall("SystemParametersInfo", "uInt",0x57, "uInt",0, "uInt",0, "uInt",0)
}
overlap() {
p1 := Vis2.obj.area.x1()
p2 := Vis2.obj.area.x2()
r1 := Vis2.obj.area.y1()
r2 := Vis2.obj.area.y2()
q1 := Vis2.obj.subtitle.x1()
q2 := Vis2.obj.subtitle.x2()
s1 := Vis2.obj.subtitle.y1()
s2 := Vis2.obj.subtitle.y2()
a := (p1 < q1 && q1 < p2) || (p1 < q2 && q2 < p2) || (q1 < p1 && p1 < q2) || (q1 < p2 && p2 < q2)
b := (r1 < s1 && s1 < r2) || (r1 < s2 && s2 < r2) || (s1 < r1 && r1 < s2) || (s1 < r2 && r2 < s2)
return (a && b)
}
suspend(){
static void := ObjBindMethod({}, {})
Hotkey, LButton, % void, Off
Hotkey, ^LButton, % void, Off
Hotkey, !LButton, % void, Off
Hotkey, +LButton, % void, Off
Hotkey, RButton, % void, Off
Hotkey, Escape, % void, Off
Hotkey, Space, % void, Off
Hotkey, ^Space, % void, Off
Hotkey, !Space, % void, Off
Hotkey, +Space, % void, Off
DllCall("SystemParametersInfo", "uInt",0x57, "uInt",0, "uInt",0, "uInt",0)
Vis2.obj.area.hide()
return
}
resume(){
Hotkey, LButton, % void, On
Hotkey, ^LButton, % void, On
Hotkey, !LButton, % void, On
Hotkey, +LButton, % void, On
Hotkey, RButton, % void, On
Hotkey, Escape, % void, On
if (Vis2.obj.selectMode == "Quick")
Vis2.stdlib.setSystemCursor(32515)
if (Vis2.obj.selectMode == "Advanced") {
Hotkey, Space, % void, On
Hotkey, ^Space, % void, On
Hotkey, !Space, % void, On
Hotkey, +Space, % void, On
}
Vis2.obj.area.show()
return
}
}
}
class functor {
__Call(method, ByRef arg := "", args*) {
if IsObject(method)
return (new this).Call(method, arg, args*)
else if (method == "")
return (new this).Call(arg, args*)
}
}
class Graphics {
static pToken, Gdip := 0
Startup(){
global pToken
return Vis2.Graphics.pToken := (Vis2.Graphics.Gdip++ > 0) ? Vis2.Graphics.pToken : (pToken) ? pToken : Gdip_Startup()
}
Shutdown(){
global pToken
return Vis2.Graphics.pToken := (--Vis2.Graphics.Gdip <= 0) ? ((pToken) ? pToken : Gdip_Shutdown(Vis2.Graphics.pToken)) : Vis2.Graphics.pToken
}
Name(){
VarSetCapacity(UUID, 16, 0)
if (DllCall("rpcrt4.dll\UuidCreate", "ptr", &UUID) != 0)
return (ErrorLevel := 1) & 0
if (DllCall("rpcrt4.dll\UuidToString", "ptr", &UUID, "uint*", suuid) != 0)
return (ErrorLevel := 2) & 0
return A_TickCount "n" SubStr(StrGet(suuid), 1, 8), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
}
class Area{
ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight,
action := ["base"], x := [0], y := [0], w := [1], h := [1], a := ["top left"], q := ["bottom right"]
__New(name := "", color := "0x7FDDDDDD") {
this.name := name := (name == "") ? Vis2.Graphics.Name() "_Graphics_Area" : name "_Graphics_Area"
this.color := color
Vis2.Graphics.Startup()
Gui, %name%:New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName, % this.name
Gui, %name%:Show, % (this.isDrawable()) ? "NoActivate" : ""
this.hwnd := SecretName
this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
this.hdc := CreateCompatibleDC()
this.obm := SelectObject(this.hdc, this.hbm)
this.G := Gdip_GraphicsFromHDC(this.hdc)
Gdip_SetSmoothingMode(this.G, 4)
this.pBrush := Gdip_BrushCreateSolid(this.color)
}
__Delete(){
Vis2.Graphics.Shutdown()
}
Destroy(){
Gdip_DeleteBrush(this.pBrush)
SelectObject(this.hdc, this.obm)
DeleteObject(this.hbm)
DeleteDC(this.hdc)
Gdip_DeleteGraphics(this.G)
Gui, % this.name ":Destroy"
}
Hide(){
DllCall("ShowWindow", "ptr",this.hWnd, "int",0)
}
Show(){
DllCall("ShowWindow", "ptr",this.hWnd, "int",8)
}
ToggleVisible(){
this.isVisible() ? this.Hide() : this.Show()
}
isVisible(){
return DllCall("IsWindowVisible", "ptr",this.hWnd)
}
isDrawable(win := "A"){
static WM_KEYDOWN := 0x100,
static WM_KEYUP := 0x101,
static vk_to_use := 7
PostMessage, WM_KEYDOWN, vk_to_use, 0,, % win
if !ErrorLevel
{
PostMessage, WM_KEYUP, vk_to_use, 0xC0000000,, % win
return true
}
return false
}
DetectScreenResolutionChange(){
if (this.ScreenWidth != A_ScreenWidth || this.ScreenHeight != A_ScreenHeight) {
this.ScreenWidth := A_ScreenWidth, this.ScreenHeight := A_ScreenHeight
SelectObject(this.hdc, this.obm)
DeleteObject(this.hbm)
DeleteDC(this.hdc)
Gdip_DeleteGraphics(this.G)
this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
this.hdc := CreateCompatibleDC()
this.obm := SelectObject(this.hdc, this.hbm)
this.G := Gdip_GraphicsFromHDC(this.hdc)
Gdip_SetSmoothingMode(this.G, 4)
}
}
Redraw(x, y, w, h){
Critical On
this.DetectScreenResolutionChange()
Gdip_GraphicsClear(this.G)
Gdip_FillRectangle(this.G, this.pBrush, x, y, w, h)
if (this.coordinates)
Vis2.Graphics.Subtitle.Draw("x: " x " â”‚ y: " y " â”‚ w: " w " â”‚ h: " h
, {"a":"top_right", "x":"right", "y":"top", "color":"Black"}, {"font":"Lucida Sans Typewriter", "size":"1.67%"}, this.G)
UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)
Critical Off
}
ChangeColor(color){
this.color := color
Gdip_DeleteBrush(this.pBrush)
this.pBrush := Gdip_BrushCreateSolid(this.color)
this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
}
ShowCoordinates(){
this.coordinates := true
this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
}
HideCoordinates(){
this.coodinates := false
this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
}
ToggleCoordinates(){
this.coordinates := !this.coordinates
this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
}
Propagate(v){
this.a[v] := (this.a[v] == "") ? this.a[v-1] : this.a[v]
this.q[v] := (this.q[v] == "") ? this.q[v-1] : this.q[v]
this.x[v] := (this.x[v] == "") ? this.x[v-1] : this.x[v]
this.y[v] := (this.y[v] == "") ? this.y[v-1] : this.y[v]
this.w[v] := (this.w[v] == "") ? this.w[v-1] : this.w[v]
this.h[v] := (this.h[v] == "") ? this.h[v-1] : this.h[v]
}
BackPropagate(pasts){
action := this.action.pop()
a := this.a.pop()
q := this.q.pop()
x := this.x.pop()
y := this.y.pop()
w := this.w.pop()
h := this.h.pop()
dx := x - this.x[pasts-1]
dy := y - this.y[pasts-1]
dw := w - this.w[pasts-1]
dh := h - this.h[pasts-1]
i := pasts-1
while (i >= 1) {
this.x[i] += dx
this.y[i] += dy
this.w[i] += dw
this.h[i] += dh
i--
}
}
Converge(v := ""){
v := (v) ? v : this.action.MaxIndex()
if (v > 2) {
this.action := [this.action[v-1], this.action[v]]
this.a := [this.a[v-1], this.a[v]]
this.q := [this.q[v-1], this.q[v]]
this.x := [this.x[v-1], this.x[v]]
this.y := [this.y[v-1], this.y[v]]
this.w := [this.w[v-1], this.w[v]]
this.h := [this.h[v-1], this.h[v]]
}
}
Debug(function){
v := (v) ? v : this.action.MaxIndex()
Tooltip % function "`t" v . "`n" v-1 ": " this.action[v-1]
. "`n" this.x[v-2] ", " this.y[v-2] ", " this.w[v-2] ", " this.h[v-2]
. "`n" this.x[v-1] ", " this.y[v-1] ", " this.w[v-1] ", " this.h[v-1]
. "`n" this.x[v] ", " this.y[v] ", " this.w[v] ", " this.h[v]
. "`nAnchor:`t" this.a[v] "`nMouse:`t" this.q[v] "`t" this.isMouseInside()
}
Hover(){
CoordMode, Mouse, Window
MouseGetPos, x_hover, y_hover
this.x_hover := x_hover
this.y_hover := y_hover
if (A_ThisFunc != this.action[this.action.MaxIndex()]){
this.action := [A_ThisFunc]
this.a := [this.a.pop()]
this.q := [this.q.pop()]
this.x := [this.x.pop()]
this.y := [this.y.pop()]
this.w := [this.w.pop()]
this.h := [this.h.pop()]
}
}
Origin(v := ""){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
if (A_ThisFunc != this.action[this.action.MaxIndex()]){
this.action.push(A_ThisFunc)
this.x_hover := x_mouse
this.y_hover := y_mouse
}
v := (v) ? v : this.action.MaxIndex()
if (x_mouse != this.x_last || y_mouse != this.y_last) {
this.x_last := x_mouse, this.y_last := y_mouse
this.x[v] := x_mouse
this.y[v] := y_mouse
this.Propagate(v)
this.Redraw(x_mouse, y_mouse, 1, 1)
}
}
Draw(v := ""){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
if (A_ThisFunc == this.action[this.action.MaxIndex()-1]){
this.BackPropagate(this.action.MaxIndex())
this.x_hover := x_mouse
this.y_hover := y_mouse
pass := 1
}
if (A_ThisFunc != this.action[this.action.MaxIndex()]){
this.Converge()
this.action.push(A_ThisFunc)
this.x_hover := x_mouse
this.y_hover := y_mouse
pass := 1
}
v := (v) ? v : this.action.MaxIndex()
dx := x_mouse - this.x_hover
dy := y_mouse - this.y_hover
xr := (x_mouse > this.x[v-1]) ? 1 : 0
yr := (y_mouse > this.y[v-1]) ? 1 : 0
if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
this.x_last := x_mouse, this.y_last := y_mouse
this.x[v] := (xr) ? this.x[v-1] : x_mouse
this.y[v] := (yr) ? this.y[v-1] : y_mouse
this.w[v] := (xr) ? x_mouse - this.x[v-1] : this.x[v-1] - x_mouse
this.h[v] := (yr) ? y_mouse - this.y[v-1] : this.y[v-1] - y_mouse
this.a[v] := (xr && yr) ? "top left" : (xr && !yr) ? "bottom left" : (!xr && yr) ? "top right" : "bottom right"
this.q[v] := (xr && yr) ? "bottom right" : (xr && !yr) ? "top right" : (!xr && yr) ? "bottom left" : "top left"
this.Propagate(v)
this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
}
}
Move(v := ""){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
if (A_ThisFunc != this.action[this.action.MaxIndex()]){
this.Converge()
this.action.push(A_ThisFunc)
this.x_hover := x_mouse
this.y_hover := y_mouse
pass := 1
}
v := (v) ? v : this.action.MaxIndex()
dx := x_mouse - this.x_hover
dy := y_mouse - this.y_hover
if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
this.x_last := x_mouse, this.y_last := y_mouse
this.x[v] := this.x[v-1] + dx
this.y[v] := this.y[v-1] + dy
this.Propagate(v)
this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
}
}
ResizeCorners(v := ""){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
if (A_ThisFunc != this.action[this.action.MaxIndex()]){
this.Converge()
this.action.push(A_ThisFunc)
this.x_hover := x_mouse
this.y_hover := y_mouse
pass := 1
}
v := (v) ? v : this.action.MaxIndex()
xr := this.x_hover - this.x[v-1] - (this.w[v-1] / 2)
yr := this.y[v-1] - this.y_hover + (this.h[v-1] / 2)
dx := x_mouse - this.x_hover
dy := y_mouse - this.y_hover
if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
this.x_last := x_mouse, this.y_last := y_mouse
if (xr < -1 && yr > 1) {
r := "top left"
this.x[v] := this.x[v-1] + dx
this.y[v] := this.y[v-1] + dy
this.w[v] := this.w[v-1] - dx
this.h[v] := this.h[v-1] - dy
}
if (xr >= -1 && yr > 1) {
r := "top right"
this.x[v] := this.x[v-1]
this.y[v] := this.y[v-1] + dy
this.w[v] := this.w[v-1] + dx
this.h[v] := this.h[v-1] - dy
}
if (xr < -1 && yr <= 1) {
r := "bottom left"
this.x[v] := this.x[v-1] + dx
this.y[v] := this.y[v-1]
this.w[v] := this.w[v-1] - dx
this.h[v] := this.h[v-1] + dy
}
if (xr >= -1 && yr <= 1) {
r := "bottom right"
this.x[v] := this.x[v-1]
this.y[v] := this.y[v-1]
this.w[v] := this.w[v-1] + dx
this.h[v] := this.h[v-1] + dy
}
this.Propagate(v)
this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
}
}
ResizeEdges(v := ""){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
if (A_ThisFunc != this.action[this.action.MaxIndex()]){
this.Converge()
this.action.push(A_ThisFunc)
this.x_hover := x_mouse
this.y_hover := y_mouse
pass := 1
}
v := (v) ? v : this.action.MaxIndex()
m := -(this.h[v-1] / this.w[v-1])
xr := this.x_hover - this.x[v-1] - (this.w[v-1] / 2)
yr := this.y[v-1] - this.y_hover + (this.h[v-1] / 2)
dx := x_mouse - this.x_hover
dy := y_mouse - this.y_hover
if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
this.x_last := x_mouse, this.y_last := y_mouse
if (m * xr >= yr && yr > -m * xr)
r := "left",                this.x[v] := this.x[v-1] + dx,               this.w[v] := this.w[v-1] - dx
if (m * xr < yr && yr > -m * xr)
r := "top",                 this.y[v] := this.y[v-1] + dy,               this.h[v] := this.h[v-1] - dy
if (m * xr < yr && yr <= -m * xr)
r := "right",   this.w[v] := this.w[v-1] + dx
if (m * xr >= yr && yr <= -m * xr)
r := "bottom",  this.h[v] := this.h[v-1] + dy
this.Propagate(v)
this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
}
}
isMouseInside(){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
return (x_mouse >= this.x[this.x.MaxIndex()]
&& x_mouse <= this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()]
&& y_mouse >= this.y[this.y.MaxIndex()]
&& y_mouse <= this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()])
}
isMouseOutside(){
return !this.isMouseInside()
}
isMouseOnCorner(){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
return (x_mouse == this.x[this.x.MaxIndex()] || x_mouse == this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()])
&& (y_mouse == this.y[this.y.MaxIndex()] || y_mouse == this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()])
}
isMouseOnEdge(){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
return ((x_mouse >= this.x[this.x.MaxIndex()] && x_mouse <= this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()])
&& (y_mouse == this.y[this.y.MaxIndex()] || y_mouse == this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()]))
OR ((y_mouse >= this.y[this.y.MaxIndex()] && y_mouse <= this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()])
&& (x_mouse == this.x[this.x.MaxIndex()] || x_mouse == this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()]))
}
isMouseStopped(){
CoordMode, Mouse, Window
MouseGetPos, x_mouse, y_mouse
return x_mouse == this.x_last && y_mouse == this.y_last
}
ScreenshotRectangle(){
x := this.x1(), y := this.y1(), w := this.width(), h := this.height()
return (w > 0 && h > 0) ? (x "|" y "|" w "|" h) : ""
}
x1(){
return this.x[this.x.MaxIndex()]
}
x2(){
return this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()]
}
y1(){
return this.y[this.y.MaxIndex()]
}
y2(){
return this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()]
}
width(){
return this.w[this.w.MaxIndex()]
}
height(){
return this.h[this.h.MaxIndex()]
}
}
Class CustomFont{
static FR_PRIVATE  := 0x10
__New(FontFile, FontName="", FontSize=30) {
if RegExMatch(FontFile, "i)res:\K.*", _FontFile) {
this.AddFromResource(_FontFile, FontName, FontSize)
} else {
this.AddFromFile(FontFile)
}
}
AddFromFile(FontFile) {
DllCall( "AddFontResourceEx", "Str", FontFile, "UInt", this.FR_PRIVATE, "UInt", 0 )
this.data := FontFile
}
AddFromResource(ResourceName, FontName, FontSize = 30) {
static FW_NORMAL := 400, DEFAULT_CHARSET := 0x1
nSize    := this.ResRead(fData, ResourceName)
fh       := DllCall( "AddFontMemResourceEx", "Ptr", &fData, "UInt", nSize, "UInt", 0, "UIntP", nFonts )
hFont    := DllCall( "CreateFont", Int,FontSize, Int,0, Int,0, Int,0, UInt,FW_NORMAL, UInt,0
, Int,0, Int,0, UInt,DEFAULT_CHARSET, Int,0, Int,0, Int,0, Int,0, Str,FontName )
this.data := {fh: fh, hFont: hFont}
}
ApplyTo(hCtrl) {
SendMessage, 0x30, this.data.hFont, 1,, ahk_id %hCtrl%
}
__Delete() {
if IsObject(this.data) {
DllCall( "RemoveFontMemResourceEx", "UInt", this.data.fh    )
DllCall( "DeleteObject"           , "UInt", this.data.hFont )
} else {
DllCall( "RemoveFontResourceEx"   , "Str", this.data, "UInt", this.FR_PRIVATE, "UInt", 0 )
}
}
ResRead( ByRef Var, Key ) {
VarSetCapacity( Var, 128 ), VarSetCapacity( Var, 0 )
If ! ( A_IsCompiled ) {
FileGetSize, nSize, %Key%
FileRead, Var, *c %Key%
Return nSize
}
If hMod := DllCall( "GetModuleHandle", UInt,0 )
If hRes := DllCall( "FindResource", UInt,hMod, Str,Key, UInt,10 )
If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
If pData := DllCall( "LockResource", UInt,hData )
Return VarSetCapacity( Var, nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ) )
,  DllCall( "RtlMoveMemory", Str,Var, UInt,pData, UInt,nSize )
Return 0
}
}
class Image{
ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight
__New(name := "") {
this.name := name := (name == "") ? Vis2.Graphics.Name() "_Graphics_Image" : name "_Graphics_Image"
Vis2.Graphics.Startup()
Gui, %name%: New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName, % this.name
this.hwnd := SecretName
DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
this.hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
this.hdc := CreateCompatibleDC()
this.obm := SelectObject(this.hdc, this.hbm)
this.G := Gdip_GraphicsFromHDC(this.hdc)
Gdip_SetInterpolationMode(this.G, 7)
}
__Delete(){
Vis2.Graphics.Shutdown()
}
Border() {
Gui, % this.name ": +Border"
UpdateLayeredWindow(this.hwnd, this.hdc, (A_ScreenWidth-this.w)/2, (A_ScreenHeight-this.h)/2, this.w, this.h)
return this
}
Destroy() {
SelectObject(this.hdc, this.obm)
DeleteObject(this.hbm)
DeleteDC(this.hdc)
Gdip_DeleteGraphics(this.G)
Gui, % this.name ":Destroy"
return this
}
Hide() {
Gui, % this.name ":Show", Hide
return this
}
Show() {
Gui, % this.name ":Show", NoActivate
return this
}
ToggleVisible() {
if DllCall("IsWindowVisible", "UInt", this.hwnd)
Gui, % this.name ":Show", Hide
else
Gui, % this.name ":Show", NoActivate
return this
}
isVisible() {
return DllCall("IsWindowVisible", "UInt", this.hwnd)
}
Render(file, scale := 1, time := 0) {
if (this.hwnd){
this.scale := scale
if (time) {
self_destruct := ObjBindMethod(this, "Destroy")
SetTimer, % self_destruct, % -1 * time
}
Critical On
if FileExist(file)
f := pBitmap := Gdip_CreateBitmapFromFile(file)
else pBitmap := file
Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
this.DetectScreenResolutionChange(Width, Height)
Gdip_DrawImage(this.G, pBitmap, 0, 0, Floor(Width*scale), Floor(Height*scale), 0, 0, Width, Height)
UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, Floor(Width*scale), Floor(Height*scale))
this.w := Floor(Width*scale)
this.h := Floor(Height*scale)
if f
Gdip_DisposeImage(pBitmap)
Critical Off
return this
}
else {
parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
Loop, Parse, parent, .
parent := (A_Index=1) ? %A_LoopField% : parent[A_LoopField]
_image := (parent) ? new parent.image() : new image()
return _image.Render(file, scale, time)
}
}
DetectScreenResolutionChange(w:="", h:=""){
w := (w) ? w : A_ScreenWidth
h := (h) ? h : A_ScreenHeight
if (this.ScreenWidth != w || this.ScreenHeight != h) {
this.ScreenWidth := w, this.ScreenHeight := h
SelectObject(this.hdc, this.obm)
DeleteObject(this.hbm)
DeleteDC(this.hdc)
Gdip_DeleteGraphics(this.G)
this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
this.hdc := CreateCompatibleDC()
this.obm := SelectObject(this.hdc, this.hbm)
this.G := Gdip_GraphicsFromHDC(this.hdc)
Gdip_SetInterpolationMode(this.G, 7)
}
}
}
class Subtitle{
layers := {}, ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight
__New(name := ""){
parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
Loop, Parse, parent, .
this.parent := (A_Index=1) ? %A_LoopField% : this.parent[A_LoopField]
this.parent.Startup()
Gui, New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName
this.hwnd := SecretName
this.name := (name != "") ? name "_Subtitle" : "Subtitle_" this.hwnd
DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
DllCall("SetWindowText", "ptr",this.hwnd, "str",this.name)
this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
this.hdc := CreateCompatibleDC()
this.obm := SelectObject(this.hdc, this.hbm)
this.G := Gdip_GraphicsFromHDC(this.hdc)
this.colorMap := this.colorMap()
}
__Delete(){
this.parent.Shutdown()
}
FreeMemory(){
SelectObject(this.hdc, this.obm)
DeleteObject(this.hbm)
DeleteDC(this.hdc)
Gdip_DeleteGraphics(this.G)
return this
}
Destroy(){
this.FreeMemory()
DllCall("DestroyWindow", "ptr",this.hwnd)
return this
}
Hide(){
DllCall("ShowWindow", "ptr",this.hwnd, "int",0)
return this
}
Show(){
DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
return this
}
ToggleVisible(){
this.isVisible() ? this.Hide() : this.Show()
return this
}
isVisible(){
return DllCall("IsWindowVisible", "ptr",this.hwnd)
}
ClickThrough(){
DetectHiddenWindows On
WinSet, ExStyle, +0x20, % "ahk_id" this.hwnd
DetectHiddenWindows Off
return this
}
DetectScreenResolutionChange(w:="", h:=""){
w := (w) ? w : A_ScreenWidth
h := (h) ? h : A_ScreenHeight
if (this.ScreenWidth != w || this.ScreenHeight != h) {
this.ScreenWidth := w, this.ScreenHeight := h
SelectObject(this.hdc, this.obm)
DeleteObject(this.hbm)
DeleteDC(this.hdc)
Gdip_DeleteGraphics(this.G)
this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
this.hdc := CreateCompatibleDC()
this.obm := SelectObject(this.hdc, this.hbm)
this.G := Gdip_GraphicsFromHDC(this.hdc)
}
}
Draw(text := "", style1 := "", style2 := "", pGraphics := "") {
if (pGraphics == "") {
pGraphics := this.G
if (this.rendered == true) {
this.rendered := false
this.layers := {}
this.x := this.y := this.xx := this.yy := ""
Gdip_GraphicsClear(this.G)
}
this.layers.push([text, style1, style2])
}
style1 := (style1) ? this.style1 := style1 : this.style1
style2 := (style2) ? this.style2 := style2 : this.style2
static q1 := "i)^.*?(?<!-|:|:\s)\b(?![^\(]*\))"
static q2 := "(:\s?)?\(?(?<value>(?<=\()[\s\-\da-z\.#%]+(?=\))|[\-\da-z\.#%]+).*$"
time := (style1.t) ? style1.t : (style1.time) ? style1.time
: (!IsObject(style1) && (___ := RegExReplace(style1, q1 "(t(ime)?)" q2, "${value}")) != style1) ? ___
: (style2.t) ? style2.t : (style2.time) ? style2.time
: (!IsObject(style2) && (___ := RegExReplace(style2, q1 "(t(ime)?)" q2, "${value}")) != style2) ? ___
: 0
if (time) {
self_destruct := ObjBindMethod(this, "Destroy")
SetTimer, % self_destruct, % -1 * time
}
static alpha := "^[A-Za-z]+$"
static decimal := "^(\-?\d+(\.\d*)?)$"
static integer := "^\d+$"
static percentage := "^(\-?\d+(?:\.\d*)?)%$"
static positive := "^\d+(\.\d*)?$"
if IsObject(style1){
_a  := (style1.a != "")  ? style1.a  : style1.anchor
_x  := (style1.x != "")  ? style1.x  : style1.left
_y  := (style1.y != "")  ? style1.y  : style1.top
_w  := (style1.w != "")  ? style1.w  : style1.width
_h  := (style1.h != "")  ? style1.h  : style1.height
_r  := (style1.r != "")  ? style1.r  : style1.radius
_c  := (style1.c != "")  ? style1.c  : style1.color
_m  := (style1.m != "")  ? style1.m  : style1.margin
_p  := (style1.p != "")  ? style1.p  : style1.padding
_q  := (style1.q != "")  ? style1.q  : (style1.quality) ? style1.quality : style1.SmoothingMode
} else {
_a  := ((___ := RegExReplace(style1, q1    "(a(nchor)?)"            q2, "${value}")) != style1) ? ___ : ""
_x  := ((___ := RegExReplace(style1, q1    "(x|left)"               q2, "${value}")) != style1) ? ___ : ""
_y  := ((___ := RegExReplace(style1, q1    "(y|top)"                q2, "${value}")) != style1) ? ___ : ""
_w  := ((___ := RegExReplace(style1, q1    "(w(idth)?)"             q2, "${value}")) != style1) ? ___ : ""
_h  := ((___ := RegExReplace(style1, q1    "(h(eight)?)"            q2, "${value}")) != style1) ? ___ : ""
_r  := ((___ := RegExReplace(style1, q1    "(r(adius)?)"            q2, "${value}")) != style1) ? ___ : ""
_c  := ((___ := RegExReplace(style1, q1    "(c(olor)?)"             q2, "${value}")) != style1) ? ___ : ""
_m  := ((___ := RegExReplace(style1, q1    "(m(argin)?)"            q2, "${value}")) != style1) ? ___ : ""
_p  := ((___ := RegExReplace(style1, q1    "(p(adding)?)"           q2, "${value}")) != style1) ? ___ : ""
_q  := ((___ := RegExReplace(style1, q1    "(q(uality)?)"           q2, "${value}")) != style1) ? ___ : ""
}
if IsObject(style2){
a  := (style2.a != "")  ? style2.a  : style2.anchor
x  := (style2.x != "")  ? style2.x  : style2.left
y  := (style2.y != "")  ? style2.y  : style2.top
w  := (style2.w != "")  ? style2.w  : style2.width
h  := (style2.h != "")  ? style2.h  : style2.height
m  := (style2.m != "")  ? style2.m  : style2.margin
f  := (style2.f != "")  ? style2.f  : style2.font
s  := (style2.s != "")  ? style2.s  : style2.size
c  := (style2.c != "")  ? style2.c  : style2.color
b  := (style2.b != "")  ? style2.b  : style2.bold
i  := (style2.i != "")  ? style2.i  : style2.italic
u  := (style2.u != "")  ? style2.u  : style2.underline
j  := (style2.j != "")  ? style2.j  : style2.justify
n  := (style2.n != "")  ? style2.n  : style2.noWrap
z  := (style2.z != "")  ? style2.z  : style2.condensed
d  := (style2.d != "")  ? style2.d  : style2.dropShadow
o  := (style2.o != "")  ? style2.o  : style2.outline
q  := (style2.q != "")  ? style2.q  : (style2.quality) ? style2.quality : style2.TextRenderingHint
} else {
a  := ((___ := RegExReplace(style2, q1    "(a(nchor)?)"            q2, "${value}")) != style2) ? ___ : ""
x  := ((___ := RegExReplace(style2, q1    "(x|left)"               q2, "${value}")) != style2) ? ___ : ""
y  := ((___ := RegExReplace(style2, q1    "(y|top)"                q2, "${value}")) != style2) ? ___ : ""
w  := ((___ := RegExReplace(style2, q1    "(w(idth)?)"             q2, "${value}")) != style2) ? ___ : ""
h  := ((___ := RegExReplace(style2, q1    "(h(eight)?)"            q2, "${value}")) != style2) ? ___ : ""
m  := ((___ := RegExReplace(style2, q1    "(m(argin)?)"            q2, "${value}")) != style2) ? ___ : ""
f  := ((___ := RegExReplace(style2, q1    "(f(ont)?)"              q2, "${value}")) != style2) ? ___ : ""
s  := ((___ := RegExReplace(style2, q1    "(s(ize)?)"              q2, "${value}")) != style2) ? ___ : ""
c  := ((___ := RegExReplace(style2, q1    "(c(olor)?)"             q2, "${value}")) != style2) ? ___ : ""
b  := ((___ := RegExReplace(style2, q1    "(b(old)?)"              q2, "${value}")) != style2) ? ___ : ""
i  := ((___ := RegExReplace(style2, q1    "(i(talic)?)"            q2, "${value}")) != style2) ? ___ : ""
u  := ((___ := RegExReplace(style2, q1    "(u(nderline)?)"         q2, "${value}")) != style2) ? ___ : ""
j  := ((___ := RegExReplace(style2, q1    "(j(ustify)?)"           q2, "${value}")) != style2) ? ___ : ""
n  := ((___ := RegExReplace(style2, q1    "(n(oWrap)?)"            q2, "${value}")) != style2) ? ___ : ""
z  := ((___ := RegExReplace(style2, q1    "(z|condensed?)"         q2, "${value}")) != style2) ? ___ : ""
d  := ((___ := RegExReplace(style2, q1    "(d(ropShadow)?)"        q2, "${value}")) != style2) ? ___ : ""
o  := ((___ := RegExReplace(style2, q1    "(o(utline)?)"           q2, "${value}")) != style2) ? ___ : ""
q  := ((___ := RegExReplace(style2, q1    "(q(uality)?)"           q2, "${value}")) != style2) ? ___ : ""
}
style += (b) ? 1 : 0
style += (i) ? 2 : 0
style += (u) ? 4 : 0
style += (strike) ? 8 : 0
s  := (s ~= percentage) ? A_ScreenHeight * SubStr(s, 1, -1)  / 100 :  s
s  := (s ~= positive) ? s : 36
q  := (q >= 0 && q <= 5) ? q : 4
n  := (n) ? 0x4000 | 0x1000 : 0x4000
j  := (j ~= "i)cent(er|re)") ? 1 : (j ~= "i)(far|right)") ? 2 : 0
_q := (_q >= 0 && _q <= 4) ? _q : 4
Gdip_SetSmoothingMode(pGraphics, _q)
Gdip_SetTextRenderingHint(pGraphics, q)
hFamily := (___ := Gdip_FontFamilyCreate(f)) ? ___ : Gdip_FontFamilyCreate("Arial")
hFont := Gdip_FontCreate(hFamily, s, style)
hFormat := Gdip_StringFormatCreate(n)
Gdip_SetStringFormatAlign(hFormat, j)
CreateRectF(RC, 0, 0, 0, 0)
ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
ReturnRC := StrSplit(ReturnRC, "|")
_m := this.margin(_m)
_p := this.margin(_p)
m := this.margin( m)
p := this.margin( p)
if (___ := Gdip_FontFamilyCreate(z)) {
ExtraMargin := (_m.2 + _m.4 + _p.2 + _p.4)
if (ReturnRC[3] + ExtraMargin > A_ScreenWidth){
hFamily := Gdip_FontFamilyCreate(z)
hFont := Gdip_FontCreate(hFamily, s, style)
ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
ReturnRC := StrSplit(ReturnRC, "|")
_w  := ReturnRC[3]
}
}
_w  := (_w  ~= percentage) ? A_ScreenWidth  * SubStr(_w, 1, -1)  / 100 : _w
_h  := (_h  ~= percentage) ? A_ScreenHeight * SubStr(_h, 1, -1)  / 100 : _h
_w  := (_w  ~= positive) ? _w  : ReturnRC[3]
_h  := (_h  ~= positive) ? _h  : ReturnRC[4]
_a  := (_a = "top") ? 2 : (_a = "left") ? 4 : (_a = "right") ? 6 : (_a = "bottom") ? 8
: (_a ~= "i)top" && _a ~= "i)left") ? 1 : (_a ~= "i)top" && _a ~= "i)cent(er|re)") ? 2
: (_a ~= "i)top" && _a ~= "i)bottom") ? 3 : (_a ~= "i)cent(er|re)" && _a ~= "i)left") ? 4
: (_a ~= "i)cent(er|re)") ? 5 : (_a ~= "i)cent(er|re)" && _a ~= "i)bottom") ? 6
: (_a ~= "i)bottom" && _a ~= "i)left") ? 7 : (_a ~= "i)bottom" && _a ~= "i)cent(er|re)") ? 8
: (_a ~= "i)bottom" && _a ~= "i)right") ? 9 : (_a ~= "^[1-9]$") ? _a : 1
_a  := (_x  = "left") ? 1+(((_a-1)//3)*3) : (_x ~= "i)cent(er|re)") ? 2+(((_a-1)//3)*3) : (_x = "right") ? 3+(((_a-1)//3)*3) : _a
_a  := (_y  = "top") ? 1+(mod(_a-1,3)) : (_y ~= "i)cent(er|re)") ? 4+(mod(_a-1,3)) : (_y = "bottom") ? 7+(mod(_a-1,3)) : _a
_x  := (_x  = "left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*A_ScreenWidth : (_x = "right") ? A_ScreenWidth : _x
_y  := (_y  = "top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*A_ScreenHeight : (_y = "bottom") ? A_ScreenHeight : _y
_x  := (_x  ~= percentage) ? A_ScreenWidth  * SubStr(_x, 1, -1)  / 100 : _x
_y  := (_y  ~= percentage) ? A_ScreenHeight * SubStr(_y, 1, -1)  / 100 : _y
_x  := (_x  ~= decimal) ? _x  : 0
_y  := (_y  ~= decimal) ? _y  : 0
_x  -= (mod(_a-1,3) == 0) ? 0 : (mod(_a-1,3) == 1) ? _w/2 : (mod(_a-1,3) == 2) ? _w : 0
_y  -= (((_a-1)//3) == 0) ? 0 : (((_a-1)//3) == 1) ? _h/2 : (((_a-1)//3) == 2) ? _h : 0
w  := ( w  ~= percentage) ? _w * RegExReplace( w, percentage, "$1")  / 100 : w
h  := ( h  ~= percentage) ? _h * RegExReplace( h, percentage, "$1")  / 100 : h
w  := ( w  ~= positive) ?  w  : (_w) ? _w : ReturnRC[3]
h  := ( h  ~= positive) ?  h  : (_h) ? _h : ReturnRC[4]
a  := (a = "top") ? 2 : (a = "left") ? 4 : (a = "right") ? 6 : (a = "bottom") ? 8
: (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
: (a ~= "i)top" && a ~= "i)bottom") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
: (a ~= "i)cent(er|re)") ? 5 : (_a ~= "i)cent(er|re)" && a ~= "i)bottom") ? 6
: (a ~= "i)bottom" && a ~= "i)left") ? 7 : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8
: (a ~= "i)bottom" && a ~= "i)right") ? 9 : (a ~= "^[1-9]$") ? a : 1
a  := ( x  = "left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x = "right") ? 3+((( a-1)//3)*3) :  a
a  := ( y  = "top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y = "bottom") ? 7+(mod( a-1,3)) :  a
x  := ( x  = "left") ? _x : (x ~= "i)cent(er|re)") ? _x + 0.5*_w : (x = "right") ? _x + _w : x
y  := ( y  = "top") ? _y : (y ~= "i)cent(er|re)") ? _y + 0.5*_h : (y = "bottom") ? _y + _h : y
x  := ( x  ~= percentage) ? _x + (_w * RegExReplace( x, percentage, "$1")  / 100) : x
y  := ( y  ~= percentage) ? _y + (_h * RegExReplace( y, percentage, "$1")  / 100) : y
x  := ( x  ~= decimal) ? x  : _x
y  := ( y  ~= decimal) ? y  : _y
x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? ReturnRC[3]/2 : (mod(a-1,3) == 2) ? ReturnRC[3] : 0
y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? ReturnRC[4]/2 : (((a-1)//3) == 2) ? ReturnRC[4] : 0
if (_w && _h) {
_w  += (_m.2 + _m.4 + _p.2 + _p.4) + (m.2 + m.4 + p.2 + p.4)
_h  += (_m.1 + _m.3 + _p.1 + _p.3) + (m.1 + m.3 + p.1 + p.3)
_x  -= (_m.1 + _p.1)
_y  -= (_m.4 + _p.4)
}
x  += (m.1 + p.1)
y  += (m.4 + p.4)
_smaller := (_w > _h) ? _h : _w
_r  := (_r  ~= percentage) ? _smaller * RegExReplace(_r, percentage, "$1")  / 100 : _r
_r  := (_r  <= _smaller / 2 && _r ~= positive) ? _r : 0
_c := this.color(_c, 0xDD424242)
c := this.color( c, 0xFFFFFFFF)
o := this.outline(o)
d := this.dropShadow(d)
if (!A_IsUnicode){
nSize := DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",0, "int",0)
VarSetCapacity(wtext, nSize*2)
DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",&wtext, "int",nSize)
}
if (_w && _h && _c && (_c & 0xFF000000)) {
pBrushBackground := Gdip_BrushCreateSolid(_c)
Gdip_FillRoundedRectangle(pGraphics, pBrushBackground, _x, _y, _w, _h, _r)
Gdip_DeleteBrush(pBrushBackground)
}
if (!d.void) {
delta := 2*d.3 + 2*o.1
offset := d.3 + o.1
if (d.3) {
pBitmap := Gdip_CreateBitmap(w + delta, h + delta)
pGraphicsDropShadow := Gdip_GraphicsFromImage(pBitmap)
Gdip_SetSmoothingMode(pGraphicsDropShadow, _q)
Gdip_SetTextRenderingHint(pGraphicsDropShadow, q)
CreateRectF(RC, offset, offset, w + delta, h + delta)
} else {
CreateRectF(RC, x + d.1, y + d.2, w, h)
pGraphicsDropShadow := pGraphics
}
if (!o.void)
{
DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
, "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)
pPen := Gdip_CreatePen(d.4, o.1)
DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uInt",2)
DllCall("gdiplus\GdipDrawPath", "ptr",pGraphicsDropShadow, "ptr",pPen, "ptr",pPath)
Gdip_DeletePen(pPen)
pBrush := Gdip_BrushCreateSolid(d.4)
Gdip_SetCompositingMode(pGraphicsDropShadow, 1)
Gdip_SetSmoothingMode(pGraphicsDropShadow, 3)
Gdip_FillPath(pGraphicsDropShadow, pBrush, pPath)
Gdip_DeleteBrush(pBrush)
Gdip_DeletePath(pPath)
Gdip_SetCompositingMode(pGraphicsDropShadow, 0)
Gdip_SetSmoothingMode(pGraphicsDropShadow, _q)
}
else
{
pBrush := Gdip_BrushCreateSolid(d.4)
Gdip_DrawString(pGraphicsDropShadow, Text, hFont, hFormat, pBrush, RC)
Gdip_DeleteBrush(pBrush)
}
if (d.3) {
Gdip_DeleteGraphics(pGraphicsDropShadow)
pBlur := Gdip_BlurBitmap(pBitmap, d.3)
Gdip_DisposeImage(pBitmap)
Gdip_DrawImage(pGraphics, pBlur, x + d.1 - offset, y + d.2 - offset, w + delta, h + delta)
Gdip_DisposeImage(pBlur)
}
}
if (!o.void) {
CreateRectF(RC, x, y, w, h)
DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
, "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)
pPen := Gdip_CreatePen(o.2, o.1)
DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uint",2)
if (o.3) {
DllCall("gdiplus\GdipClonePath", "ptr",pPath, "uptr*",pPathGlow)
DllCall("gdiplus\GdipWidenPath", "ptr",pPathGlow, "ptr",pPen, "ptr",0, "float",1)
color := (o.4) ? o.4 : o.2
loop % o.3
{
ARGB := Format("0x{:02X}",((color & 0xFF000000) >> 24)/o.3) . Format("{:06X}",(color & 0x00FFFFFF))
pPenGlow := Gdip_CreatePen(ARGB, A_Index)
DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPenGlow, "uInt",2)
DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPenGlow, "ptr",pPathGlow)
Gdip_DeletePen(pPenGlow)
}
Gdip_DeletePath(pPathGlow)
}
if (o.1)
DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath)
if (c && (c & 0xFF000000)) {
pBrush := Gdip_BrushCreateSolid(c)
Gdip_FillPath(pGraphics, pBrush, pPath)
Gdip_DeleteBrush(pBrush)
}
Gdip_DeletePen(pPen)
Gdip_DeletePath(pPath)
}
if (text != "" && d.void && o.void) {
CreateRectF(RC, x, y, w, h)
pBrushText := Gdip_BrushCreateSolid(c)
Gdip_DrawString(pGraphics, text, hFont, hFormat, pBrushText, RC)
Gdip_DeleteBrush(pBrushText)
}
Gdip_DeleteStringFormat(hFormat)
Gdip_DeleteFont(hFont)
Gdip_DeleteFontFamily(hFamily)
_w := (_w == 0) ? (ReturnRC[3] + d.1 + 2*d.3 + 2*o.1 + 2*o.3) : _w
_h := (_h == 0) ? (ReturnRC[4] + d.2 + 2*d.3 + 2*o.1 + 2*o.3) : _h
this.x  := (this.x  = "" || _x < this.x) ? _x : this.x
this.y  := (this.y  = "" || _y < this.y) ? _y : this.y
this.xx := (this.xx = "" || _x + _w > this.xx) ? _x + _w : this.xx
this.yy := (this.yy = "" || _y + _h > this.yy) ? _y + _h : this.yy
return
}
Render(text := "", style1 := "", style2 := "", update := 1){
if (this.hWnd){
Critical On
this.DetectScreenResolutionChange()
this.Draw(text, style1, style2)
if (update)
UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
this.rendered := true
Critical Off
return this
}
else {
parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
Loop, Parse, parent, .
parent := (A_Index=1) ? %A_LoopField% : parent[A_LoopField]
_subtitle := (parent) ? new parent.Subtitle() : new Subtitle()
return _subtitle.Render(text, style1, style2, update)
}
}
Bitmap(x:=0, y:=0, w:=0, h:=0){
pBitmap := Gdip_CreateBitmap(A_ScreenWidth, A_ScreenHeight)
pGraphics := Gdip_GraphicsFromImage(pBitmap)
loop % this.layers.MaxIndex()
this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3, pGraphics)
Gdip_DeleteGraphics(pGraphics)
if (x || y || w || h) {
w := (w = 0) ? A_ScreenWidth, h := (h = 0) ? A_ScreenHeight
pBitmap2 := Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
Gdip_DisposeImage(pBitmap)
pBitmap := pBitmap2
}
return pBitmap
}
Save(filename := "", quality := 92, fullscreen := 0){
filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
: (filename != "") ? filename ".png" : this.name ".png"
pBitmap := (fullscreen) ? this.Bitmap() : this.Bitmap(this.x, this.y, this.xx - this.x, this.yy - this.y)
Gdip_SaveBitmapToFile(pBitmap, filename, quality)
Gdip_DisposeImage(pBitmap)
}
SaveFullScreen(filename := "", quality := ""){
return this.Save(filename, quality, 1)
}
hBitmap(alpha := 0xFFFFFFFF){
pBitmap := this.Bitmap(this.x, this.y, this.xx - this.x, this.yy - this.y)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, alpha)
Gdip_DisposeImage(pBitmap)
return hBitmap
}
RenderToHBitmap(text := "", style1 := "", style2 := ""){
if (this.hWnd){
this.Render(text, style1, style2, 0)
return this.hBitmap()
}
else {
parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
Loop, Parse, parent, .
parent := (A_Index=1) ? %A_LoopField% : parent[A_LoopField]
_subtitle := (parent) ? new parent.Subtitle() : new Subtitle()
_subtitle.Render(text, style1, style2, 0)
return _subtitle.hBitmap()
}
}
hIcon(){
pBitmap := this.Bitmap(this.x, this.y, this.xx - this.x, this.yy - this.y)
hIcon := Gdip_CreateHICONFromBitmap(pBitmap)
Gdip_DisposeImage(pBitmap)
return hIcon
}
color(c, default := 0xDD424242){
static colorRGB  := "^0x([0-9A-Fa-f]{6})$"
static colorARGB := "^0x([0-9A-Fa-f]{8})$"
static hex6      :=   "^([0-9A-Fa-f]{6})$"
static hex8      :=   "^([0-9A-Fa-f]{8})$"
if ObjGetCapacity([c], 1){
c  := (c ~= "^#") ? SubStr(c, 2) : c
c  := ((___ := this.colorMap[c]) != "") ? ___ : c
c  := (c ~= colorRGB) ? "0xFF" RegExReplace(c, colorRGB, "$1") : (c ~= hex8) ? "0x" c : (c ~= hex6) ? "0xFF" c : c
c  := (c ~= colorARGB) ? c : default
}
return (c != "") ? c : default
}
margin(m, default := 0){
static percentage := "^(\-?\d+(?:\.\d*)?)%$"
static positive := "^\d+(\.\d*)?$"
if IsObject(m){
m.1 := (m.y  != "") ? m.y  : m.top
m.2 := (m.x2 != "") ? m.x2 : m.right
m.3 := (m.y2 != "") ? m.y2 : m.bottom
m.4 := (m.x  != "") ? m.x  : m.left
}
else if (m) {
m   := StrSplit(m, " ")
if (m.length() == 3)
m.4 := m.2
else if (m.length() == 2)
m.4 := m.2, m.3 := m.1
else if (m.length() == 1)
m.4 := m.3 := m.2 := m.1, exception := true
else
m.Delete(5, m.MaxIndex())
}
else
return {1:default, 2:default, 3:default, 4:default}
m.1 := (m.1 ~= percentage) ? A_ScreenHeight * SubStr(m.1, 1, -1)  / 100 : m.1
m.2 := (m.2 ~= percentage) ? (exception ? A_ScreenHeight : A_ScreenWidth) * SubStr(m.2, 1, -1)  / 100 : m.2
m.3 := (m.3 ~= percentage) ? A_ScreenHeight * SubStr(m.3, 1, -1)  / 100 : m.3
m.4 := (m.4 ~= percentage) ? (exception ? A_ScreenHeight : A_ScreenWidth) * SubStr(m.4, 1, -1)  / 100 : m.4
m.1 := (m.1 ~= positive) ? m.1 : default
m.2 := (m.2 ~= positive) ? m.2 : default
m.3 := (m.3 ~= positive) ? m.3 : default
m.4 := (m.4 ~= positive) ? m.4 : default
return m
}
outline(o){
static percentage := "^(\-?\d+(?:\.\d*)?)%$"
static positive := "^\d+(\.\d*)?$"
if IsObject(o){
o.1 := (o.w  != "") ? o.w  : o.width
o.2 := (o.c  != "") ? o.c  : o.color
o.3 := (o.g  != "") ? o.g  : o.glow
o.4 := (o.c2 != "") ? o.c2 : o.glowColor
} else if (o)
o   := StrSplit(o, " ")
else
return {"void":true, 1:0, 2:0, 3:0, 4:0}
o.1 := (o.1 ~= "px$") ? SubStr(o.1, 1, -2) : o.1
o.1 := (o.1 ~= percentage) ?  s * RegExReplace(o.1, percentage, "$1")  // 100 : o.1
o.1 := (o.1 ~= positive) ? o.1 : 1
o.2 := this.color(o.2, 0xFF000000)
o.3 := (o.3 ~= "px$") ? SubStr(o.3, 1, -2) : o.3
o.3 := (o.3 ~= percentage) ?  s * RegExReplace(o.3, percentage, "$1")  // 100 : o.3
o.3 := (o.3 ~= positive) ? o.3 : 0
o.4 := this.color(o.4, 0x00000000)
return o
}
dropShadow(d){
static decimal := "^(\-?\d+(\.\d*)?)$"
static percentage := "^(\-?\d+(?:\.\d*)?)%$"
static positive := "^\d+(\.\d*)?$"
if IsObject(d){
d.1 := (d.h != "") ? d.h : d.horizontal
d.2 := (d.v != "") ? d.v : d.vertical
d.3 := (d.b != "") ? d.b : d.blur
d.4 := (d.c != "") ? d.c : d.color
d.5 := (d.s != "") ? d.s : d.strength
} else if (d)
d   := StrSplit(d, " ")
else
return {"void":true, 1:0, 2:0, 3:0, 4:0, 5:0}
d.1 := (d.1 ~= "px$") ? SubStr(d.1, 1, -2) : d.1
d.1 := (d.1 ~= percentage) ? ReturnRC[3] * RegExReplace(d.1, percentage, "$1")  / 100 : d.1
d.1 := (d.1 ~= decimal) ? d.1 : 0
d.2 := (d.2 ~= "px$") ? SubStr(d.2, 1, -2) : d.2
d.2 := (d.2 ~= percentage) ? ReturnRC[4] * RegExReplace(d.2, percentage, "$1")  / 100 : d.2
d.2 := (d.2 ~= decimal) ? d.2 : 0
d.3 := (d.3 ~= "px$") ? SubStr(d.3, 1, -2) : d.3
d.3 := (d.3 ~= percentage) ? s * RegExReplace(d.3, percentage, "$1")  / 100 : d.3
d.3 := (d.3 ~= positive) ? d.3 : 1
d.4 := this.color(d.4, 0xFF000000)
d.5 := (d.5 ~= percentage) ? s * RegExReplace(d.5, percentage, "$1")  / 100 : d.5
d.5 := (d.5 ~= positive) ? d.5 : 1
return d
}
colorMap(){
color := []
color["Clear"] := color["Off"] := color["None"] := color["Transparent"] := "0x00000000"
color["AliceBlue"]             := "0xFFF0F8FF"
, color["AntiqueWhite"]          := "0xFFFAEBD7"
, color["Aqua"]                  := "0xFF00FFFF"
, color["Aquamarine"]            := "0xFF7FFFD4"
, color["Azure"]                 := "0xFFF0FFFF"
, color["Beige"]                 := "0xFFF5F5DC"
, color["Bisque"]                := "0xFFFFE4C4"
, color["Black"]                 := "0xFF000000"
, color["BlanchedAlmond"]        := "0xFFFFEBCD"
, color["Blue"]                  := "0xFF0000FF"
, color["BlueViolet"]            := "0xFF8A2BE2"
, color["Brown"]                 := "0xFFA52A2A"
, color["BurlyWood"]             := "0xFFDEB887"
, color["CadetBlue"]             := "0xFF5F9EA0"
, color["Chartreuse"]            := "0xFF7FFF00"
, color["Chocolate"]             := "0xFFD2691E"
, color["Coral"]                 := "0xFFFF7F50"
, color["CornflowerBlue"]        := "0xFF6495ED"
, color["Cornsilk"]              := "0xFFFFF8DC"
, color["Crimson"]               := "0xFFDC143C"
, color["Cyan"]                  := "0xFF00FFFF"
, color["DarkBlue"]              := "0xFF00008B"
, color["DarkCyan"]              := "0xFF008B8B"
, color["DarkGoldenRod"]         := "0xFFB8860B"
, color["DarkGray"]              := "0xFFA9A9A9"
, color["DarkGrey"]              := "0xFFA9A9A9"
, color["DarkGreen"]             := "0xFF006400"
, color["DarkKhaki"]             := "0xFFBDB76B"
, color["DarkMagenta"]           := "0xFF8B008B"
, color["DarkOliveGreen"]        := "0xFF556B2F"
, color["DarkOrange"]            := "0xFFFF8C00"
, color["DarkOrchid"]            := "0xFF9932CC"
, color["DarkRed"]               := "0xFF8B0000"
, color["DarkSalmon"]            := "0xFFE9967A"
, color["DarkSeaGreen"]          := "0xFF8FBC8F"
, color["DarkSlateBlue"]         := "0xFF483D8B"
, color["DarkSlateGray"]         := "0xFF2F4F4F"
, color["DarkSlateGrey"]         := "0xFF2F4F4F"
, color["DarkTurquoise"]         := "0xFF00CED1"
, color["DarkViolet"]            := "0xFF9400D3"
, color["DeepPink"]              := "0xFFFF1493"
, color["DeepSkyBlue"]           := "0xFF00BFFF"
, color["DimGray"]               := "0xFF696969"
, color["DimGrey"]               := "0xFF696969"
, color["DodgerBlue"]            := "0xFF1E90FF"
, color["FireBrick"]             := "0xFFB22222"
, color["FloralWhite"]           := "0xFFFFFAF0"
, color["ForestGreen"]           := "0xFF228B22"
, color["Fuchsia"]               := "0xFFFF00FF"
, color["Gainsboro"]             := "0xFFDCDCDC"
, color["GhostWhite"]            := "0xFFF8F8FF"
, color["Gold"]                  := "0xFFFFD700"
, color["GoldenRod"]             := "0xFFDAA520"
, color["Gray"]                  := "0xFF808080"
, color["Grey"]                  := "0xFF808080"
, color["Green"]                 := "0xFF008000"
, color["GreenYellow"]           := "0xFFADFF2F"
, color["HoneyDew"]              := "0xFFF0FFF0"
, color["HotPink"]               := "0xFFFF69B4"
, color["IndianRed"]             := "0xFFCD5C5C"
, color["Indigo"]                := "0xFF4B0082"
, color["Ivory"]                 := "0xFFFFFFF0"
, color["Khaki"]                 := "0xFFF0E68C"
, color["Lavender"]              := "0xFFE6E6FA"
, color["LavenderBlush"]         := "0xFFFFF0F5"
, color["LawnGreen"]             := "0xFF7CFC00"
, color["LemonChiffon"]          := "0xFFFFFACD"
, color["LightBlue"]             := "0xFFADD8E6"
, color["LightCoral"]            := "0xFFF08080"
, color["LightCyan"]             := "0xFFE0FFFF"
, color["LightGoldenRodYellow"]  := "0xFFFAFAD2"
, color["LightGray"]             := "0xFFD3D3D3"
, color["LightGrey"]             := "0xFFD3D3D3"
color["LightGreen"]            := "0xFF90EE90"
, color["LightPink"]             := "0xFFFFB6C1"
, color["LightSalmon"]           := "0xFFFFA07A"
, color["LightSeaGreen"]         := "0xFF20B2AA"
, color["LightSkyBlue"]          := "0xFF87CEFA"
, color["LightSlateGray"]        := "0xFF778899"
, color["LightSlateGrey"]        := "0xFF778899"
, color["LightSteelBlue"]        := "0xFFB0C4DE"
, color["LightYellow"]           := "0xFFFFFFE0"
, color["Lime"]                  := "0xFF00FF00"
, color["LimeGreen"]             := "0xFF32CD32"
, color["Linen"]                 := "0xFFFAF0E6"
, color["Magenta"]               := "0xFFFF00FF"
, color["Maroon"]                := "0xFF800000"
, color["MediumAquaMarine"]      := "0xFF66CDAA"
, color["MediumBlue"]            := "0xFF0000CD"
, color["MediumOrchid"]          := "0xFFBA55D3"
, color["MediumPurple"]          := "0xFF9370DB"
, color["MediumSeaGreen"]        := "0xFF3CB371"
, color["MediumSlateBlue"]       := "0xFF7B68EE"
, color["MediumSpringGreen"]     := "0xFF00FA9A"
, color["MediumTurquoise"]       := "0xFF48D1CC"
, color["MediumVioletRed"]       := "0xFFC71585"
, color["MidnightBlue"]          := "0xFF191970"
, color["MintCream"]             := "0xFFF5FFFA"
, color["MistyRose"]             := "0xFFFFE4E1"
, color["Moccasin"]              := "0xFFFFE4B5"
, color["NavajoWhite"]           := "0xFFFFDEAD"
, color["Navy"]                  := "0xFF000080"
, color["OldLace"]               := "0xFFFDF5E6"
, color["Olive"]                 := "0xFF808000"
, color["OliveDrab"]             := "0xFF6B8E23"
, color["Orange"]                := "0xFFFFA500"
, color["OrangeRed"]             := "0xFFFF4500"
, color["Orchid"]                := "0xFFDA70D6"
, color["PaleGoldenRod"]         := "0xFFEEE8AA"
, color["PaleGreen"]             := "0xFF98FB98"
, color["PaleTurquoise"]         := "0xFFAFEEEE"
, color["PaleVioletRed"]         := "0xFFDB7093"
, color["PapayaWhip"]            := "0xFFFFEFD5"
, color["PeachPuff"]             := "0xFFFFDAB9"
, color["Peru"]                  := "0xFFCD853F"
, color["Pink"]                  := "0xFFFFC0CB"
, color["Plum"]                  := "0xFFDDA0DD"
, color["PowderBlue"]            := "0xFFB0E0E6"
, color["Purple"]                := "0xFF800080"
, color["RebeccaPurple"]         := "0xFF663399"
, color["Red"]                   := "0xFFFF0000"
, color["RosyBrown"]             := "0xFFBC8F8F"
, color["RoyalBlue"]             := "0xFF4169E1"
, color["SaddleBrown"]           := "0xFF8B4513"
, color["Salmon"]                := "0xFFFA8072"
, color["SandyBrown"]            := "0xFFF4A460"
, color["SeaGreen"]              := "0xFF2E8B57"
, color["SeaShell"]              := "0xFFFFF5EE"
, color["Sienna"]                := "0xFFA0522D"
, color["Silver"]                := "0xFFC0C0C0"
, color["SkyBlue"]               := "0xFF87CEEB"
, color["SlateBlue"]             := "0xFF6A5ACD"
, color["SlateGray"]             := "0xFF708090"
, color["SlateGrey"]             := "0xFF708090"
, color["Snow"]                  := "0xFFFFFAFA"
, color["SpringGreen"]           := "0xFF00FF7F"
, color["SteelBlue"]             := "0xFF4682B4"
, color["Tan"]                   := "0xFFD2B48C"
, color["Teal"]                  := "0xFF008080"
, color["Thistle"]               := "0xFFD8BFD8"
, color["Tomato"]                := "0xFFFF6347"
, color["Turquoise"]             := "0xFF40E0D0"
, color["Violet"]                := "0xFFEE82EE"
, color["Wheat"]                 := "0xFFF5DEB3"
, color["White"]                 := "0xFFFFFFFF"
, color["WhiteSmoke"]            := "0xFFF5F5F5"
color["Yellow"]                := "0xFFFFFF00"
, color["YellowGreen"]           := "0xFF9ACD32"
return color
}
x1(){
return this.x
}
y1(){
return this.y
}
x2(){
return this.xx
}
y2(){
return this.yy
}
width(){
return this.xx - this.x
}
height(){
return this.yy - this.y
}
}
}
class provider {
class GoogleCloudVision {
static ext := "jpg"
static jpegQuality := "75"
base64 := true
static api_key := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
getCredentials(error:=""){
if (error != "") {
(Vis2.obj) ? Vis2.core.ux.suspend() : ""
InputBox, api_key, Vis2.GoogleCloudVision.ImageIdentify, Enter your api_key for GoogleCloudVision.
(Vis2.obj) ? Vis2.core.ux.resume() : ""
FileAppend, GoogleCloudVision=%api_key%, Vis2_API.txt
return api_key
}
if (this.api_key ~= "^X{39}$") {
if FileExist("Vis2_API.txt") {
file := FileOpen("Vis2_API.txt", "r")
keys := file.Read()
api_key := ((___ := RegExReplace(keys, "s)^.*?GoogleCloudVision(?:\s*)=(?:\s*)([A-Za-z0-9\-]+).*$", "$1")) != keys) ? ___ : ""
file.close()
if (api_key != "")
return api_key
}
}
else
return this.api_key
}
ImageIdentify(image, search:="", options:=""){
base64 := Vis2.stdlib.toBase64(image, "png", this.jpegQuality, options)
reply := this.convert(base64)
return this.getText()
}
convert(in:=""){
in := (in) ? in : this.base64
req := {}
req.requests := {}
req.requests[1] := {"image":{}, "features":{}}
req.requests[1].image.content := in
req.requests[1].features[1] := {"type":"LABEL_DETECTION"}
body := JSON.Dump(req)
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
if (api_key := this.getCredentials())
whr.Open("POST", "https://vision.googleapis.com/v1/images:annotate?key=" api_key, true)
else
whr.Open("POST", "https://cxl-services.appspot.com/proxy?url=https%3A%2F%2Fvision.googleapis.com%2Fv1%2Fimages%3Aannotate", true)
whr.SetRequestHeader("Accept", "*/*")
whr.SetRequestHeader("Origin", "https://cloud.google.com")
whr.SetRequestHeader("Content-Type", "text/plain;charset=UTF-8")
whr.SetRequestHeader("Referer", "https://cloud.google.com/vision/")
whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36")
whr.Send(body)
whr.WaitForResponse()
try reply := JSON.Load(whr.ResponseText)
catch
this.getCredentials(whr.ResponseText)
i := 1
while (i <= reply.responses[1].labelAnnotations.length()) {
sentence  .= (i == 1) ? "" : ", "
sentence2 .= (i == 1) ? "" : ", "
sentence  .= reply.responses[1].labelAnnotations[i].description
sentence2 .= reply.responses[1].labelAnnotations[i].description " (" Format("{:i}",  100*reply.responses[1].labelAnnotations[i].score) "%)"
i++
}
this.text := sentence2
return reply
}
getText(){
return this.text
}
}
class Tesseract {
static leptonica := A_ScriptDir "\bin\leptonica_util\leptonica_util.exe"
static tesseract := A_ScriptDir "\bin\tesseract\tesseract.exe"
static tessdata_best := A_ScriptDir "\bin\tesseract\tessdata_best"
static tessdata_fast := A_ScriptDir "\bin\tesseract\tessdata_fast"
uuid := Vis2.stdlib.CreateUUID()
file := A_Temp "\Vis2_screenshot" this.uuid ".bmp"
fileProcessedImage := A_Temp "\Vis2_preprocess" this.uuid ".tif"
fileConvertedText := A_Temp "\Vis2_text" this.uuid ".txt"
__New(language:=""){
this.language := language
}
OCR(image, language:="", options:=""){
this.language := language
try {
screenshot := Vis2.stdlib.toFile(image, this.file, options)
this.preprocess(screenshot, this.fileProcessedImage)
this.convert_best(this.fileProcessedImage, this.fileConvertedText)
text := this.getText(this.fileConvertedText)
} catch e {
}
finally {
this.cleanup()
text.base.google := ObjBindMethod(Vis2.Text, "google")
text.base.clipboard := ObjBindMethod(Vis2.Text, "clipboard")
}
return text
}
cleanup(){
FileDelete, % this.file
FileDelete, % this.fileProcessedImage
FileDelete, % this.fileConvertedText
}
convert(in:="", out:="", fast:=1){
in := (in) ? in : this.fileProcessedImage
out := (out) ? out : this.fileConvertedText
fast := (fast) ? this.tessdata_fast : this.tessdata_best
if !(FileExist(in))
throw Exception("Input image for conversion not found.",, in)
if !(FileExist(this.tesseract))
throw Exception("Tesseract not found",, this.tesseract)
static q := Chr(0x22)
_cmd .= q this.tesseract q " --tessdata-dir " q fast q " " q in q " " q SubStr(out, 1, -4) q
_cmd .= (this.language) ? " -l " q this.language q : ""
_cmd := ComSpec " /C " q _cmd q
RunWait % _cmd,, Hide
if !(FileExist(out))
throw Exception("Tesseract failed.",, _cmd)
return out
}
convert_best(in:="", out:=""){
return this.convert(in, out, 0)
}
convert_fast(in:="", out:=""){
return this.convert(in, out, 1)
}
getPreprocessImage(){
return this.fileProcessedImage
}
getText(in:="", lines:=""){
in := (in) ? in : this.fileConvertedText
if !(database := FileOpen(in, "r`n", "UTF-8"))
throw Exception("Text file could not be found or opened.",, in)
if (lines == "") {
text := RegExReplace(database.Read(), "^\s*(.*?)\s*$", "$1")
text := RegExReplace(text, "(?<!\r)\n", "`r`n")
} else {
while (lines > 0) {
data := database.ReadLine()
data := RegExReplace(data, "^\s*(.*?)\s*$", "$1")
if (data != "") {
text .= (text) ? ("`n" . data) : data
lines--
}
if (!database || database.AtEOF)
break
}
}
database.Close()
return text
}
getTextLines(lines){
return this.read(, lines)
}
preprocess(in:="", out:=""){
static ocrPreProcessing := 1
static negateArg := 2
static performScaleArg := 1
static scaleFactor := 3.5
in := (in != "") ? in : this.file
out := (out != "") ? out : this.fileProcessedImage
if !(FileExist(in))
throw Exception("Input image for preprocessing not found.",, in)
if !(FileExist(this.leptonica))
throw Exception("Leptonica not found",, this.leptonica)
static q := Chr(0x22)
_cmd .= q this.leptonica q " " q in q " " q out q
_cmd .= " " negateArg " 0.5 " performScaleArg " " scaleFactor " " ocrPreProcessing " 5 2.5 " ocrPreProcessing  " 2000 2000 0 0 0.0"
_cmd := ComSpec " /C " q _cmd q
RunWait, % _cmd,, Hide
if !(FileExist(out))
throw Exception("Preprocessing failed.",, _cmd)
return out
}
}
}
class stdlib {
isBinaryImageFormat(data){
Loop 12
bytes .= Chr(NumGet(data, A_Index-1, "uchar"))
if (bytes ~= "^BM")
return "bmp"
if (bytes ~= "^(GIF87a|GIF89a)")
return "gif"
if (bytes ~= "^Ã¿Ã˜Ã¿Ã›")
return "jpg"
if (bytes ~= "s)^Ã¿Ã˜Ã¿Ã ..\x4A\x46\x49\x46")
return "jfif"
if (bytes ~= "^\x89\x50\x4E\x47\x0D\x0A\x1A\x0A")
return "png"
if (bytes ~= "^(\x49\x49\x2A|\x4D\x4D\x2A)")
return "tif"
return
}
isURL(url){
regex .= "((https?|ftp)\:\/\/)"
regex .= "([a-z0-9+!*(),;?&=\$_.-]+(\:[a-z0-9+!*(),;?&=\$_.-]+)?@)?"
regex .= "([a-z0-9-.]*)\.([a-z]{2,3})"
regex .= "(\:[0-9]{2,5})?"
regex .= "(\/([a-z0-9+\$_-]\.?)+)*\/?"
regex .= "(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?"
regex .= "(#[a-z_.-][a-z0-9+\$_.-]*)?"
return (url ~= "i)" regex) ? true : false
}
b64Encode( ByRef buf, bufLen:="" ) {
bufLen := (bufLen) ? bufLen : StrLen(buf) << !!A_IsUnicode
DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", 0, "UInt*", outLen )
VarSetCapacity( outBuf, outLen, 0 )
DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", &outBuf, "UInt*", outLen )
return strget( &outBuf, outLen, "CP0" )
}
b64Decode( b64str, ByRef outBuf ) {
static CryptStringToBinary := "crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A")
DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", 0, "UInt*", outLen, "ptr", 0, "ptr", 0 )
VarSetCapacity( outBuf, outLen, 0 )
DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", &outBuf, "UInt*", outLen, "ptr", 0, "ptr", 0 )
return outLen
}
CreateUUID() {
VarSetCapacity(puuid, 16, 0)
if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
return StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
return ""
}
Gdip_EncodeBitmapTo64string(pBitmap, ext, Quality=75) {
if Ext not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
return -1
Extension := "." Ext
DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
VarSetCapacity(ci, nSize)
DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
if !(nCount && nSize)
return -2
Loop, %nCount%
{
sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
if !InStr(sString, "*" Extension)
continue
pCodec := &ci+idx
break
}
if !pCodec
return -3
if (Quality != 75)
{
Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
if Extension in .JPG,.JPEG,.JPE,.JFIF
{
DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
VarSetCapacity(EncoderParameters, nSize, 0)
DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
Loop, % NumGet(EncoderParameters, "UInt")
{
elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
{
p := elem+&EncoderParameters-pad-4
NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
break
}
}
}
}
DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint",p ? p : 0)
DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
pData := DllCall("GlobalLock", "ptr",hData, "uptr")
nSize := DllCall("GlobalSize", "uint",pData)
VarSetCapacity(Bin, nSize, 0)
DllCall("RtlMoveMemory", "ptr",&Bin , "ptr",pData , "uint",nSize)
DllCall("GlobalUnlock", "ptr",hData)
DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
DllCall("GlobalFree", "ptr",hData)
DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",0, "uint*",base64Length)
VarSetCapacity(base64, base64Length*2, 0)
DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",&base64, "uint*",base64Length)
Bin := ""
VarSetCapacity(Bin, 0)
VarSetCapacity(base64, -1)
return base64
}
Gdip_BitmapFromClientHWND(hwnd) {
VarSetCapacity(rc, 16)
DllCall("GetClientRect", "ptr", hwnd, "ptr", &rc)
hbm := CreateDIBSection(NumGet(rc, 8, "int"), NumGet(rc, 12, "int"))
VarSetCapacity(rc, 0)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
PrintWindow(hwnd, hdc, 1)
pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
return pBitmap
}
Gdip_CropBitmap(ByRef pBitmap, c, preserveOriginal:=false){
w := Gdip_GetImageWidth(pBitmap), h := Gdip_GetImageHeight(pBitmap)
pBitmap2 := Gdip_CloneBitmapArea(pBitmap, c.1, c.2, (c.1 + c.3 > w) ? w - c.1 : c.3 , (c.2 + c.4 > h) ? h - c.2 : c.4)
(preserveOriginal) ? "" : Gdip_DisposeImage(pBitmap)
pBitmap := pBitmap2
}
Gdip_isBitmapEqual(pBitmap1, pBitmap2, width:="", height:="") {
if (pBitmap1 == pBitmap2)
return true
width := (width) ? width : Gdip_GetImageWidth(pBitmap1)
height := (height) ? height : Gdip_GetImageHeight(pBitmap1)
E1 := Gdip_LockBits(pBitmap1, 0, 0, width, height, Stride1, Scan01, BitmapData1)
E2 := Gdip_LockBits(pBitmap2, 0, 0, width, height, Stride2, Scan02, BitmapData2)
length := width * height * 4
bytes := DllCall("RtlCompareMemory", "ptr", Scan01+0, "ptr", Scan02+0, "uint", length)
Gdip_UnlockBits(pBitmap1, BitmapData1)
Gdip_UnlockBits(pBitmap2, BitmapData2)
return (bytes == length) ? true : false
}
RPath_Absolute(AbsolutPath, RelativePath, s="\") {
len := InStr(AbsolutPath, s, "", InStr(AbsolutPath, s . s) + 2) - 1
pr := SubStr(AbsolutPath, 1, len)
AbsolutPath := SubStr(AbsolutPath, len + 1)
If InStr(AbsolutPath, s, "", 0) = StrLen(AbsolutPath)
StringTrimRight, AbsolutPath, AbsolutPath, 1
If InStr(RelativePath, s) = 1
AbsolutPath := "", RelativePath := SubStr(RelativePath, 2)
Else If InStr(RelativePath,"." s) = 1
RelativePath := SubStr(RelativePath, 3)
Else If InStr(RelativePath,".." s) = 1 {
StringReplace, RelativePath, RelativePath, ..%s%, , UseErrorLevel
Loop, %ErrorLevel%
AbsolutPath := SubStr(AbsolutPath, 1, InStr(AbsolutPath, s, "", 0) - 1)
} Else
pr := "", AbsolutPath := "", s := ""
Return, pr . AbsolutPath . s . RelativePath
}
setSystemCursor(CursorID = "", cx = 0, cy = 0 ) {
static SystemCursors := "32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651"
Loop, Parse, SystemCursors, `,
{
Type := "SystemCursor"
CursorHandle := DllCall( "LoadCursor", "uInt",0, "Int",CursorID )
%Type%%A_Index% := DllCall( "CopyImage", "uInt",CursorHandle, "uInt",0x2, "Int",cx, "Int",cy, "uInt",0 )
CursorHandle := DllCall( "CopyImage", "uInt",%Type%%A_Index%, "uInt",0x2, "Int",0, "Int",0, "Int",0 )
DllCall( "SetSystemCursor", "uInt",CursorHandle, "Int",A_Loopfield)
}
}
toBase64(image, extension:="png", quality:="", crop:="", crop2:=""){
Vis2.Graphics.Startup()
if (image.1 ~= "^\d+$" && image.2 ~= "^\d+$" && image.3 ~= "^\d+$" && image.4 ~= "^\d+$") {
pBitmap := Gdip_BitmapFromScreen(image.1 "|" image.2 "|" image.3 "|" image.4)
base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
Gdip_DisposeImage(pBitmap)
}
else if FileExist(image) {
if !(crop) {
file := FileOpen(image, "r")
file.RawRead(data, file.length)
base64 := Vis2.stdlib.b64Encode(data, file.length)
file.Close()
} else {
pBitmap := Gdip_CreateBitmapFromFile(image)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
Gdip_DisposeImage(pBitmap)
}
}
else if Vis2.stdlib.isURL(image) {
static req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
req.Open("GET",image)
req.Send()
pStream := ComObjQuery(req.ResponseStream, "{0000000C-0000-0000-C000-000000000046}")
if !(crop) {
DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
pData := DllCall("GlobalLock", "ptr",hData, "uptr")
nSize := DllCall("GlobalSize", "uint",pData)
VarSetCapacity(Bin, nSize, 0)
DllCall("RtlMoveMemory", "ptr",&Bin , "ptr",pData , "uint",nSize)
DllCall("GlobalUnlock", "ptr",hData)
DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
DllCall("GlobalFree", "ptr",hData)
DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",0, "uint*",base64Length)
VarSetCapacity(base64, base64Length*2, 0)
DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",&base64, "uint*",base64Length)
Bin := ""
VarSetCapacity(Bin, 0)
VarSetCapacity(base64, -1)
} else {
DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
ObjRelease(pStream)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
Gdip_DisposeImage(pBitmap)
}
}
else if (DllCall("IsWindow", "ptr",image) || (hwnd := WinExist(image))) {
hwnd := (DllCall("IsWindow", "ptr",image)) ? image : hwnd
pBitmap := Vis2.stdlib.Gdip_BitmapFromClientHWND(hwnd)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
Gdip_DisposeImage(pBitmap)
}
else if DeleteObject(Gdip_CreateHBITMAPFromBitmap(image)) {
(crop) ? Vis2.stdlib.Gdip_CropBitmap(image, crop, true) : ""
base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(image, extension, quality)
(crop) ? Gdip_DisposeImage(image) : ""
}
else if (DllCall("GetObjectType", "ptr",image) == 7) {
pBitmap := Gdip_CreateBitmapFromHBITMAP(image)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
Gdip_DisposeImage(pBitmap)
}
else if (image ~= "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") {
base64 := image
}
Vis2.Graphics.Shutdown()
return base64
}
toFile(image, outputFile:="", crop:=""){
Vis2.Graphics.Startup()
if (image.1 ~= "^\d+$" && image.2 ~= "^\d+$" && image.3 ~= "^\d+$" && image.4 ~= "^\d+$") {
pBitmap := Gdip_BitmapFromScreen(image.1 "|" image.2 "|" image.3 "|" image.4)
Gdip_SaveBitmapToFile(pBitmap, outputFile)
Gdip_DisposeImage(pBitmap)
}
else if FileExist(image) {
Loop, Files, % image
{
if (A_LoopFileExt != "bmp" || IsObject(crop)) {
pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileLongPath)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
Gdip_SaveBitmapToFile(pBitmap, outputFile)
Gdip_DisposeImage(pBitmap)
}
else outputFile := A_LoopFileLongPath
}
}
else if Vis2.stdlib.isURL(image) {
static req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
req.Open("GET",image)
req.Send()
pStream := ComObjQuery(req.ResponseStream, "{0000000C-0000-0000-C000-000000000046}")
DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
Gdip_SaveBitmapToFile(pBitmap, outputFile, 92)
ObjRelease(pStream)
Gdip_DisposeImage(pBitmap)
}
else if (DllCall("IsWindow", "ptr",image) || (hwnd := WinExist(image))) {
hwnd := (DllCall("IsWindow", "ptr",image)) ? image : hwnd
pBitmap := Vis2.stdlib.Gdip_BitmapFromClientHWND(hwnd)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
Gdip_SaveBitmapToFile(pBitmap, outputFile)
Gdip_DisposeImage(pBitmap)
}
else if DeleteObject(Gdip_CreateHBITMAPFromBitmap(image)) {
(crop) ? Vis2.stdlib.Gdip_CropBitmap(image, crop, true) : ""
Gdip_SaveBitmapToFile(image, outputFile)
}
else if (DllCall("GetObjectType", "ptr",image) == 7) {
pBitmap := Gdip_CreateBitmapFromHBITMAP(image)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
Gdip_SaveBitmapToFile(pBitmap, outputFile)
Gdip_DisposeImage(pBitmap)
}
else if (image ~= "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") {
nSize := Vis2.stdlib.b64Decode(image, bin)
hData := DllCall("GlobalAlloc", "uint",0x2, "ptr",nSize)
pData := DllCall("GlobalLock", "ptr",hData)
DllCall("RtlMoveMemory", "ptr",pData, "ptr",&bin, "ptr",nSize)
DllCall("GlobalUnlock", "ptr",hData)
DllCall("ole32\CreateStreamOnHGlobal", "ptr",hData, "int",1, "uptr*",pStream)
DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
(crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
Gdip_SaveBitmapToFile(pBitmap, outputFile, 92)
DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
DllCall("GlobalFree", "ptr",hData)
ObjRelease(pStream)
Gdip_DisposeImage(pBitmap)
}
if !(FileExist(outputFile))
throw Exception("Could not find source image.")
Vis2.Graphics.Shutdown()
return outputFile
}
}
class Text {
copy() {
AutoTrim Off
c := ClipboardAll
Clipboard := ""
Send, ^c
ClipWait 0.5
if ErrorLevel
return
t := Clipboard
Clipboard := c
VarSetCapacity(c, 0)
return t
}
paste(t) {
c := ClipboardAll
Clipboard := t
Send, ^v
Sleep 50
Clipboard := c
VarSetCapacity(c, 0)
AutoTrim On
}
restore() {
AutoTrim On
}
rmgarbage(data := ""){
text := (data == "") ? Vis2.Text.copy() : data
strings := [], whitespaces := [], pos := 1
while RegexMatch(text, "O)([^\s]+)", string, pos) {
strings.push(string.value())
pos := string.pos() + string.len()
RegexMatch(text, "O)([\s]+)", whitespace, pos)
whitespaces.push(whitespace.value)
}
for i in strings {
alnum_thresholds := {1: 0
,2: 0
,3: 0.32
,4: 0.24
,5: 0.39}
strings[i] := (StrLen(RegExReplace(strings[i], "\W")) / StrLen(strings[i]) < 0.5) ? "" : strings[i]
}
text := ""
for i, string in strings {
text .= string . whitespaces[i]
}
return (data == "") ? Vis2.Text.paste(text) : text
}
clipboard(data := ""){
text := (data == "") ? Vis2.Text.copy() : data
clipboard := text
return (data == "") ? Vis2.Text.restore() : text
}
google(data := "") {
text := data
if not RegExMatch(text, "^(http|ftp|telnet)")
text := "https://www.google.com/search?&q=" . RegExReplace(text, "\s", "+")
if (data)
Run % text
return data
}
}
}
GoogleTranslate(str, from := "auto", to := "en")  {
static JS := CreateScriptObj(), _ := JS.( GetJScript() ) := JS.("delete ActiveXObject; delete GetObject;")
json := SendRequest(JS, str, to, from, proxy := "")
oJSON := JS.("(" . json . ")")
if !IsObject(oJSON[1])  {
Loop % oJSON[0].length
trans .= oJSON[0][A_Index - 1][0]
}
else  {
MainTransText := oJSON[0][0][0]
Loop % oJSON[1].length  {
trans .= "`n+"
obj := oJSON[1][A_Index-1][1]
Loop % obj.length  {
txt := obj[A_Index - 1]
trans .= (MainTransText = txt ? "" : "`n" txt)
}
}
}
if !IsObject(oJSON[1])
MainTransText := trans := Trim(trans, ",+`n ")
else
trans := MainTransText . "`n+`n" . Trim(trans, ",+`n ")
from := oJSON[2]
trans := Trim(trans, ",+`n ")
Return trans
}
SendRequest(JS, str, tl, sl, proxy) {
static http
ComObjError(false)
if !http
{
http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
( proxy && http.SetProxy(2, proxy) )
http.open( "get", "https://translate.google.com", 1 )
http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
http.send()
http.WaitForResponse(-1)
}
http.open( "POST", "https://translate.google.com/translate_a/single?client=webapp&sl="
. sl . "&tl=" . tl . "&hl=" . tl
. "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=0&ssel=0&tsel=0&pc=1&kc=1"
. "&tk=" . JS.("tk").(str), 1 )
http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
http.send("q=" . URIEncode(str))
http.WaitForResponse(-1)
Return http.responsetext
}
URIEncode(str, encoding := "UTF-8")  {
VarSetCapacity(var, StrPut(str, encoding))
StrPut(str, &var, encoding)
While code := NumGet(Var, A_Index - 1, "UChar")  {
bool := (code > 0x7F || code < 0x30 || code = 0x3D)
UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
}
Return UrlStr
}
GetJScript()
{
script =
   (
      var TKK = ((function() {
        var a = 561666268;
        var b = 1526272306;
        return 406398 + '.' + (a + b);
      })());

      function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
            var c = b.charAt(d + 2),
                c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
                c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
            a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
      }

      function tk(a) {
          for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
              var c = a.charCodeAt(f);
              128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
              (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
              g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
          }
          a = h;
          for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
          a = b(a, "+-3^+b+-f");
          a ^= Number(e[1]) || 0;
          0 > a && (a = (a & 2147483647) + 2147483648);
          a `%= 1E6;
          return a.toString() + "." + (a ^ h)
      }
)
Return script
}
CreateScriptObj() {
static doc
doc := ComObjCreate("htmlfile")
doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
Return ObjBindMethod(doc.parentWindow, "eval")
}
IniRead, translate_line_hotkey, config.ini, Hotkeys, translate_line_hotkey
IniRead, translate_my_text_hotkey, config.ini, Hotkeys, translate_my_text_hotkey
IniRead, reload_script_hotkey, config.ini, Hotkeys, reload_script_hotkey
IniRead, chat_language, config.ini, Language, chat_language
IniRead, tooltip_language, config.ini, Language, tooltip_language
IniRead, chat_width, config.ini, Other, chat_width
IniRead, tooltip_show_time, config.ini, Other, tooltip_show_time
IniRead, send_enter, config.ini, Other, send_enter
IniRead, alternative_tooltip, config.ini, Other, alternative_tooltip
Hotkey, %translate_my_text_hotkey%, translate_my_text
Hotkey, %translate_line_hotkey%, translate_line
Hotkey, %reload_script_hotkey%, reload_script
Return
reload_script:
Reload
return
hide_tooltip:
ToolTip
return
translate_line:
{
WinActivate, Discord
WinWaitActive, Discord
mousegetpos, start_x, start_y
ocr_lang := eng
if (tooltip_language = "en")
ocr_lang := spa
if (chat_width > 700)
chat_width := 700
try
{
newline := Vis2.OCR([start_x, start_y-6, chat_width, 15], ocr_lang)
} catch e
{
Reload
}
translated := GoogleTranslate(newline, , tooltip_language)
t := StrSplit(translated , "`n")
translated := t[1]
if (translated = "")
Reload
tooltip_y := start_y-30
if (tooltip_show_time > 10000)
tooltip_show_time := 10000
if (tooltip_show_time > 1)
{
tooltip_show_time := -1 * tooltip_show_time
SetTimer, hide_tooltip, %tooltip_show_time%
}
if (alternative_tooltip = "true")
alt_tooltip := Vis2.Graphics.Subtitle.Render(translated, {"t":tooltip_show_time, "x":start_x, "y":tooltip_y, "r":"8", "c":"88B6DB", "p":"0.35%"}, {"s":"1.23%", "c":"Black"})
else
ToolTip, %translated%, %start_x%, %tooltip_y%
return
}
translate_my_text:
{
WinActivate, Discord
WinWaitActive, Discord
WinGetPos, winX, winY, Width, Height, Discord
chat_icon_search_up := Height-200
chat_icon_search_down := Height-20
try {
ImageSearch, X, Y, 5, %chat_icon_search_up%, %chat_width%, %chat_icon_search_down%, *1, lib\img\gift.png
} catch e
{
}
try {
ImageSearch, X, Y, 5, %chat_icon_search_up%, 30, %chat_icon_search_down%, *1, lib\img\plus.png
} catch e
{
Reload
}
if (chat_width > 700)
chat_width := 700
Send, {SPACE 2}
try
{
newline := Vis2.OCR([winX+X+10, winY+Y+5, chat_width, 15])
} catch e
{
Reload
}
clearline := StrReplace(newline, "|", "")
clearline := StrReplace(clearline, "]", "")
translated := GoogleTranslate(clearline, ,chat_language)
t := StrSplit(translated , "`n")
translated := t[1]
if (translated = "")
Reload
Send, {BACKSPACE 300}
Send, %translated%
if (send_enter = "true" and translated != "Error.")
Send, {ENTER}
return
}
~LButton::
{
alt_tooltip.Destroy()
MouseGetPos,,, winID
if (winID = WinExist("ahk_class tooltips_class32"))
ToolTip
return
}
~RButton::
{
alt_tooltip.Destroy()
MouseGetPos,,, winID
if (winID = WinExist("ahk_class tooltips_class32"))
ToolTip
return
}
~MButton::
{
alt_tooltip.Destroy()
MouseGetPos,,, winID
if (winID = WinExist("ahk_class tooltips_class32"))
ToolTip
return
}