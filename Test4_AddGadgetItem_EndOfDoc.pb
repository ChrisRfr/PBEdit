; ============================================================================
; TEST 4 - PBEdit_AddGadgetItem() appending past the last line
; ============================================================================
; BUG (original): a local variable "lineNr" was declared but never assigned
; (always 0 in PureBasic), and used instead of "Position" in the check that
; decides whether to put the newline before or after the new text. Because
; of that, appending an item PAST THE LAST LINE always took the wrong
; branch: the new text got glued directly onto the end of the previous last
; line (no line break before it), plus an extra blank line appeared after.
;
; THIS TEST IS AUTOMATIC: it creates a 2-line document, then appends a 3rd
; item past the end, and checks the resulting line count and content.
; ============================================================================

XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

OpenWindow(0, 0, 0, 400, 300, "Test 4", #PB_Window_Invisible)
editor = PBEdit_Gadget(0, 0, 0, 400, 300)

If PBEdit_IsGadget(editor) = 0
	Debug "TEST 4: FAIL - could not create the PBEdit gadget"
	End
EndIf

PBEdit_SetGadgetText(editor, "Line one" + Chr(10) + "Line two")

; Append a brand new item PAST the last line (Position = current item count,
; i.e. one past the last valid 0-based index) - this is the exact scenario
; that triggered the bug.
count = PBEdit_CountGadgetItems(editor)
PBEdit_AddGadgetItem(editor, count, "Line three")

failed = #False
newCount = PBEdit_CountGadgetItems(editor)

Debug "Line count after append: " + Str(newCount) + " (expected 3)"
If newCount <> 3
	failed = #True
EndIf

For i = 0 To newCount - 1
	line$ = PBEdit_GetGadgetItemText(editor, i)
	Debug "Line " + Str(i) + ": [" + line$ + "]"
Next

; The bug specifically caused "Line two" and "Line three" to be glued
; together on one line (e.g. "Line twoLine three") and/or an extra blank
; line to appear. Check line 1 (0-based) is exactly "Line two" and line 2
; is exactly "Line three", with no stray blank line.
line1$ = PBEdit_GetGadgetItemText(editor, 1)
line2$ = PBEdit_GetGadgetItemText(editor, 2)

If line1$ <> "Line two"
	Debug "TEST 4: FAIL - line 2 should be exactly 'Line two', got: [" + line1$ + "]"
	failed = #True
EndIf
If line2$ <> "Line three"
	Debug "TEST 4: FAIL - line 3 should be exactly 'Line three', got: [" + line2$ + "]"
	failed = #True
EndIf

If failed = #False
	Debug "TEST 4: PASS - appended item is a clean, separate line with no glued text or stray blank line"
EndIf

CloseWindow(0)

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger