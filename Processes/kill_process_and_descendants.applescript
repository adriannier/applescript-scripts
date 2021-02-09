on killProcessAndDescendants(processId)

    (*
        Kills a process and all its descendants
    *)
    
    try
        
        if processId is "" then error "Empty string is an invalid process id" number 1
        
        log "Killing process id " & processId
        
        -- Generate a dictionary mapping process ids to their parent process id    
        set processDict to generateProcessDictionary()
        
        -- Create list of process ids to kill
        set allProcessIds to {processId} & listDescendantProcessIds(processId, processDict)
        
        -- Kill all processes in the list
        set killedIds to {}
        repeat with i from 1 to count of allProcessIds
            
            set pid to item i of allProcessIds
            
            try
                do shell script "kill -9 " & pid
                log "Sent KILL signal to process " & pid
                set end of killedIds to pid
            on error
                log "Process pid " & pid & " was not found"
            end try
            
        end repeat
        
        return killedIds
        
    on error eMsg number eNum
        
        error "killProcessAndDescendants(): " & eMsg
        
    end try
    
end killProcessAndDescendants

on generateProcessDictionary()
    
    try
        
        set processIdList to paragraphs of (do shell script "ps -e -o pid= -o ppid=")
        
        set processDict to newDictionary()
        set parentIds to {}
        
        repeat with i from 1 to count of processIdList
            
            set thisProcessId to first word of item i of processIdList
            set parentProcessId to second word of item i of processIdList
            
            if parentProcessId is not in parentIds then
                processDict's addValueForKey(parentProcessId, {thisProcessId})
                set end of parentIds to parentProcessId
            else
                set childProcessIds to processDict's valueForKey(parentProcessId)
                set end of childProcessIds to thisProcessId
                processDict's setValueForKey(parentProcessId, childProcessIds)
                
            end if
            
        end repeat
        
        return processDict
        
    on error eMsg number eNum
        
        error "generateProcessDictionary(): " & eMsg
        
    end try
    
end generateProcessDictionary

on listDescendantProcessIds(processId, processDict)
    
    try
        
        if processDict's existsKey(processId) then
            set childProcessIds to processDict's valueForKey(processId)
        else
            return {}
        end if
        
        set allChildProcessIds to {}
        
        repeat with i from 1 to count of childProcessIds
            
            set childProcessId to item i of childProcessIds
            
            set end of allChildProcessIds to childProcessId
            
            set grandChildIds to listDescendantProcessIds(childProcessId, processDict)
            
            repeat with j from 1 to count of grandChildIds
                
                set end of allChildProcessIds to item j of grandChildIds
                
            end repeat
            
        end repeat
        
        return allChildProcessIds
        
    on error eMsg number eNum
        
        error "listDescendantProcessIds(): " & eMsg
        
    end try
    
end listDescendantProcessIds

on newDictionary()
    
    (*
        Returns an empty dictionary.
    *)
    
    script Dictionary
        
        property _version : 1
        
        property _keyValuePairs : {}
        property _keyList : {}
        property _keyListAsText : ASCII character 10
        property _valueTypes : {}
        property _keyPathDelimiter : "/"
        property _longestKeyInDict : false
        
        property _nl : " Â" & (ASCII character 10)
        property _indentation : "    "
        property _decimalPointSymbol : false
        
        (* Section: Instance Functions *)
        
        on ________________________________General()
        end ________________________________General
        
        on isDictionary(obj)
            
            (*
                Checks whether the specified object is a dictionary.
                
                Example:
                ```
                set dict to newDictionary()
                set dict2 to newDictionary()
                return dict's isDictionary(dict2)
                ```
            *)
            
            try
                
                return _typeForValue(obj) is "script/Dictionary"
                
            on error eMsg number eNum
                _handleError("isDictionary", eMsg, eNum)
            end try
            
        end isDictionary
        
        on empty()
            
            (*
                Checks whether this dictionary is empty.
                
                Example:
                ```
                set dict to newDictionary()
                
                if dict's empty() then
                
                    -- Do something
                    
                end if
                ```
            *)
            
            try
                
                if (count of _keyList) is 0 then
                    return true
                else
                    return false
                end if
                
            on error eMsg number eNum
                _handleError("empty", eMsg, eNum)
            end try
            
        end empty
        
        on allKeys()
            
            (*
                Returns all keys.
                
                Example:
                ```
                set dict to newDictionary()
                
                repeat with i from 1 to 4
                
                    dict's addValueForKey("key_" & i as text, i)
                    
                end repeat
                
                return dict's allKeys()
                ```
            *)
            
            try
                
                return _keyList
                
            on error eMsg number eNum
                _handleError("allKeys", eMsg, eNum)
            end try
            
        end allKeys
        
        on keyCount()
            
            (*
                Returns the count of all keys.
                
                Example:
                ```
                set dict to newDictionary()
                
                repeat with i from 1 to 4
                
                    dict's addValueForKey("key_" & i as text, i)
                    
                end repeat
                
                return dict's keyCount()
                ```
            *)
            
            try
                
                return count of _keyList
                
            on error eMsg number eNum
                _handleError("keyCount", eMsg, eNum)
            end try
            
        end keyCount
        
        on allKeysRecursively()
            
            (*
                Returns the keys of this dictionary and all its nested dictionaries. The keys of nested dictionaries are returned as key paths.
                
                Example:
                ```
                set dict to newDictionary()
                
                dict's addValueForKeyPathRecursively("a/b/c/d/e/f", "test")
                dict's addValueForKeyPathRecursively("a/b/x/d/e/f", "test")
                dict's addValueForKeyPathRecursively("z/b/x/d/e/f", "test")
                                
                return dict's allKeysRecursively()
                ```
            *)
            
            try
                
                return _recursiveKeys()
                
            on error eMsg number eNum
                _handleError("allKeysRecursively", eMsg, eNum)
            end try
            
        end allKeysRecursively
        
        on allValues()
            
            (*
                Returns all values of this dictionary.
                
                Example:
                ```
                set dict to newDictionary()
                
                repeat with i from 1 to 4
                
                    dict's addValueForKey("key_" & i as text, i)
                    
                end repeat
                
                return dict's allValues()
                ```
            *)
            
            try
                
                if _keyList is {} then return {}
                
                set collectedValues to {}
                
                repeat with i from 1 to count of _keyList
                    set end of collectedValues to _value(i)
                end repeat
                
                return collectedValues
                
            on error eMsg number eNum
                _handleError("allValues", eMsg, eNum)
            end try
            
        end allValues
        
        on ________________________________Key()
        end ________________________________Key
        
        on existsKey(aKey)
            
            (*
                Returns true if the specified key exists, otherwise false.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                return _existsKey(aKey)
                
            on error eMsg number eNum
                _handleError("existsKey", eMsg, eNum)
            end try
            
        end existsKey
        
        on tryKey(aKey, defaultValue)
            
            (*
                If the specified key exists, its value is returned. Otherwise the value specified as **defaultValue** is returned.
            *)
            
            try
                set aKey to _sanitizeKey(aKey)
                
                if not _existsKey(aKey) then
                    return defaultValue
                else
                    return _valueForKey(aKey)
                end if
                
            on error eMsg number eNum
                _handleError("tryKey", eMsg, eNum)
            end try
            
        end tryKey
        
        on addValueForKey(aKey, aValue)
            
            (*
                Adds the value for the specified key. The key must not exists. If it does an error 2 is raised.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                try
                    set pos to _pos(aKey)
                on error
                    set pos to false
                end try
                
                if pos is not false then
                    error "Key \"" & aKey & "\" already exists" number 2
                else
                    _add(aKey, aValue, false)
                end if
                
            on error eMsg number eNum
                _handleError("addValueForKey", eMsg, eNum)
            end try
            
        end addValueForKey
        
        on removeValueForKey(aKey)
            
            (*
                Removes the value for the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                log "Removing value for key \"" & aKey & "\""
                
                set keyPosition to _pos(aKey)
                set previousValue to _value(keyPosition)
                
                log "Removing value for " & aKey
                
                set _keyList to _removePositionFromList(_keyList, keyPosition)
                set _keyListAsText to (ASCII character 10) & _implodeList(_keyList, ASCII character 10, false) & (ASCII character 10)
                set _keyValuePairs to _removePositionFromList(_keyValuePairs, keyPosition)
                set _valueTypes to _removePositionFromList(_valueTypes, keyPosition)
                
                return previousValue
                
            on error eMsg number eNum
                _handleError("removeValueForKey", eMsg, eNum)
            end try
            
        end removeValueForKey
        
        on setValueForKey(aKey, aValue)
            
            (*
                Sets the value for the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                set pos to _pos(aKey)
                _set(pos, aKey, aValue, false)
                
            on error eMsg number eNum
                _handleError("setValueForKey", eMsg, eNum)
            end try
            
        end setValueForKey
        
        on valueForKey(aKey)
            
            (*
                Returns the value for the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                return _valueForKey(aKey)
                
            on error eMsg number eNum
                _handleError("valueForKey", eMsg, eNum)
            end try
            
        end valueForKey
        
        on typeForKey(aKey)
            
            (*
                Returns a string representing the type of the value for the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                return _typeForPair(_pairForKey(_sanitizeKey(aKey)))
                
            on error eMsg number eNum
                _handleError("typeForKey", eMsg, eNum)
            end try
            
        end typeForKey
        
        on classForKey(aKey)
            
            (*
                Returns the AppleScript class for the value of the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                return _classForPair(_pairForKey(_sanitizeKey(aKey)))
                
            on error eMsg number eNum
                _handleError("classForKey", eMsg, eNum)
            end try
            
        end classForKey
        
        on positionForKey(aKey)
            
            (*
                Returns the 1-based position for the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                return _pos(aKey)
                
            on error eMsg number eNum
                _handleError("positionForKey", eMsg, eNum)
            end try
            
        end positionForKey
        
        on indexForKey(aKey)
            
            (*
                Returns the 0-based index for the specified key. The key must exist otherwise error 1 is raised.
            *)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                return _pos(aKey) - 1
                
            on error eMsg number eNum
                _handleError("positionForKey", eMsg, eNum)
            end try
            
        end indexForKey
        
        on ________________________________Key_path()
        end ________________________________Key_path
        
        on existsKeyPath(keyPath)
            
            (*
                Returns true if the key path can be fully satisified, otherwise false.
            *)
            
            try
                
                return _existsKeyPath(_sanitizeKeyPath(keyPath), false)
                
            on error eMsg number eNum
                _handleError("existsKeyPath", eMsg, eNum)
            end try
            
        end existsKeyPath
        
        on tryKeyPath(keyPath, defaultValue)
            
            (*
                Returns the value for the key path if a value is found, other **defaultValue** is returned.
            *)
            
            try
                
                set keyPath to _sanitizeKeyPath(keyPath)
                
                if not existsKeyPath(keyPath) then
                    return defaultValue
                else
                    return valueForKeyPath(keyPath)
                end if
                
            on error eMsg number eNum
                _handleError("tryKeyPath", eMsg, eNum)
            end try
            
        end tryKeyPath
        
        on addValueForKeyPath(keyPath, aValue)
            
            (*
                Adds the specified value at the key path. The dictionaries found along the path must exist. The final key must not exist.
            *)
            
            try
                
                set keyPath to _sanitizeKeyPath(keyPath)
                
                log "Adding value for key path \"" & keyPath & "\""
                
                set dict to _valueForKeyPath(keyPath, -2)
                
                set keyPathComponents to _explodeString(keyPath, _keyPathDelimiter, false)
                
                dict's _add(item -1 of keyPathComponents, aValue, false)
                
            on error eMsg number eNum
                _handleError("addValueForKeyPath", eMsg, eNum)
            end try
            
        end addValueForKeyPath
        
        on addValueForKeyPathRecursively(keyPath, aValue)
            
            (*
                Adds the specified value at the key path. The dictionaries found along the path **will be created automatically**. The final key must not exist.
            *)
            
            try
                
                set keyPath to _sanitizeKeyPath(keyPath)
                
                log "Adding value for key path \"" & keyPath & "\" recursively"
                
                set keyPathComponents to _explodeString(keyPath, _keyPathDelimiter, false)
                
                set keyPathLength to count of keyPathComponents
                
                set obj to me
                
                repeat with i from 1 to keyPathLength
                    
                    set aKey to item i of keyPathComponents
                    
                    if i < keyPathLength then
                        
                        try
                            set obj to obj's _valueForKey(aKey)
                        on error
                            set newDict to newDictionary()
                            obj's _add(aKey, newDict, "script/Dictionary")
                            set obj to newDict
                        end try
                        
                    else
                        obj's _add(aKey, aValue, false)
                    end if
                    
                end repeat
                
                return
                
            on error eMsg number eNum
                _handleError("addValueForKeyPathRecursively", eMsg, eNum)
            end try
            
        end addValueForKeyPathRecursively
        
        on removeValueForKeyPath(keyPath)
            
            (*
                Removes the value at the specified key path.
                
            *)
            
            try
                
                set keyPath to _sanitizeKeyPath(keyPath)
                
                log "Removing value for key path \"" & keyPath & "\""
                
                set keyPathComponents to _explodeString(keyPath, _keyPathDelimiter, false)
                
                set dict to _valueForKeyPath(keyPath, -2)
                
                if not isDictionary(dict) then
                    error "Cannot remove value at key path \"" & keyPath & "\" as the object is not a dictionary"
                else
                    dict's removeValueForKey(item -1 of keyPathComponents)
                end if
                
            on error eMsg number eNum
                _handleError("removeValueForKeyPath", eMsg, eNum)
            end try
            
        end removeValueForKeyPath
        
        on setValueForKeyPath(keyPath, aValue)
            
            (*
                Sets the value at the specified key path. The final key and all the keys along the path must exist.
            *)
            
            try
                
                set keyPath to _sanitizeKeyPath(keyPath)
                
                -- log "Setting value for key path \"" & keyPath & "\""
                
                set dict to _valueForKeyPath(keyPath, -2)
                
                set keyPathComponents to _explodeString(keyPath, _keyPathDelimiter, false)
                
                dict's _set(item -1 of keyPathComponents, aValue, false)
                
            on error eMsg number eNum
                _handleError("setValueForKeyPath", eMsg, eNum)
            end try
            
        end setValueForKeyPath
        
        on valueForKeyPath(keyPath)
            
            (*
                Returns the value at the specified key path.
            *)
            
            try
                
                return _valueFromPair(_pairForKeyPath(_sanitizeKeyPath(keyPath), false))
                
            on error eMsg number eNum
                _handleError("valueForKeyPath", eMsg, eNum)
            end try
            
        end valueForKeyPath
        
        on typeForKeyPath(keyPath)
            
            (*
                Returns a string representing the type of the value at the specified key path. Error 1 is raised when any of the keys along the path do not exist.                
            *)
            
            try
                
                return _typeForPair(_pairForKeyPath(_sanitizeKeyPath(keyPath), false))
                
            on error eMsg number eNum
                _handleError("typeForKeyPath", eMsg, eNum)
            end try
            
        end typeForKeyPath
        
        on classForKeyPath(keyPath)
            
            (*
                Returns the AppleScript class for the value at the specified key path. Error 1 is raised when any of the keys along the path do not exist.                
            *)
            
            try
                
                return _classForPair(_pairForKeyPath(_sanitizeKeyPath(keyPath), false))
                
            on error eMsg number eNum
                _handleError("typeForKeyPath", eMsg, eNum)
            end try
            
        end classForKeyPath
        
        on ________________________________Input_Output()
        end ________________________________Input_Output
        
        on writeToFile(filePath)
            
            (*
                Writes this dictionary to a text file at the specified path. The path should end with .applescript
            *)
            
            try
                
                set writeData to textRepresentation()
                
                _writeTextToFile(writeData, filePath)
                
            on error eMsg number eNum
                _handleError("writeToFile", eMsg, eNum)
            end try
            
        end writeToFile
        
        on readFromFile(filePath)
            
            (*
                Reads data for this dictionary from a text file generated by **writeToFile()** at the specified path.
            *)
            
            try
                
                set filePath to _hfsPath(filePath)
                
                log "Reading from " & filePath
                
                set theData to run script file filePath
                
                try
                    get dict of theData
                on error
                    error "Invalid dictionary at " & filePath
                end try
                
                set readDict to _convertLoadedDict(theData)
                
                set _keyValuePairs to readDict's _keyValuePairs
                set _keyList to readDict's _keyList
                set _keyListAsText to (ASCII character 10) & _implodeList(_keyList, ASCII character 10, false) & (ASCII character 10)
                set _valueTypes to readDict's _valueTypes
                
                if ((count of _keyValuePairs) + (count of _keyList) + (count of _valueTypes)) / 3 is not (count of _keyValuePairs) then
                    error "Invalid dictionary at " & filePath
                end if
                
                
            on error eMsg number eNum
                
                _handleError("readFromFile", eMsg, eNum)
                
            end try
            
        end readFromFile
        
        on ________________________________Representations()
        end ________________________________Representations
        
        on textRepresentation()
            
            (*
                Returns a textual representation of this dictionary.
            *)
            
            try
                
                set txt to _dictTextRepresentation(1)
                
                return txt
                
            on error eMsg number eNum
                _handleError("textRepresentation", eMsg, eNum)
            end try
            
        end textRepresentation
        
        on recordRepresentation()
            
            (*
                Returns this dictionary as an AppleScript record
            *)
            
            try
                
                set theRecord to {}
                
                repeat with i from 1 to count of _keyValuePairs
                    
                    set theKey to _key(i)
                    set theValue to _value(i)
                    set valueType to _typeForPair(item i of _keyValuePairs)
                    
                    
                    if valueType is "script/Dictionary" then
                        
                        set transformedKeyValuePair to {_:theKey, d:theValue's recordRepresentation()}
                        
                    else
                        
                        set transformedKeyValuePair to item i of _keyValuePairs
                        
                    end if
                    
                    set end of theRecord to transformedKeyValuePair
                    
                end repeat
                
                return {dict:theRecord, v:_version}
                
            on error eMsg number eNum
                _handleError("recordRepresentation", eMsg, eNum)
            end try
            
        end recordRepresentation
        
        on ________________________________Private()
        end ________________________________Private
        
        (*
            Below are undocumented private methods that could change at any time.
        *)
        
        
        on _pos(aKey)
            
            try
                
                set aKey to _sanitizeKey(aKey)
                
                if aKey is in _keyList then
                    
                    -- set startDate to current date
                    
                    set keyOffset to offset of ((ASCII character 10) & aKey & (ASCII character 10)) in _keyListAsText
                    
                    if keyOffset is 0 then
                        
                        -- Slower fallback method; this should never need to be called
                        
                        repeat with pos from 1 to count of _keyList
                            if (item pos of _keyList) is aKey then
                                -- log "Found key position: " & pos & " after " & (((current date) - startDate) as text) & " second(s)"
                                return pos
                            end if
                        end repeat
                        
                    else if keyOffset is 1 then
                        
                        return 1
                        
                    else
                        
                        set subString to text 1 thru (keyOffset - 1) of _keyListAsText
                        set pos to (count of paragraphs of subString)
                        -- log "Found key position: " & pos & " after " & (((current date) - startDate) as text) & " second(s)"
                        return pos
                        
                    end if
                    
                end if
                
                if _keyList is {} then
                    error "Key \"" & aKey & "\" not found" number 1
                else
                    error "Key \"" & aKey & "\" not found. Available keys are: " & _toString(_implodeList(allKeys(), ", ", false)) number 1
                end if
                
            on error eMsg number eNum
                error "_pos(): " & eMsg number eNum
            end try
            
        end _pos
        
        on _add(aKey, aValue, valueType)
            
            try
                
                if valueType is false then
                    set valueType to _typeForValue(aValue)
                end if
                
                -- log "Adding value for \"" & aKey & "\" with type: " & valueType
                
                set end of _valueTypes to valueType
                set _keyListAsText to _keyListAsText & aKey & (ASCII character 10)
                set end of _keyList to aKey
                set end of _keyValuePairs to _newPair(aKey, aValue, valueType)
                
                return
                
            on error eMsg number eNum
                error "_add(): " & eMsg number eNum
            end try
            
        end _add
        
        on _set(pos, aKey, aValue, valueType)
            
            try
                
                if valueType is false then
                    set valueType to _typeForValue(aValue)
                end if
                
                -- log "Setting value for key \"" & aKey & "\""
                
                set item pos of _keyValuePairs to _newPair(aKey, aValue, valueType)
                set item pos of _valueTypes to valueType
                
                return
                
            on error eMsg number eNum
                error "_set(): " & eMsg number eNum
            end try
            
        end _set
        
        on _sanitizeKey(aKey)
            
            try
                
                return _snr(paragraph 1 of (aKey as text), _keyPathDelimiter, "_")
                
            on error eMsg number eNum
                error "_sanitizeKey(): " & eMsg number eNum
            end try
            
        end _sanitizeKey
        
        on _sanitizeKeyPath(keyPath)
            
            try
                
                if class of keyPath is list then
                    set keyPath to _implodeList(keyPath, _keyPathDelimiter, false)
                else
                    set keyPath to keyPath as text
                end if
                
                return paragraph 1 of keyPath
                
            on error eMsg number eNum
                error "_sanitizeKey(): " & eMsg number eNum
            end try
            
        end _sanitizeKeyPath
        
        on _existsKey(aKey)
            
            try
                
                return aKey is in _keyList
                
            on error eMsg number eNum
                error "_existsKey(): " & eMsg number eNum
            end try
            
        end _existsKey
        
        on _existsKeyPath(keyPath, lastItem)
            
            try
                
                try
                    _pairForKeyPath(keyPath, lastItem)
                    return true
                on error eMsg number eNum
                    if eNum is 1 then
                        return false
                    else
                        error eMsg number eNum
                    end if
                end try
                
            on error eMsg number eNum
                error "_existsKeyPath(): " & eMsg number eNum
            end try
            
        end _existsKeyPath
        
        on _key(pos)
            
            try
                
                return item pos of _keyList
                
            on error eMsg number eNum
                error "_key(): " & eMsg number eNum
            end try
            
        end _key
        
        on _longestKey()
            
            try
                
                set maxLength to 0
                
                repeat with i from 1 to count of _keyList
                    
                    set keyLength to count of item i of _keyList
                    
                    if keyLength > maxLength then
                        set maxLength to keyLength
                    end if
                    
                end repeat
                
                return maxLength
                
            on error eMsg number eNum
                error "_longestKey(): " & eMsg number eNum
            end try
            
        end _longestKey
        
        on _recursiveKeys()
            
            try
                
                set aKeyList to {}
                
                repeat with i from 1 to count of _valueTypes
                    
                    if item i of _valueTypes is "script/Dictionary" then
                        
                        set subKeys to _value(i)'s _recursiveKeys()
                        
                        repeat with j from 1 to count of subKeys
                            
                            set end of aKeyList to item i of _keyList & _keyPathDelimiter & item j of subKeys
                        end repeat
                        
                    else
                        
                        set end of aKeyList to item i of _keyList
                        
                    end if
                    
                end repeat
                
                return aKeyList
                
            on error eMsg number eNum
                error "_recursiveKeys(): " & eMsg number eNum
            end try
            
        end _recursiveKeys
        
        on _value(pos)
            
            try
                
                return _valueFromPairWithType(item pos of _keyValuePairs, item pos of _valueTypes)
                
            on error eMsg number eNum
                error "_value(): " & eMsg number eNum
            end try
            
        end _value
        
        on _valueForKey(aKey)
            
            try
                
                set pos to _pos(aKey)
                return _valueFromPairWithType(item pos of _keyValuePairs, item pos of _valueTypes)
                
            on error eMsg number eNum
                error "_valueForKey(): " & eMsg number eNum
            end try
            
        end _valueForKey
        
        on _valueForKeyPath(keyPath, lastItem)
            
            try
                
                return _valueFromPair(_pairForKeyPath(keyPath, lastItem))
                
            on error eMsg number eNum
                error "_valueForKeyPath(): " & eMsg number eNum
            end try
            
        end _valueForKeyPath
        
        on _valueFromPair(pair)
            
            try
                
                return _valueFromPairWithType(pair, false)
                
            on error eMsg number eNum
                error "_valueFromPair(): " & eMsg number eNum
            end try
            
        end _valueFromPair
        
        on _valueFromPairWithType(pair, valueType)
            
            try
                
                if valueType is false then
                    set valueType to _typeForPair(pair)
                end if
                
                if valueType is "script/Dictionary" then
                    return d of pair
                    
                else if valueType is "boolean" then
                    return b of pair
                    
                else if valueType is "integer" then
                    return i of pair
                    
                else if valueType is "real" then
                    return f of pair
                    
                else if valueType is "text" then
                    return s of pair
                    
                else if valueType is "date" then
                    return t of pair
                    
                else if valueType is "list" then
                    return a of pair
                    
                else if valueType is "record" then
                    return r of pair
                    
                else
                    
                    try
                        return v of pair
                    on error
                        error "This does not seem to be a key/value pair: " & pair
                    end try
                    
                end if
                
            on error eMsg number eNum
                error "_valueFromPairWithType(): " & eMsg number eNum
            end try
            
        end _valueFromPairWithType
        
        on _type(pos)
            
            try
                
                return item pos of _valueTypes
                
            on error eMsg number eNum
                error "_type(): " & eMsg number eNum
            end try
            
        end _type
        
        on _typeForPair(pair)
            
            try
                
                try
                    get d of pair
                    return "script/Dictionary"
                end try
                
                try
                    get b of pair
                    return "boolean"
                end try
                
                try
                    get i of pair
                    return "integer"
                end try
                
                try
                    get f of pair
                    return "real"
                end try
                
                try
                    get s of pair
                    return "text"
                end try
                
                try
                    get t of pair
                    return "date"
                end try
                
                try
                    get a of pair
                    return "list"
                end try
                
                try
                    get r of pair
                    return "record"
                end try
                
                try
                    get v of pair
                    return "unknown"
                end try
                
                set valueClass to (class of pair) as text
                error "Value of class " & valueClass & " is not a key/value pair: " & pair
                
            on error eMsg number eNum
                error "_typeForPair(): " & eMsg number eNum
            end try
            
        end _typeForPair
        
        on _typeForValue(aValue)
            
            try
                
                set valueClass to (class of aValue) as text
                
                if valueClass is "script" then
                    
                    set scriptName to name of aValue
                    
                    if scriptName is not "Dictionary" then
                        error "_typeForValue(): Unsupported value type \"script/" & scriptName & "\""
                    else
                        return "script/" & scriptName
                    end if
                    
                else if valueClass is "record" then
                    
                    try
                        get dict of aValue
                        return "script/Dictionary"
                    on error
                        return "record"
                    end try
                    
                end if
                
                return valueClass
                
            on error eMsg number eNum
                error "_typeForValue(): " & eMsg number eNum
            end try
            
        end _typeForValue
        
        on _typeForKey(aKey)
            
            try
                
                return _type(_pos(aKey))
                
            on error eMsg number eNum
                error "_typeForKey(): " & eMsg number eNum
            end try
            
        end _typeForKey
        
        on _classForPair(pair)
            
            try
                
                set valueType to _typeForPair(pair)
                
                if valueType is "string" then
                    return string
                else if valueType is "text" then
                    return text
                else if valueType is "Çclass utf8È" then
                    return Çclass utf8È
                else if valueType is "list" then
                    return list
                else if valueType is "record" then
                    return record
                else if valueType is "boolean" then
                    return boolean
                else if valueType is "integer" then
                    return integer
                else if valueType is "real" then
                    return real
                else if valueType is "date" then
                    return date
                else if valueType is "unknown" then
                    return class of _valueFromPair(aKey)
                else
                    error "Unknown value type: " & valueType
                end if
                
            on error eMsg number eNum
                error "_classForPair(): " & eMsg number eNum
            end try
            
        end _classForPair
        
        on _pairForKey(aKey)
            
            try
                
                return item _pos(aKey) of _keyValuePairs
                
            on error eMsg number eNum
                error "_pairForKey(): " & eMsg number eNum
            end try
            
        end _pairForKey
        
        on _pairForKeyPath(keyPath, lastItem)
            
            try
                
                if lastItem is false then set lastItem to -1
                
                set keyPathComponents to _explodeString(keyPath, _keyPathDelimiter, lastItem)
                
                log "Finding pair at path \"" & _implodeList(keyPathComponents, _keyPathDelimiter, false) & "\""
                
                set obj to me
                
                repeat with i from 1 to count of keyPathComponents
                    
                    try
                        
                        if i < (count of keyPathComponents) then
                            set obj to obj's _valueForKey(item i of keyPathComponents)
                        else
                            set obj to obj's _pairForKey(item i of keyPathComponents)
                        end if
                        
                    on error eMsg number eNum
                        error "Error at key path \"" & _implodeList(keyPathComponents, _keyPathDelimiter, i) & "\": " & eMsg number eNum
                    end try
                    
                end repeat
                
                return obj
                
            on error eMsg number eNum
                error "_pairForKeyPath(): " & eMsg number eNum
            end try
            
        end _pairForKeyPath
        
        on _newPair(aKey, aValue, valueType)
            
            try
                
                if valueType is false then
                    set valueType to _typeForValue(aValue)
                end if
                
                if valueType is "script/Dictionary" then
                    set newPair to {_:aKey, d:aValue}
                    
                else if valueType is "boolean" then
                    set newPair to {_:aKey, b:aValue}
                    
                else if valueType is "integer" then
                    set newPair to {_:aKey, i:aValue}
                    
                else if valueType is "real" then
                    set newPair to {_:aKey, f:aValue}
                    
                else if valueType is "text" then
                    set newPair to {_:aKey, s:aValue}
                    
                else if valueType is "date" then
                    set newPair to {_:aKey, t:aValue}
                    
                else if valueType is "list" then
                    set newPair to {_:aKey, a:aValue}
                    
                else if valueType is "record" then
                    set newPair to {_:aKey, r:aValue}
                    
                else
                    set newPair to {_:aKey, v:aValue}
                    
                end if
                
                return newPair
                
            on error eMsg number eNum
                error "_newPair(): " & eMsg number eNum
            end try
            
        end _newPair
        
        on ________________________________Conversion()
        end ________________________________Conversion
        
        on _convertLoadedDict(loadedDict)
            
            try
                
                set newDict to newDictionary()
                
                set pairs to dict of loadedDict
                
                -- log "Count of key/value pairs: " & (count of pairs)
                
                repeat with i from 1 to count of pairs
                    
                    set pair to (a reference to item i of pairs)
                    
                    set theKey to _ of pair
                    set valueType to _typeForPair(pair)
                    set theValue to _valueFromPairWithType(pair, valueType)
                    
                    newDict's _add(theKey, _convertLoadedValue(theValue, valueType), valueType)
                    
                end repeat
                
                return newDict
                
            on error eMsg number eNum
                error "_convertLoadedDict(): " & eMsg number eNum
            end try
            
        end _convertLoadedDict
        
        on _convertLoadedValue(theValue, valueType)
            
            try
                
                if theValue is {} then
                    
                    -- Do nothing
                    
                else if valueType is "script/Dictionary" then
                    set theValue to _convertLoadedDict(theValue)
                    
                else if valueType is "list" then
                    set theValue to _convertLoadedList(theValue)
                    
                else if valueType is "date" then
                    set theValue to _dateFromTimestamp(theValue)
                    
                else if valueType is "integer" then
                    set theValue to _convertLoadedInteger(theValue)
                    
                else if valueType is "real" then
                    set theValue to _convertLoadedFloat(theValue)
                    
                end if
                
                return theValue
                
            on error eMsg number eNum
                error "_convertLoadedValue(): " & eMsg number eNum
            end try
            
        end _convertLoadedValue
        
        on _convertLoadedList(loadedList)
            
            try
                
                set newList to {}
                
                repeat with i from 1 to count of loadedList
                    
                    set pair to (a reference to item i of loadedList)
                    
                    set valueType to _typeForPair(pair)
                    set theValue to _valueFromPairWithType(pair, valueType)
                    
                    set end of newList to _convertLoadedValue(theValue, valueType)
                    
                end repeat
                
                return newList
                
            on error eMsg number eNum
                error "_convertLoadedList(): " & eMsg number eNum
            end try
            
        end _convertLoadedList
        
        on _convertLoadedInteger(str)
            
            try
                
                return str as integer
                
            on error eMsg number eNum
                error "_convertLoadedInteger(): " & eMsg number eNum
            end try
            
        end _convertLoadedInteger
        
        on _convertLoadedFloat(str)
            
            try
                
                if _decimalPointSymbol is false then _initDecimalPointSymbol()
                
                if _decimalPointSymbol is "." and str contains "," then
                    set str to _snr(str, ",", ".")
                else if _decimalPointSymbol is "," and str contains "." then
                    set str to _snr(str, ".", ",")
                end if
                
                return str as real
                
            on error eMsg number eNum
                error "_convertLoadedFloat(): " & eMsg number eNum
            end try
            
        end _convertLoadedFloat
        
        on _initDecimalPointSymbol()
            
            try
                
                try
                    set r to "1,2" as real
                    set _decimalPointSymbol to ","
                on error
                    set r to "1.3" as real
                    set _decimalPointSymbol to "."
                end try
                
            on error eMsg number eNum
                error "_initDecimalPointSymbol(): " & eMsg number eNum
            end try
            
        end _initDecimalPointSymbol
        
        on ________________________________Dumping()
        end ________________________________Dumping
        
        on _letterForType(valueType)
            
            try
                
                if valueType is "script/Dictionary" then
                    return "d"
                else if valueType is "boolean" then
                    return "b"
                else if valueType is "integer" then
                    return "i"
                else if valueType is "real" then
                    return "f"
                else if valueType is "text" then
                    return "s"
                else if valueType is "date" then
                    return "t"
                else if valueType is "list" then
                    return "a"
                else if valueType is "record" then
                    return "r"
                else
                    return "v"
                end if
                
            on error eMsg number eNum
                error "_letterForType(): " & eMsg number eNum
            end try
            
        end _letterForType
        
        on _dump(anItem, depthLevel, dictKey)
            
            try
                
                set valueType to _typeForValue(anItem)
                set valueClass to class of anItem
                
                if valueType is "script/Dictionary" then
                    set itemDump to anItem's _dictTextRepresentation(depthLevel + 3)
                    
                else if valueClass is list then
                    set itemDump to _listTextRepresentation(anItem, depthLevel + 2)
                    
                else if valueClass is in {string, text, Çclass utf8È} then
                    
                    set itemDump to _snr(anItem, "\\", "\\\\")
                    set itemDump to "\"" & _snr(itemDump, "\"", "\\\"") & "\""
                    
                else if valueClass is in {boolean} then
                    set itemDump to anItem as text
                    
                else if valueClass is in {integer, real} then
                    set itemDump to "\"" & (anItem as text) & "\""
                    
                else if valueClass is in {date} then
                    set itemDump to "\"" & _toString(anItem) & "\""
                    
                else
                    set itemDump to _toString(anItem)
                    
                end if
                
                set typeLetter to _letterForType(valueType)
                
                if dictKey is false then
                    
                    -- List item
                    
                    set itemDump to "{" & typeLetter & ":" & itemDump & "}"
                    
                else
                    
                    -- Dictionary key/value pair
                    
                    set preWhitespace to ""
                    set postWhitespace to ""
                    
                    if (valueType is "script/Dictionary" or valueType is "list") and (itemDump is not "{}" and itemDump is not "{dict:{}}") then
                        
                        set preWhitespace to _nl & _genIndt(depthLevel + 2)
                        set postWhitespace to _nl & _genIndt(depthLevel + 1)
                    end if
                    
                    set padding to _padWithSuffix("", _longestKeyInDict - (length of dictKey), " ")
                    
                    set itemDump to "{_:\"" & dictKey & "\", " & padding & typeLetter & ":" & preWhitespace & itemDump & postWhitespace & "}"
                    
                end if
                
                return itemDump
                
            on error eMsg number eNum
                error "_dump(): " & eMsg number eNum
            end try
            
        end _dump
        
        on _listTextRepresentation(aList, depthLevel)
            
            try
                
                if (count of aList) is 0 then
                    
                    set txtValue to "{}"
                    
                else if (count of aList) is 1 and class of (item 1 of aList) is not script then
                    
                    set txtValue to "{" & _dump(item 1 of aList, depthLevel, false) & "}"
                    
                else
                    
                    set indt to _genIndt(depthLevel)
                    set nextIndt to _genIndt(depthLevel + 1)
                    
                    set listItemsAsText to ""
                    
                    repeat with i from 1 to count of aList
                        
                        set itemDump to _dump(item i of aList, depthLevel, false)
                        
                        if listItemsAsText is "" then
                            set listItemsAsText to itemDump
                        else
                            set listItemsAsText to listItemsAsText & "," & _nl & nextIndt & itemDump
                        end if
                        
                    end repeat
                    
                    set txtValue to "{" & _nl & nextIndt & listItemsAsText & _nl & indt & "}"
                    
                end if
                
                return txtValue
                
            on error eMsg number eNum
                error "_listTextRepresentation(): " & eMsg number eNum
            end try
            
        end _listTextRepresentation
        
        on _dictTextRepresentation(depthLevel)
            
            try
                
                if (count of _keyValuePairs) is 0 then
                    
                    set txtValue to "{dict:{}}"
                    
                else
                    
                    set _longestKeyInDict to _longestKey()
                    
                    set dictPairsAsText to ""
                    
                    set indt to _genIndt(depthLevel)
                    set nextIndt to _genIndt(depthLevel + 1)
                    set previousIndt to _genIndt(depthLevel - 1)
                    
                    repeat with i from 1 to count of _keyValuePairs
                        
                        set itemDump to _dump(_value(i), depthLevel, item i of _keyList)
                        
                        if dictPairsAsText is "" then
                            set dictPairsAsText to itemDump
                        else
                            set dictPairsAsText to dictPairsAsText & "," & _nl & nextIndt & itemDump
                        end if
                        
                    end repeat
                    
                    if (count of paragraphs of dictPairsAsText) is 1 then
                        set txtValue to "{dict:{" & dictPairsAsText & "}, v:" & _version & "}"
                    else
                        set txtValue to "{dict: " & _nl & indt & "{" & _nl & nextIndt & dictPairsAsText & _nl & indt & "}, v:" & _version & _nl & previousIndt & "}"
                    end if
                    
                end if
                
                return txtValue
                
            on error eMsg number eNum
                error "_dictTextRepresentation(): " & eMsg number eNum
            end try
            
        end _dictTextRepresentation
        
        on _toString(var)
            
            try
                
                try
                    
                    if (class of var) is in {string, text, Çclass utf8È} then
                        
                        return var
                        
                    else if (class of var) is date then
                        
                        return _timestamp(var)
                        
                    else if class of var is list then
                        item 0 of var
                        
                    else
                        return var as text
                        
                    end if
                    
                on error e
                    
                    if class of var is list then
                        return text (offset of "{" in e) thru -2 of e
                        
                    else if class of var is record then
                        return text (offset of "{" in e) thru -17 of e
                        
                    end if
                    
                    return "missing value"
                    
                end try
                
            on error eMsg number eNum
                error "_toString(): " & eMsg number eNum
            end try
            
        end _toString
        
        on ________________________________List()
        end ________________________________List
        
        on _removePositionFromList(aList, aPosition)
            
            try
                
                if (count of aList) is 1 then
                    
                    set aList to {}
                    
                else if (count of aList) is 2 then
                    
                    if aPosition is 1 then
                        set aList to {item 2 of aList}
                    else
                        set aList to {item 1 of aList}
                    end if
                    
                else
                    
                    try
                        set theStart to items 1 thru (aPosition - 1) of aList
                    on error
                        set theStart to {}
                    end try
                    
                    try
                        set theEnd to items (aPosition + 1) thru -1 of aList
                    on error
                        set theEnd to {}
                    end try
                    
                    set aList to theStart & theEnd
                    
                end if
                
                return aList
                
            on error eMsg number eNum
                error "_removePositionFromList(): " & eMsg number eNum
            end try
            
        end _removePositionFromList
        
        on _implodeList(aList, aDelimiter, lastItem)
            
            try
                
                if aList is {} then return ""
                
                if lastItem is false then set lastItem to -1
                
                set prvDlmt to AppleScript's text item delimiters
                set AppleScript's text item delimiters to aDelimiter
                set aString to items 1 thru lastItem of aList as text
                set AppleScript's text item delimiters to prvDlmt
                
                return aString
                
            on error eMsg number eNum
                error "_implodeList(): " & eMsg number eNum
            end try
            
        end _implodeList
        
        on _explodeString(aString, aDelimiter, lastItem)
            
            try
                
                if lastItem is false then set lastItem to -1
                
                set prvDlmt to AppleScript's text item delimiters
                set AppleScript's text item delimiters to aDelimiter
                set aList to text items 1 thru lastItem of aString
                set AppleScript's text item delimiters to prvDlmt
                
                -- FIXME: Find out why the delimiter is part of the list
                
                set validItems to {}
                
                repeat with i from 1 to count of aList
                    if item i of aList is not aDelimiter then
                        set end of validItems to item i of aList
                    end if
                end repeat
                
                return validItems
                
            on error eMsg number eNum
                error "_explodeString(): " & eMsg number eNum
            end try
            
        end _explodeString
        
        on ________________________________Date()
        end ________________________________Date
        
        on _dateFromTimestamp(aTimestamp)
            
            try
                set y to (text 1 thru 4 of aTimestamp) as integer
                set m to (text 6 thru 7 of aTimestamp) as integer
                set d to (text 9 thru 10 of aTimestamp) as integer
                set h to (text 12 thru 13 of aTimestamp) as integer
                set min to (text 15 thru 16 of aTimestamp) as integer
                set s to (text 18 thru 19 of aTimestamp) as integer
                
                set newDate to current date
                
                set time of newDate to 0
                set day of newDate to 1
                set month of newDate to m
                set year of newDate to y
                set day of newDate to d
                set time of newDate to (h * 60 * 60 + min * 60 + s)
                
                return newDate
                
            on error eMsg number eNum
                error "_dateFromTimestamp(): " & eMsg number eNum
            end try
            
            
        end _dateFromTimestamp
        
        on _timestamp(aDate)
            
            try
                
                -- Get the month and day as integer
                set m to month of aDate as integer
                set d to day of aDate
                
                -- Get the year
                set y to year of aDate as text
                
                -- Get the seconds since midnight
                set theTime to (time of aDate)
                
                -- Get hours, minutes, and seconds
                set h to theTime div (60 * 60)
                set min to theTime mod (60 * 60) div 60
                set s to theTime mod 60
                
                -- Zeropad month value
                set m to m as text
                if (count of m) is less than 2 then set m to "0" & m
                
                
                -- Zeropad day value
                set d to d as text
                if (count of d) is less than 2 then
                    set d to "0" & d
                end if
                
                -- Zeropad hours value
                set h to h as text
                if (count of h) is less than 2 then set h to "0" & h
                
                -- Zeropad minutes value
                set min to min as text
                if (count of min) is less than 2 then set min to "0" & min
                
                -- Zeropad seconds value
                set s to s as text
                if (count of s) is less than 2 then set s to "0" & s
                
                -- Return in a format suitable for log files (e.g. 2000-01-28 23:15:59)
                return y & "-" & m & "-" & d & " " & h & ":" & min & ":" & s
                
            on error eMsg number eNum
                error "_timestamp(): " & eMsg number eNum
            end try
            
        end _timestamp
        
        on ________________________________Utilities()
        end ________________________________Utilities
        
        on _handleError(fnc, eMsg, eNum)
            
            log "[Error] Dictionary/" & fnc & "(): " & eMsg & " (" & (eNum as text) & ")"
            
            try
                -- Try to shorten error message
                if eNum is 1 then
                    
                    set eMsgComponents to _explodeString(eMsg, "(): ", false)
                    set eMsg to item -1 of eMsgComponents
                    
                end if
                
            end try
            
            error "Dictionary/" & fnc & "(): " & eMsg number eNum
            
        end _handleError
        
        on _snr(aText, aPattern, aReplacement)
            
            try
                
                if aText contains aPattern then
                    
                    set prvDlmt to AppleScript's text item delimiters
                    
                    considering case
                        
                        try
                            set AppleScript's text item delimiters to aPattern
                            set tempList to text items of aText
                            set AppleScript's text item delimiters to aReplacement
                            set aText to tempList as text
                        end try
                        
                    end considering
                    
                    set AppleScript's text item delimiters to prvDlmt
                    
                end if
                
                return aText
                
            on error eMsg number eNum
                error "_snr(): " & eMsg number eNum
            end try
            
        end _snr
        
        on _genIndt(depthLevel)
            
            try
                
                set indt to ""
                repeat depthLevel times
                    set indt to indt & _indentation
                end repeat
                
                return indt
                
            on error eMsg number eNum
                error "_genIndt(): " & eMsg number eNum
            end try
            
        end _genIndt
        
        on _padWithSuffix(aText, newWidth, aSuffix)
            
            try
                
                if (count of paragraphs of aText) > 1 then
                    
                    set nl to ASCII character 10
                    
                    -- Pad lines individually
                    set newParagraphs to {}
                    
                    repeat with i from 1 to count of paragraphs of aText
                        set end of newParagraphs to _padWithSuffix(paragraph i of aText, newWidth, aSuffix)
                    end repeat
                    
                    -- Join lines
                    set prvDlmt to AppleScript's text item delimiters
                    set AppleScript's text item delimiters to nl
                    set aText to newParagraphs as text
                    set AppleScript's text item delimiters to prvDlmt
                    
                else
                    
                    -- Pad text to new width
                    repeat newWidth - (count of aText) times
                        set aText to aText & aSuffix
                    end repeat
                    
                end if
                
                return aText
                
            on error eMsg number eNum
                error "_padWithSuffix(): " & eMsg number eNum
            end try
            
        end _padWithSuffix
        
        on _uuid()
            
            try
                
                set buffer to ""
                set chars to "0123456789ABCDEF"
                set dashPositions to {9, 14, 19, 24}
                set charCount to length of chars
                
                
                repeat with i from 1 to 36
                    
                    if i is in dashPositions then
                        set buffer to buffer & "-"
                    else
                        set buffer to buffer & character (random number from 1 to charCount) of chars
                    end if
                    
                end repeat
                
                return buffer
                
            on error eMsg number eNum
                error "_uuid(): " & eMsg number eNum
            end try
            
        end _uuid
        
        on _hfsPath(aPath)
            
            try
                
                -- Convert path to text
                set aPath to aPath as text
                
                if aPath starts with "'" and aPath ends with "'" then
                    -- Remove quotes
                    set aPath to text 2 thru -2 of anyPath
                end if
                
                if aPath does not contain "/" and aPath does not contain ":" then
                    -- Only filename specified; treat as path relative to current directory
                    set aPath to "./" & aPath
                end if
                
                
                if aPath starts with "~" then
                    
                    -- Expand tilde
                    
                    -- Get the path to the userÕs home folder
                    set userPath to POSIX path of (path to home folder)
                    
                    -- Remove trailing slash
                    if userPath ends with "/" then set userPath to (text 1 thru -2 of userPath) as text
                    
                    if aPath is "~" then
                        -- Simply use home folder path
                        set aPath to userPath
                    else
                        -- Concatenate paths
                        set aPath to userPath & (text 2 thru -1 of aPath)
                    end if
                    
                else if aPath starts with "./" then
                    
                    -- Convert reference to current directory to absolute path
                    
                    set aPath to text 3 thru -1 of aPath
                    
                    try
                        set myPath to POSIX path of kScriptPath
                    on error
                        set myPath to POSIX path of (path to me)
                    end try
                    
                    set prvDlmt to AppleScript's text item delimiters
                    set AppleScript's text item delimiters to "/"
                    set parentDirectoryPath to (text items 1 thru -2 of myPath) & "" as text
                    set AppleScript's text item delimiters to prvDlmt
                    
                    set aPath to parentDirectoryPath & aPath
                    
                else if aPath starts with "../" then
                    
                    -- Convert reference to parent directories to absolute path
                    
                    try
                        set myPath to POSIX path of kScriptPath
                    on error
                        set myPath to POSIX path of (path to me)
                    end try
                    
                    set prvDlmt to AppleScript's text item delimiters
                    set AppleScript's text item delimiters to "../"
                    set pathComponents to text items of aPath
                    set parentDirectoryCount to (count of pathComponents) - 1
                    set AppleScript's text item delimiters to "/"
                    set myPathComponents to text items of myPath
                    set parentDirectoryPath to (items 1 thru ((count of items of myPathComponents) - parentDirectoryCount) of myPathComponents) & "" as text
                    set AppleScript's text item delimiters to prvDlmt
                    
                    set aPath to parentDirectoryPath & item -1 of pathComponents
                    
                end if
                
                if aPath does not contain ":" then
                    set aPath to (POSIX file aPath) as text
                end if
                
                return aPath
                
            on error eMsg number eNum
                error "_hfsPath(): " & eMsg number eNum
            end try
            
        end _hfsPath
        
        on _uniqueFileHFSPath(parentFolderPath, fileName, suffix)
            
            (*
                Generates a unique path for a file with the 
                specified name and suffix in a folder 
                located at the specified path.
            *)
            
            try
                
                -- Convert path to text
                set parentFolderPath to parentFolderPath as text
                
                -- Remove quotes
                if parentFolderPath starts with "'" and parentFolderPath ends with "'" then
                    set parentFolderPath to text 2 thru -2 of parentFolderPath
                end if
                
                -- Expand tilde
                if parentFolderPath starts with "~" then
                    
                    -- Get the path to the userÕs home folder
                    set userPath to POSIX path of (path to home folder)
                    
                    -- Remove trailing slash
                    if userPath ends with "/" then set userPath to text 1 thru -2 of userPath as text
                    if parentFolderPath is "~" then
                        set parentFolderPath to userPath
                    else
                        set parentFolderPath to userPath & text 2 thru -1 of parentFolderPath
                    end if
                    
                end if
                
                -- Convert to HFS style path if necessary
                if parentFolderPath does not contain ":" then set parentFolderPath to (POSIX file parentFolderPath) as text
                
                -- Add trailing colon
                if parentFolderPath does not end with ":" then set parentFolderPath to parentFolderPath & ":"
                
                -- Make sure the file does not exist
                set loopNumber to 1
                
                repeat
                    
                    if loopNumber is 1 then
                        set tempFilePath to parentFolderPath & fileName & "." & suffix
                    else
                        set tempFilePath to parentFolderPath & fileName & " " & (loopNumber as text) & "." & suffix
                    end if
                    
                    tell application "System Events" to if (exists file tempFilePath) is false then exit repeat
                    set loopNumber to loopNumber + 1
                    
                end repeat
                
                return tempFilePath
                
            on error eMsg number eNum
                error "_uniqueFilePath(): " & eMsg number eNum
            end try
            
        end _uniqueFileHFSPath
        
        on _writeTextToFile(writeData, filePath)
            
            (*
                Writes UTF-8 strings to a text file at the specified path.
            *)
            
            try
                
                set filePath to _hfsPath(filePath)
                
                
                log "Writing to " & filePath
                
                try
                    set openFile to open for access filePath with write permission
                on error eMsg number eNum
                    error "Failed to open " & filePath & ": " & eMsg number eNum
                end try
                
                try
                    set eof openFile to 0
                on error eMsg number eNum
                    error "Failed to reset end of file for " & filePath & ": " & eMsg number eNum
                end try
                
                try
                    set _ to write writeData to openFile as Çclass utf8È
                on error eMsg number eNum
                    
                    try
                        close access openFile
                    end try
                    
                    error "Failed to write to " & filePath & ": " & eMsg number eNum
                    
                end try
                
                try
                    close access openFile
                on error eMsg number eNum
                    error "Failed to close " & filePath & ": " & eMsg number eNum
                end try
                
            on error eMsg number eNum
                _handleError("_writeTextToFile", eMsg, eNum)
            end try
            
        end _writeTextToFile
        
    end script
    
    return Dictionary
    
end newDictionary