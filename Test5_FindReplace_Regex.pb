; ============================================================================
; TEST 5 - Regex Find/Replace (MANUAL / GUIDED TEST)
; ============================================================================
; BUG (original, pre-existing since v1.14): Find_Next() called the regex
; functions (IsRegularExpression, ExamineRegularExpression, ...) with the
; FLAG CONSTANT #TE_Find_RegEx instead of the real compiled regex handle
; *te\regExFind. As a result, "Search with regular expression" almost never
; found anything at all.
;
; There is no public PBEdit_Find*() API to drive this headlessly, so this
; test is manual - follow the steps below after running it.
;
; STEPS:
;   1. Run this test. A window opens with sample text already loaded.
;   2. Press Ctrl+H to open Find & Replace.
;   3. Enable the "Regular expression" option (checkbox in the Find window).
;   4. In "Find what", type:      \d+
;      In "Replace with", type:   #
;   5. Click "Replace All".
;
; EXPECTED RESULT (fixed file): every run of digits in the sample text
; (123, 45, 6789, 0) gets replaced by "#". The status/message should report
; several replacements made, and the visible text should now read:
;     "Item # costs $#.# and there are # left, # in reserve."
;
; EXPECTED RESULT (original, unfixed file): "Replace All" reports no
; matches found (or replaces nothing) - the regex search silently fails
; because it was checking the wrong handle.
;
; BONUS CHECK (zero-length match / infinite-loop guard):
;   6. Clear the fields, enable regex again, and try "Find what": x*
;      with "Replace with" left EMPTY or set to the exact same text "x*"
;      (an edge case where a match can be zero-length). Click "Replace All".
;   Expected: the operation completes (does not freeze the application).
;   If the app hangs/freezes here, something is wrong with the
;   infinite-loop guard - close it via Task Manager and report back.
; ============================================================================

XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

OpenWindow(0, 0, 0, 700, 300, "Test 5 - Ctrl+H, enable Regex, find \d+ replace with #", #PB_Window_SystemMenu | #PB_Window_SizeGadget)
editor = PBEdit_Gadget(0, 0, 0, 700, 300)
PBEdit_SetText(editor, "Item 123 costs $45.6789 and there are 0 left, 6789 in reserve.")

Repeat
	Select WaitWindowEvent()
		Case #PB_Event_CloseWindow
			PBEdit_FreeGadget(editor)
			End
		Case #PB_Event_SizeWindow
			PBEdit_Resize(editor, #PB_Ignore, #PB_Ignore, WindowWidth(0), WindowHeight(0))
	EndSelect
ForEver

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger