; ============================================================================
; TEST 2 - closing one editor must not break redraw/cursor-blink for others
; ============================================================================
; BUG (regression introduced by a "MyFix" attempt, now fixed): Editor_Free()
; called UnbindEvent(#TE_Event_Redraw, @Event_Redraw()) and
; UnbindEvent(#TE_Event_CursorBlink, @Event_Cursor()). Those two events are
; bound WITHOUT a window in Editor_New() (BindEvent(#TE_Event_Redraw,
; @Event_Redraw()) - no 3rd argument), so they are ONE GLOBAL callback
; shared by every editor instance, not a per-editor one. Unbinding them when
; closing ONE editor silently killed redraw and cursor blinking for every
; OTHER editor still open.
;
; THIS TEST IS MANUAL / VISUAL (it needs a working display + your eyes,
; there is no public API to introspect internal event bindings):
;
;   1. Run this test. Two windows open, each with its own editor and some
;      sample text already loaded.
;   2. Click inside EITHER editor so its caret starts blinking. Confirm you
;      SEE it blink in both windows if you click each one in turn.
;   3. Close window "Editor A" ONLY (its close box, or Alt+F4 on it) - NOT
;      window B.
;   4. Click inside "Editor B" (the one still open) and type a few
;      characters, then leave the caret sitting somewhere.
;
; EXPECTED RESULT (fixed file): Editor B keeps redrawing normally as you
; type, and its caret keeps blinking after you stop typing.
;
; EXPECTED RESULT (regression, unfixed): after closing Editor A, Editor B's
; caret freezes (stops blinking) and/or typed text stops visually updating,
; because the shared redraw/blink event handlers were unbound.
; ============================================================================

XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

OpenWindow(0, 100, 100, 500, 350, "Editor A - close ME first", #PB_Window_SystemMenu | #PB_Window_SizeGadget)
editorA = PBEdit_Gadget(0, 10, 10, 480, 330)
PBEdit_SetText(editorA, "This is editor A." + Chr(10) + "Close this window first," + Chr(10) + "then type in editor B.")

OpenWindow(1, 650, 100, 500, 350, "Editor B - keep ME open, type here after closing A", #PB_Window_SystemMenu | #PB_Window_SizeGadget)
editorB = PBEdit_Gadget(1, 10, 10, 480, 330)
PBEdit_SetText(editorB, "This is editor B." + Chr(10) + "After closing editor A," + Chr(10) + "type here and watch the caret blink.")

Repeat
	event = WaitWindowEvent()
	Select event
		Case #PB_Event_CloseWindow
			Select EventWindow()
				Case 0
					PBEdit_FreeGadget(editorA)
					CloseWindow(0)
					Debug "closed window and editor 0"
				Case 1
					PBEdit_FreeGadget(editorB)
					CloseWindow(1)
					Debug "closed window and editor 1"
			EndSelect

		Case #PB_Event_SizeWindow
			Select EventWindow()
			  Case 0
			    Debug "PBEdit_Resize 0"
					PBEdit_Resize(editorA, #PB_Ignore, #PB_Ignore, WindowWidth(0), WindowHeight(0))
				Case 1
				  Debug "PBEdit_Resize 1"
					PBEdit_Resize(editorB, #PB_Ignore, #PB_Ignore, WindowWidth(1), WindowHeight(1))
			EndSelect
	EndSelect
ForEver

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger