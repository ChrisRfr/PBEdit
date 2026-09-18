; ============================================================================
; TEST 3 - PBEdit_SetGadgetText() must not pollute the Undo/Redo history
; ============================================================================
; BUG (original): every call to PBEdit_SetGadgetText() pushed a full-document
; "select all / delete / insert" group onto the Undo stack, and never
; cleared the Redo stack. Calling it repeatedly (e.g. reloading a file, or
; refreshing content) made the Undo history grow forever, and a later
; PBEdit_Redo() could replay stale positions from before the reload.
;
; THIS TEST IS AUTOMATIC: it calls PBEdit_SetGadgetText() three times with
; different content, then calls PBEdit_Undo() several times and checks that
; the text NEVER reverts to an earlier "loaded" version - because none of
; those loads should have been undoable at all.
; ============================================================================

SetCurrentDirectory(GetPathPart(ProgramFilename()))

XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

OpenWindow(0, 0, 0, 400, 300, "Test 3", #PB_Window_Invisible)
editor = PBEdit_Gadget(0, 0, 0, 400, 300)

If PBEdit_IsGadget(editor) = 0
	Debug "TEST 3: FAIL - could not create the PBEdit gadget"
	End
EndIf

text1$ = "First version of the document."
text2$ = "Second version, completely different."
text3$ = "Third and final version."

For i = 1 To 20
  PBEdit_SetGadgetText(editor, text1$)
  PBEdit_SetGadgetText(editor, text2$)
  PBEdit_SetGadgetText(editor, text3$)
Next

; Now do a small, REAL, user-style edit so there is something legitimate
; that Undo COULD meaningfully revert (typed text is still undoable).
PBEdit_SetCursorPosition(editor, 1, Len(text3$) + 1)
PBEdit_AddGadgetItem(editor, -1, " (edited)")

after$ = PBEdit_GetGadgetText(editor)
Debug "After edit: " + after$

failed = #False

; Try undoing several times (more than enough to reach past all 3 reloads
; if the bug were still present) and make sure we NEVER see text1$ or
; text2$ reappear - only the current content, or at most the pre-edit
; text3$ (undoing the one real edit is fine and expected).
For i = 1 To 5
	Debug "PBEdit_Undo Return=" + PBEdit_Undo(editor) + " (0=Fail, 1=Done)"
	current$ = PBEdit_GetGadgetText(editor)
	Debug "After Undo #" + Str(i) + ": " + current$
	If FindString(current$, text1$) Or FindString(current$, text2$)
		failed = #True
	EndIf
Next

If failed
	Debug "TEST 3: FAIL - an earlier PBEdit_SetGadgetText() reload reappeared via Undo (history was polluted)"
Else
	Debug "TEST 3: PASS - repeated PBEdit_SetGadgetText() calls left nothing undoable"
EndIf

CloseWindow(0)

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger