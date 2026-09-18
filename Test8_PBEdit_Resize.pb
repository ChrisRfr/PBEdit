XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

; *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST 

Procedure UndoImage(angle)
  Protected i = CreateImage(#PB_Any, 24, 24, 32, #PB_Image_Transparent)
  If IsImage(i)
    If StartVectorDrawing(ImageVectorOutput(i))
      RotateCoordinates(12,12,angle)
      AddPathSegments("M 2 10 L 12 10 L 12 7 L 23 12 L 12 17 L 12 14 L 2 14 Z")
      VectorSourceColor(RGBA(16,16,16,255))
      FillPath()
      StopVectorDrawing()
    EndIf
  EndIf
  ProcedureReturn i
EndProcedure

Enumeration 1
  #tlb_undo
  #tlb_redo
  #panel
EndEnumeration

OpenWindow(0, 0, 0, 800, 600, AppTitle$, #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)

CreateToolBar(0, WindowID(0), #PB_ToolBar_Large)
ToolBarImageButton(#tlb_undo, ImageID(UndoImage(180)))
ToolBarImageButton(#tlb_redo, ImageID(UndoImage(0)))
CreateStatusBar(0, WindowID(0))
AddStatusBarField(#PB_Ignore)
AddStatusBarField(#PB_Ignore)
AddStatusBarField(#PB_Ignore)
AddStatusBarField(#PB_Ignore)
WindowBounds(0, 100, 100, #PB_Ignore, #PB_Ignore)

PanelGadget(#panel, 5, ToolBarHeight(0)+5, WindowWidth(0) - 10, WindowHeight(0) - ToolBarHeight(0) - StatusBarHeight(0) - 10)
AddGadgetItem (#panel, -1, "Tab1")
Global editor = PBEdit_Gadget(0,0,0,GetGadgetAttribute(#panel, #PB_Panel_ItemWidth),GetGadgetAttribute(#panel, #PB_Panel_ItemHeight))
CloseGadgetList()

If PBEdit_IsGadget(editor) = 0
  MessageRequester("", "Failed to create PBEdit Gadget", #PB_MessageRequester_Error)
  End
EndIf

PBEdit_LoadSettings(editor, #PB_Compiler_FilePath + "styles\PBEdit_PureBasic.settings")
PBEdit_LoadStyle(editor, #PB_Compiler_FilePath + "styles\PBEdit_PureBasic.style")

; 	PBEdit_SetFlag(editor, _PBEdit_::#TE_EnableDictionary, 0)

If ReadFile(0, #PB_Compiler_Filename, #PB_File_SharedRead)
  PBEdit_SetFlag(editor, _PBEdit_::#TE_EnableShowModifiedLines, 0)
  PBEdit_SetText(editor, ReadString(0, #PB_File_IgnoreEOL))
  PBEdit_SetFlag(editor, _PBEdit_::#TE_EnableShowModifiedLines, 1)
  CloseFile(0)
  
EndIf


Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      If EventWindow() = PBEdit_GetWindow(editor)
        PBEdit_FreeGadget(editor)
        End
      EndIf
    Case #PB_Event_ActivateWindow
      If EventWindow() = PBEdit_GetWindow(editor)
        PBEdit_Activate(editor)
      EndIf

    Case #PB_Event_SizeWindow
      If EventWindow() = PBEdit_GetWindow(editor)
        ResizeGadget(#panel, #PB_Ignore, #PB_Ignore ,WindowWidth(0) - 10, WindowHeight(0) - ToolBarHeight(0) - StatusBarHeight(0) - 10)
        Debug "resize(Ignore,Ignore," + GetGadgetAttribute(#panel, #PB_Panel_ItemWidth) + "," +GetGadgetAttribute(#panel, #PB_Panel_ItemHeight) + ")"
        PBEdit_Resize(editor, #PB_Ignore, #PB_Ignore, GetGadgetAttribute(#panel, #PB_Panel_ItemWidth),GetGadgetAttribute(#panel, #PB_Panel_ItemHeight))
      EndIf
    Case #PB_Event_Menu
      If EventMenu() = #tlb_undo
        PBEdit_Undo(editor)
      ElseIf EventMenu() = #tlb_redo
        PBEdit_Redo(editor)
      EndIf
      ; --- custom events ---
    Case _PBEdit_::#TE_Event_Cursor
      If EventType() = _PBEdit_::#TE_EventType_Change
        StatusBarText(0, 0, "Line: " + Str(PBEdit_GetCursorLineNr(editor)) + 
                            "  Column: " + Str(PBEdit_GetCursorColumnNr(editor)) + 
                            "  (Char: " + Str(PBEdit_GetCursorCharNr(editor)) + ")")
        
      ElseIf EventType() = _PBEdit_::#TE_EventType_Add Or EventType() = _PBEdit_::#TE_EventType_Remove
        StatusBarText(0, 2, "Cursors: " + Str(PBEdit_GetCursorCount(editor)))
      EndIf
    Case _PBEdit_::#TE_Event_Selection
      If EventType() = _PBEdit_::#TE_EventType_Change
        StatusBarText(0, 1, "Selection [" + 
                            Str(Abs(PBEdit_GetSelectionLineNr(editor) - PBEdit_GetCursorLineNr(editor)) + 1) + ", " +
                            Str(PBEdit_GetSelectionCharCount(editor)) + "]")
      ElseIf EventType() = _PBEdit_::#TE_EventType_Remove
        StatusBarText(0, 1, "")
      EndIf
  EndSelect
ForEver

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger