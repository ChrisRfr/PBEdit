XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

OpenWindow(0, 0, 0, 800, 600, AppTitle$, #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_Maximize)

Global editor = PBEdit_Gadget(0, 10, 10, WindowWidth(0) - 10, WindowHeight(0) - 10)
If PBEdit_IsGadget(editor) = 0
  MessageRequester("", "Failed to create PBEdit Gadget", #PB_MessageRequester_Error)
  End
EndIf

PBEdit_LoadSettings(editor, #PB_Compiler_FilePath + "styles\PBEdit_PureBasic.settings")
PBEdit_LoadStyle(editor, #PB_Compiler_FilePath + "styles\PBEdit_PureBasic.style")

If ReadFile(0, #PB_Compiler_Filename, #PB_File_SharedRead)
  PBEdit_SetFlag(editor, _PBEdit_::#TE_EnableShowModifiedLines, #False)
  PBEdit_SetText(editor, ReadString(0, #PB_File_IgnoreEOL))
  PBEdit_SetFlag(editor, _PBEdit_::#TE_EnableShowModifiedLines, #True)
  CloseFile(0)
EndIf

PBEdit_SetCursorPosition(editor, 1, 1)   ;- <=== now work

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
        PBEdit_Resize(editor, #PB_Ignore, #PB_Ignore, WindowWidth(0) - 10, WindowHeight(0) - (ToolBarHeight(0) + StatusBarHeight(0) + 5))
      EndIf
    Case _PBEdit_::#TE_Event_Selection
      If EventType() = _PBEdit_::#TE_EventType_Change
        Debug "Selection [Line=" + PBEdit_GetCursorLineNr(editor) +
              ", CursorCharNr=" + PBEdit_GetCursorCharNr(editor) +
              ", SelectionCharCount=" + PBEdit_GetSelectionCharCount(editor) + 
              ", SelectionLineNr=" + PBEdit_GetSelectionLineNr(editor) + "]"
      ElseIf EventType() = _PBEdit_::#TE_EventType_Remove
        Debug "EventType()=" + EventType()
      EndIf
  EndSelect
ForEver

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger