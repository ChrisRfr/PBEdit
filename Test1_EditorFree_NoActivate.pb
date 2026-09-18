; ============================================================================
; TEST 1 - Editor_Free() crash on a never-activated editor
; ============================================================================
; BUG (original PBEdit_1_14.pb): Editor_Free() called WaitThread() on
; _PBEdit_Window_\cursorThread without checking IsThread() first. If the
; editor is freed before it was ever activated (so the shared cursor-blink
; thread was never created), this crashes with:
;   [ERROR] ... : The specified 'Thread' is null
;
; HOW THIS TEST REPRODUCES IT: creates a gadget and closes it IMMEDIATELY,
; in the same run of the event loop, WITHOUT ever letting the window
; receive #PB_Event_ActivateWindow (which is what normally triggers
; Editor_Activate() / thread creation). This is exactly the scenario from
; TestPBEDITinP.pb that originally crashed.
;
; EXPECTED RESULT (fixed file): no crash, "TEST 1: PASS" printed to the
; debug output, program exits cleanly.
; EXPECTED RESULT (original, unfixed file): crash on PBEdit_FreeGadget().
; ============================================================================

XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

Debug "TEST 1 - starting: create an editor and free it before any activation"

OpenWindow(0, 0, 0, 400, 300, "Test 1", #PB_Window_Invisible)

editor = PBEdit_Gadget(0, 0, 0, 400, 300)

If PBEdit_IsGadget(editor) = 0
	Debug "TEST 1: FAIL - could not create the PBEdit gadget"
	End
EndIf

; --- No WaitWindowEvent() loop at all here: the window never receives
; #PB_Event_ActivateWindow, so Editor_Activate() (and therefore the cursor
; thread) is never triggered before we free the gadget. This is the exact
; condition that used to crash.
PBEdit_FreeGadget(editor)

CloseWindow(0)

Debug "TEST 1: PASS - Editor_Free() did not crash on a never-activated editor"

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger