set input to paragraphs of (do shell script "/opt/homebrew/bin/icalBuddy -ec 'Found in Natural Language,CCSF' -npn -nc -iep 'datetime,title' -po 'datetime,title' -eed -ea -n -li 4 -ps '|: |' -b '' eventsToday")

set currentTime to date (do shell script "date '+%I:%M %p'")

set theEvent to ""

if input is not "" then
	repeat with anEvent in input
		set text item delimiters to "^"
		set eventTime to date (text item 1 of anEvent)
		set text item delimiters to ""
		if eventTime > currentTime then
			set theEvent to anEvent as string
			exit repeat
		end if
	end repeat
end if

return theEvent
