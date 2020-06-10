osascript<<EOF
		tell application "System Events"
		tell process "Terminal" to keystroke "n" using command down
		end 
		tell application "Terminal"
		activate
		do script with command "cd `pwd`" in window 1
		do script with command "cd ../..
" in window 1
		do script with command "clear" in window 1
		do script with command "jolie ACME_magazzini_MP.ol
" in window 1
		end tell
		EOF