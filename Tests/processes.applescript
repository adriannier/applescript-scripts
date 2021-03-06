on run
	
	set ProcessKiller to loadScript("../Processes/kill_process_and_descendants.applescript")
	
	----------------------------------------------------------------------------------------------------
	
	set testNumber to 1
	set testName to "Kill processes"
	
	-- Launch a couple of proceses
	set processId to do shell script "( ( sleep 10 ) &>/dev/null & sleep 10 ) &>/dev/null & printf $!"
	
	tell ProcessKiller to set killedProcessIds to killProcessAndDescendants(processId)
	
	-- Check test result
	if (count of killedProcessIds) is not 3 then
		error "Failed test " & (testNumber as text) & ": " & testName
	end if
	
end run

on loadScript(specifiedPath)
	
	(* 
	
	loadScript("/path/to/script.applescript")
	Version 3
	
	Loads an AppleScript file compiling it first if necessary.
	
	Specified path can be:
	
	- single file name 
	  --> file assumed in same directory as current script
	  
	- single file name prefixed with ./ 
	  --> file assumed in same directory as current script
	  
	- relative POSIX path prefixed with one or more ../ 
	  --> file assumed at relative path
	  
	- relative POSIX path starting with ~/ 
	  --> file assumed relative to home directory
	  
	- full HFS-style path
	
	- full POSIX path
	
	Version history
	===============

	Version 3 - 2021-02-09
	
	- Fixed bug in handling paths that start with "../"
		
	Version 2 - 2020-09-23
	
	- Handled error where sometimes the path to the temporary 
	  items folder could not be gathered
	  
	- Packed uses of the text class inside System Events tell 
	  blocks to avoid certain applications causing the class 
	  to change during compile time

	Version 1 - Initial release
	
*)
	
	try
		
		script Util
			
			on hfsPath(aPath)
				
				log " Converting path \"" & aPath & "\" to HFS"
				
				set aPath to pathToString(aPath)
				set aPath to unwrap(aPath, "'")
				
				if aPath does not contain "/" and aPath does not contain ":" then
					-- Only filename specified; treat as path relative to current directory
					set aPath to "./" & aPath
					log " Converted file name specification to " & aPath
				end if
				
				-- Get the path to this script
				try
					set myPath to pp(kScriptPath)
				on error
					set myPath to pp(path to me)
				end try
				
				log " Own path is " & myPath
				
				-- Get path to parent directory
				set myPathComponents to explode(myPath, "/")
				set myParentDirectoryPath to implode(items 1 thru -2 of myPathComponents & "", "/")
				
				log " Parent path is " & myParentDirectoryPath
				
				if aPath does not contain ":" then
					
					if aPath starts with "~" then
						
						(* Expand tilde *)
						
						-- Get the path to the user�s home folder
						tell application "System Events" to set userPath to Util's pp(path to home folder as text)
						
						-- Remove trailing slash
						if userPath ends with "/" then
							tell application "System Events"
								set userPath to text 1 thru -2 of userPath
							end tell
						end if
						
						log " Found user�s home folder at " & userPath & " "
						
						if aPath is "~" then
							-- Simply use home folder path
							set aPath to userPath
						else
							-- Concatenate paths
							tell application "System Events"
								set aPath to userPath & (text 2 thru -1 of aPath)
							end tell
						end if
						
						log " Expanded tilde to " & aPath
						
					else if aPath starts with "./" then
						
						(* Convert current directory reference *)
						
						tell application "System Events"
							set aPath to myParentDirectoryPath & text 3 thru -1 of aPath
						end tell
						
						log " Converted reference to current directory to " & aPath
						
					else if aPath starts with "../" then
						
						-- Convert reference to parent directories to absolute path
						
						tell Util
							set pathComponents to explode(aPath, "../")
							set parentDirectoryCount to (count of pathComponents)
							set parentDirectoryPath to implode((items 1 thru ((count of items of myPathComponents) - parentDirectoryCount) of myPathComponents) & "", "/")
						end tell
						
						set aPath to parentDirectoryPath & item -1 of pathComponents
						
						log " Converted relative path to " & aPath
						
					else
						
						log " Normalized path to " & aPath & " "
						
					end if
					
					-- Turn POSIX path to HFS path
					tell application "System Events"
						set aPath to POSIX file aPath as text
					end tell
					
				end if
				
				log " Converted path to " & aPath
				
				return aPath
				
			end hfsPath
			
			on q(str)
				
				(* Return quoted string *)
				
				return quoted form of str
				
			end q
			
			on pp(aPath)
				
				(* Return posix path for path *)
				
				try
					tell application "System Events" to return POSIX path of file (aPath as text)
				on error eMsg number eNum
					-- log " Warning! System Events could not get posix path of " & aPath
					try
						tell application "System Events" to return POSIX path of folder (aPath as text) & "/"
					on error eMsg number eNum
						error "Util/pp(): " & eMsg number eNum
					end try
				end try
				
			end pp
			
			on qpp(aPath)
				
				(* Return quoted posix path for path *)
				
				return q(pp(aPath))
				
			end qpp
			
			on snr(str, search, replace)
				
				(* Search and replace *)
				
				return implode(explode(str, search), replace)
				
			end snr
			
			on explode(str, dlmt)
				
				(* Convert string to list *)
				
				set prvDlmt to AppleScript's text item delimiters
				set AppleScript's text item delimiters to dlmt
				set strComponents to text items of str
				set AppleScript's text item delimiters to prvDlmt
				
				return strComponents
				
			end explode
			
			on implode(strComponents, dlmt)
				
				(* Convert list to string *)
				
				tell application "System Events"
					set prvDlmt to AppleScript's text item delimiters
					set AppleScript's text item delimiters to dlmt
					set str to strComponents as text
					set AppleScript's text item delimiters to prvDlmt
				end tell
				
				return str
				
			end implode
			
			on unwrap(str, char)
				
				(* Remove first and last character of `str` if both characters are `char` *)
				
				if str starts with char and str ends with char and str is not (char & char) then
					tell application "System Events" to return text 2 thru -2 of str
				end if
				
				return str
				
			end unwrap
			
			on pathToString(aPath)
				
				(* Convert any path to a string *)
				
				try
					tell application "System Events" to return aPath as text
				on error
					tell application "System Events" to return path of aPath
				end try
				
			end pathToString
			
		end script
		
		-- Convert path to text
		tell Util to set scriptPath to hfsPath(specifiedPath)
		
		-- Get information on existing script file
		try
			tell application "System Events"
				set scriptModDate to modification date of file scriptPath
				set scriptName to name of file scriptPath
			end tell
		on error
			error "Could not find script file at \"" & scriptPath & "\""
		end try
		
		if scriptPath ends with ".applescript" then
			
			log " Plain-text AppleScript specified "
			
			-- Plain text version of script; look for compiled version
			
			-- Turn script path into a string we can use for identification
			tell Util to set scriptId to implode(explode(scriptPath, {":", " ", "/"}), "_")
			-- Remove the .applescript suffix from the id
			tell application "System Events" to set scriptId to text 1 thru -13 of scriptId
			
			log " Script id is " & scriptId
			
			-- Generate temporary path
			try
				set compiledScriptParent to (path to temporary items folder from user domain)
			on error eMsg number eNum
				try
					set compiledScriptParent to (path to temporary items folder)
				on error eMsg number eNum
					try
						tell application "System Events" to set compiledScriptParent to (path to temporary items folder)
					on error eMsg number eNum
						try
							set compiledScriptParent to do shell script "echo $TMPDIR"
							set compiledScriptParent to POSIX file compiledScriptParent
						on error eMsg number eNum
							error "Could not get path to temporary items folder. " & eMsg number eNum
						end try
					end try
				end try
			end try
			
			tell application "System Events"
				set compiledScriptParent to compiledScriptParent as text
			end tell
			
			set compiledScriptPath to compiledScriptParent & scriptId & ".scpt"
			
			log " Compiled script path is " & compiledScriptPath
			
			-- Get information on possibly existing compiled script		
			try
				tell application "System Events"
					set compiledModDate to modification date of file compiledScriptPath
				end tell
				log " Modification date of compiled script is " & compiledModDate
			on error eMsg number eNum
				log " Could not get modification date of compiled script. " & eMsg & " (" & (eNum as string) & ")"
				set compiledModDate to false
			end try
			
			if compiledModDate is false or scriptModDate > compiledModDate then
				
				log " Script changed or was never compiled "
				
				set compileCommand to "/usr/bin/osacompile -o " & Util's q(Util's pp(compiledScriptParent) & scriptId & ".scpt") & " " & Util's qpp(scriptPath)
				
				try
					do shell script compileCommand
				on error eMsg number eNum
					error "Failed to compile script file at \"" & scriptPath & "\". " & eMsg number eNum
				end try
				
			end if
			
		else
			
			log " Compiled AppleScript specified "
			
			set compiledScriptPath to scriptPath
			
		end if
		
		-- Load the script			
		try
			log " Loading script from \"" & compiledScriptPath & "\" "
			set loadedScript to load script file compiledScriptPath
		on error eMsg number eNum
			error "Could not load script file at \"" & compiledScriptPath & "\". " & eMsg number eNum
		end try
		
		-- Try to set script's own path property
		try
			set loadedScript's kScriptPath to scriptPath
			log " Property kScriptPath set \"" & scriptPath & "\" in loaded script "
		on error eMsg number eNum
			log " Script has no kScriptPath property "
		end try
		
		-- Try to initialize script
		try
			set initFunctionClass to class of loadedScript's initScript
		on error eMsg number eNum
			set initFunctionClass to missing value
			log " Script has no initScript() function "
		end try
		
		if initFunctionClass is handler then
			try
				set initResult to loadedScript's initScript()
				try
					get initResult
					set loadedScript to initResult
				end try
				
			on error eMsg number eNum
				error " Error while initializing script " & scriptName & ": " & eMsg number eNum
			end try
		end if
		
		
		return loadedScript
		
	on error eMsg number eNum
		
		log " " & eMsg & " (" & (eNum as string) & ")"
		error "loadScript(" & specifiedPath & "): " & eMsg number eNum
		
	end try
	
end loadScript