#!/bin/sh

source "$CONFIG_DIR/icons.sh"

case "$1" in
"Terminal" | "Warp" | "iTerm2")
  RESULT=$ICON_TERM
	if grep -q "btop" <<< $2;
  then
	 RESULT=$ICON_CHART
	fi
	if grep -q "brew" <<< $2;
  then
	 RESULT=$ICON_PACKAGE
	fi
	if grep -q "nvim" <<< $2;
  then
	 RESULT=$ICON_DEV
	fi
	if grep -q "ranger" <<< $2;
  then
	 RESULT=$ICON_FILE
	fi
	if grep -q "lazygit" <<< $2;
  then
	 RESULT=$ICON_GIT
	fi
	if grep -q "taskwarrior-tui" <<< $2;
  then
	 RESULT=$ICON_LIST
	fi
	if grep -q "unimatrix\|pipes.sh" <<< $2;
  then
	 RESULT=$ICON_SCREENSAVOR
	fi
	if grep -q "bat" <<< $2;
  then
	 RESULT=$ICON_NOTE
	fi
	if grep -q "tty-clock" <<< $2;
  then
	 RESULT=$ICON_CLOCK
	fi
	;;
"Finder")
	RESULT=$ICON_FINDER
	;;
"Weather")
	RESULT=$ICON_WEATHER
	;;
"Clock")
	RESULT=$ICON_CLOCK
	;;
"Mail" | "Microsoft Outlook")
	RESULT=$ICON_MAIL
	;;
"Calendar")
	RESULT=$ICON_CALENDAR
	;;
"Calculator" | "Numi")
	RESULT=$ICON_CALC
	;;
"Maps" | "Find My")
	RESULT=$ICON_MAP
	;;
"Voice Memos")
	RESULT=$ICON_MICROPHONE
	;;
"Messages" | "Slack" | "Microsoft Teams" | "Telegram" | "WhatsApp")
	RESULT=$ICON_CHAT
	;;
"Discord")
	RESULT=$ICON_DISCORD
	;;
"FaceTime" | "zoom.us" | "Webex")
	RESULT=$ICON_VIDEOCHAT
	;;
"Notes" | "TextEdit" | "Stickies" | "Microsoft Word")
	RESULT=$ICON_NOTE
	;;
"Reminders" | "Microsoft OneNote")
	RESULT=$ICON_LIST
	;;
"Things")
	RESULT=$ICON_THINGS
	;;
"Photo Booth")
	RESULT=$ICON_CAMERA
	;;
"Safari" | "Beam" | "DuckDuckGo" | "Arc" | "Microsoft Edge" | "Google Chrome")
	RESULT=$ICON_WEB
	;;
"Firefox")
	RESULT=$ICON_FIREFOX
	;;
"System Settings" | "System Information" | "TinkerTool")
	RESULT=$ICON_COG
	;;
"HOME")
	RESULT=$ICON_HOMEAUTOMATION
	;;
"Music" | "Spotify")
	RESULT=$ICON_MUSIC
	;;
"Podcasts")
	RESULT=$ICON_PODCAST
	;;
"TV" | "QuickTime Player" | "VLC")
	RESULT=$ICON_PLAY
	;;
"Books")
	RESULT=$ICON_BOOK
	;;
"Xcode" | "Code" | "Neovide")
	RESULT=$ICON_DEV
	;;
"VSCodium")
	RESULT=$ICON_VSCODIUM
	;;
"Dictionary")
	RESULT=$ICON_BOOKINFO
	;;
"Font Book")
	RESULT=$ICON_FONTBOOK
	;;
"Activity Monitor")
	RESULT=$ICON_CHART
	;;
"Disk Utility")
	RESULT=$ICON_DISK
	;;
"Screenshot" | "Preview")
	RESULT=$ICON_PREVIEW
	;;
"1Password")
	RESULT=$ICON_PASSKEY
	;;
"NordVPN")
	RESULT=$ICON_VPN
	;;
"Progressive Downloaded" | "Transmission")
	RESULT=$ICON_DOWNLOAD
	;;
"Airflow")
	RESULT=$ICON_CAST
	;;
"Microsoft Excel" | "Numbers")
	RESULT=$ICON_TABLE
	;;
"Microsoft PowerPoint" | "Keynote" | "Google Slides")
	RESULT=$ICON_PRESENT
	;;
"OneDrive")
	RESULT=$ICON_CLOUD
	;;
"Curve")
	RESULT=$ICON_PEN
	;;
"VMware Fusion" | "UTM")
	RESULT=$ICON_REMOTEDESKTOP
	;;
"Adobe Photoshop 2024")
	RESULT=$ICON_PHOTOSHOP
	;;
"Adobe After Effects")
	RESULT=$ICON_AFTEREFFECTS
	;;
"Photos" | "Lightroom Classic")
	RESULT=$ICON_PHOTOS
	;;
"Figma")
	RESULT=$ICON_FIGMA
	;;
"KiCad")
	RESULT=$ICON_KICAD
	;;
"JDownloader2")
	RESULT=$ICON_DOWNLOAD
	;;
"SF Symbols")
	RESULT=$ICON_ICON
	;;
"Steam" | "Steam Helper")
	RESULT=$ICON_STEAM
	;;
"HandBrake")
	RESULT=$ICON_HANDBRAKE
	;;
"GLMv4" | "GLMv5")
	RESULT=$ICON_GLM
	;;
"Popcorn-Time")
	RESULT=$ICON_POPCORN
	;;
"InDesign")
	RESULT=$ICON_INDESIGN
	;;
"Adobe Illustrator 2024")
	RESULT=$ICON_ILLUSTRATOR
	;;
"DaisyDisk")
	RESULT=$ICON_DAISYDISK
	;;
*)
	RESULT=$ICON_APP
	;;
esac

echo $RESULT
