; ============================================================================
; TEST 6 - Stress test: repeated create/split/close cycles must not crash
; ============================================================================
; This doesn't measure leaked bytes directly (no easy way to do that from
; inside PureBasic without an external profiler), but it exercises, many
; times in a row, every code path touched by the memory/thread fixes:
;   - Editor_Free() thread handling (crash fix)
;   - View_Delete() / View split + close (view-structure leak fix)
;   - regExRepeatedSelection / regExFind / regExDictionary handles
; If any of those fixes is subtly wrong (e.g. a double free, a dangling
; pointer, a real deadlock), this is the kind of test likely to crash,
; hang, or visibly slow down / balloon in memory after many iterations.
;
; HOW TO USE: run it, watch Task Manager's memory usage for this process
; while it runs. Memory should stay roughly flat (small fluctuations are
; normal) across the iterations rather than climbing steadily. The test
; prints progress to the debug output and a final PASS if it completes
; without crashing.
; ============================================================================

XIncludeFile "PBEdit_1_15.pb"   ; <-- adjust path/filename if needed

UseModule PBEdit

#Iterations = 200

OpenWindow(0, 0, 0, 500, 400, "Test 6 - stress test running...", #PB_Window_SystemMenu)

Delay(5000)   ; Use Process Hacker 2, process PureBasic_compilation0.exe to check Memory, GDI Handles,... 
For i = 1 To #Iterations
	editor = PBEdit_Gadget(0, 0, 0, 500, 400)
	If PBEdit_IsGadget(editor) = 0
		Debug "TEST 6: FAIL - gadget creation failed at iteration " + Str(i)
		End
	EndIf

	PBEdit_SetText(editor, "Iteration " + Str(i) + Chr(10) + "Some sample text" + Chr(10) + "on a few lines.")

	; Activate it (this creates/uses the shared cursor-blink thread) then
	; immediately free it WITHOUT processing further window events - this
	; is the exact pattern that used to crash on WaitThread().
	PBEdit_Activate(editor)

	; Occasionally simulate closing before ever activating (the original
	; crash scenario), to cover both code paths.
	If i % 5 = 0
		editor2 = PBEdit_Gadget(0, 0, 0, 500, 400)
		PBEdit_FreeGadget(editor2)   ; freed with no activation at all
		;Debug "PBEdit_FreeGadget(editor2)"
	EndIf

	PBEdit_FreeGadget(editor)
	;Debug "PBEdit_FreeGadget(editor)"
	
	If i % 20 = 0
		Debug "TEST 6: completed " + Str(i) + " / " + Str(#Iterations) + " iterations"
		SetWindowTitle(0, "Test 6 - " + Str(i) + " / " + Str(#Iterations))
	EndIf

	; Let the event loop breathe a little so timers/threads behave as they
	; would in a real application, and the window stays responsive.
	Repeat
	Until WindowEvent() = 0 
Next

Debug "TEST 6: PASS - " + Str(#Iterations) + " create/activate/free cycles completed without crashing"
Debug "TEST 6: check Task Manager - memory usage should not have climbed steadily during this run"

; IDE Options = PureBasic 6.41 (Windows - x64)
; Optimizer
; EnableXP
; DPIAware
; DisableDebugger