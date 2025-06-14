# SHKD Key Bindings

## Open Applications

| Key Combination      | Command                                    |
| -------------------- | ------------------------------------------ |
| cmd - return         | open -na kitty                             |
| cmd + shift - return | open ~/                                    |
| ctrl + alt - c       | open -a "/Applications/Mattermost.app"     |
| ctrl + alt - e       | open -a "/Applications/Microsoft Edge.app" |
| ctrl + alt - f       | open -a "/Applications/Firefox.app"        |
| ctrl + alt - w       | open -a "/Applications/WhatsApp.app"       |
| ctrl + alt - o       | open -a "/Applications/Obsidian.app"       |
| ctrl + alt - m       | open -a "Mail"                             |
| ctrl + alt - d       | open -a docker                             |

## Focus Window

| Key Combination | Command                       |
| --------------- | ----------------------------- |
| alt - h         | yabai -m window --focus west  |
| alt - j         | yabai -m window --focus south |
| alt - k         | yabai -m window --focus north |
| alt - l         | yabai -m window --focus east  |

## Swap Window

| Key Combination | Command                      |
| --------------- | ---------------------------- |
| shift + alt - h | yabai -m window --swap west  |
| shift + alt - j | yabai -m window --swap south |
| shift + alt - k | yabai -m window --swap north |
| shift + alt - l | yabai -m window --swap east  |

## Move Window

| Key Combination | Command                      |
| --------------- | ---------------------------- |
| shift + cmd - h | yabai -m window --warp west  |
| shift + cmd - j | yabai -m window --warp south |
| shift + cmd - k | yabai -m window --warp north |
| shift + cmd - l | yabai -m window --warp east  |

## Resize Window

| Key Combination | Command                               |
| --------------- | ------------------------------------- |
| shift + alt - a | yabai -m window --resize left:-20:0   |
| shift + alt - s | yabai -m window --resize bottom:0:20  |
| shift + alt - w | yabai -m window --resize top:0:-20    |
| shift + alt - d | yabai -m window --resize right:20:0   |
| shift + cmd - a | yabai -m window --resize left:20:0    |
| shift + cmd - s | yabai -m window --resize bottom:0:-20 |
| shift + cmd - w | yabai -m window --resize top:0:20     |
| shift + cmd - d | yabai -m window --resize right:-20:0  |

## Balance and Grid

| Key Combination     | Command                            |
| ------------------- | ---------------------------------- |
| shift + alt - 0     | yabai -m space --balance           |
| shift + alt - up    | yabai -m window --grid 1:1:0:0:1:1 |
| shift + alt - left  | yabai -m window --grid 1:2:0:0:1:1 |
| shift + alt - right | yabai -m window --grid 1:2:1:0:1:1 |

## Desktop Management

| Key Combination | Command                       |
| --------------- | ----------------------------- |
| cmd + alt - w   | yabai -m space --destroy      |
| cmd + alt - x   | yabai -m space --focus recent |
| cmd + alt - z   | yabai -m space --focus prev   |
| cmd + alt - c   | yabai -m space --focus next   |
| cmd + alt - 1   | yabai -m space --focus 1      |
| cmd + alt - 2   | yabai -m space --focus 2      |
| cmd + alt - 3   | yabai -m space --focus 3      |
| cmd + alt - 4   | yabai -m space --focus 4      |
| cmd + alt - 5   | yabai -m space --focus 5      |
| cmd + alt - 6   | yabai -m space --focus 6      |
| cmd + alt - 7   | yabai -m space --focus 7      |
| cmd + alt - 8   | yabai -m space --focus 8      |
| cmd + alt - 9   | yabai -m space --focus 9      |
| cmd + alt - 0   | yabai -m space --focus 10     |

## Send Window to Desktop

| Key Combination | Command                        |
| --------------- | ------------------------------ |
| shift + alt - x | yabai -m window --space recent |
| shift + alt - z | yabai -m window --space prev   |
| shift + alt - c | yabai -m window --space next   |
| shift + alt - 1 | yabai -m window --space 1      |
| shift + alt - 2 | yabai -m window --space 2      |
| shift + alt - 3 | yabai -m window --space 3      |
| shift + alt - 4 | yabai -m window --space 4      |
| shift + alt - 5 | yabai -m window --space 5      |
| shift + alt - 6 | yabai -m window --space 6      |
| shift + alt - 7 | yabai -m window --space 7      |
| shift + alt - 8 | yabai -m window --space 8      |
| shift + alt - 9 | yabai -m window --space 9      |
| shift + alt - 0 | yabai -m window --space 10     |

## Send Window to Desktop and Follow Focus

| Key Combination | Command                                                       |
| --------------- | ------------------------------------------------------------- |
| shift + cmd - x | yabai -m window --space recent; yabai -m space --focus recent |
| shift + cmd - z | yabai -m window --space prev; yabai -m space --focus prev     |
| shift + cmd - c | yabai -m window --space next; yabai -m space --focus next     |
| shift + cmd - 1 | yabai -m window --space 1; yabai -m space --focus 1           |
| shift + cmd - 2 | yabai -m window --space 2; yabai -m space --focus 2           |
| shift + cmd - 3 | yabai -m window --space 3; yabai -m space --focus 3           |
| shift + cmd - 4 | yabai -m window --space 4; yabai -m space --focus 4           |
| shift + cmd - 5 | yabai -m window --space 5; yabai -m space --focus 5           |
| shift + cmd - 6 | yabai -m window --space 6; yabai -m space --focus 6           |
| shift + cmd - 7 | yabai -m window --space 7; yabai -m space --focus 7           |
| shift + cmd - 8 | yabai -m window --space 8; yabai -m space --focus 8           |
| shift + cmd - 9 | yabai -m window --space 9; yabai -m space --focus 9           |
| shift + cmd - 0 | yabai -m window --space 10; yabai -m space --focus 10         |

## Focus Monitor

| Key Combination | Command                         |
| --------------- | ------------------------------- |
| ctrl + alt - x  | yabai -m display --focus recent |
| ctrl + alt - z  | yabai -m display --focus prev   |
| ctrl + alt - c  | yabai -m display --focus next   |
| ctrl + alt - 1  | yabai -m display --focus 1      |
| ctrl + alt - 2  | yabai -m display --focus 2      |
| ctrl + alt - 3  | yabai -m display --focus 3      |

## Send Window to Monitor and Follow Focus

| Key Combination | Command                                                           |
| --------------- | ----------------------------------------------------------------- |
| ctrl + cmd - x  | yabai -m window --display recent; yabai -m display --focus recent |
| ctrl + cmd - z  | yabai -m window --display prev; yabai -m display --focus prev     |
| ctrl + cmd - c  | yabai -m window --display next; yabai -m display --focus next     |
| ctrl + cmd - 1  | yabai -m window --display 1; yabai -m display --focus 1           |
| ctrl + cmd - 2  | yabai -m window --display 2; yabai -m display --focus 2           |
| ctrl + cmd - 3  | yabai -m window --display 3; yabai -m display --focus 3           |

## Window Management

| Key Combination | Command                                                                                                                          |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| ctrl + alt - h  | yabai -m window --insert west                                                                                                    |
| ctrl + alt - j  | yabai -m window --insert south                                                                                                   |
| ctrl + alt - k  | yabai -m window --insert north                                                                                                   |
| ctrl + alt - l  | yabai -m window --insert east                                                                                                    |
| alt - r         | yabai -m space --rotate 90                                                                                                       |
| alt - y         | yabai -m space --mirror y-axis                                                                                                   |
| alt - x         | yabai -m space --mirror x-axis                                                                                                   |
| alt - a         | yabai -m space --toggle padding; yabai -m space --toggle gap                                                                     |
| alt - d         | yabai -m window --toggle zoom-parent                                                                                             |
| alt - f         | yabai -m window --toggle zoom-fullscreen                                                                                         |
| shift + alt - f | yabai -m window --toggle native-fullscreen                                                                                       |
| shift + alt - b | yabai -m window --toggle border                                                                                                  |
| alt - e         | yabai -m window --toggle split                                                                                                   |
| alt - t         | yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2                                                               |
| alt - s         | yabai -m window --toggle sticky                                                                                                  |
| alt - o         | yabai -m window --toggle topmost                                                                                                 |
| alt - p         | yabai -m window --toggle sticky; yabai -m window --toggle topmost; yabai -m window --toggle border; yabai -m window --toggle pip |

## Change Layout of Desktop

| Key Combination  | Command                       |
| ---------------- | ----------------------------- |
| ctrl + shift - b | yabai -m space --layout bsp   |
| ctrl + shift - f | yabai -m space --layout float |
