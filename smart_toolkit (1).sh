#!/bin/bash
# Smart Text Editor & File Toolkit Using Shell Scripting
# Menu-driven Bash program with 20 file/text features

while true; do
  clear
  echo "=================================================="
  echo "        SMART TEXT EDITOR & FILE TOOLKIT"
  echo "=================================================="
  printf "  %-27s%s\n" " 1. Create File"          "11. Rename File"
  printf "  %-27s%s\n" " 2. View File"            "12. Move File"
  printf "  %-27s%s\n" " 3. Append Text"          "13. Delete File"
  printf "  %-27s%s\n" " 4. Overwrite File"       "14. Organize by Extension"
  printf "  %-27s%s\n" " 5. Find & Replace"       "15. Sort Lines"
  printf "  %-27s%s\n" " 6. Search Word + Lines"  "16. Remove Duplicate Lines"
  printf "  %-27s%s\n" " 7. Word Counter"         "17. View Permissions"
  printf "  %-27s%s\n" " 8. Line Counter"         "18. Change Permissions"
  printf "  %-27s%s\n" " 9. Character Counter"    "19. File Information"
  printf "  %-27s%s\n" "10. Copy File"            "20. Timestamped Backup"
  echo "   0. Exit"
  echo "=================================================="
  read -p "Enter your choice (0-20): " ch || break

  if [ "$ch" = "0" ]; then echo "Goodbye!"; break; fi

  # Reject anything that is not 1-20
  case $ch in
    [1-9]|1[0-9]|20) ;;
    *) echo "[X] Invalid choice. Please enter 0-20."; read -p "Press Enter to continue..." x; continue ;;
  esac

  # Ask for the folder (option 14) or the file name (all others)
  if [ "$ch" = "14" ]; then
    read -p "Enter folder name: " d
  else
    read -p "Enter file name: " f
    # Every option except "Create" needs an existing file
    if [ "$ch" != "1" ] && [ ! -f "$f" ]; then
      echo "[X] File not found: $f"
      read -p "Press Enter to return to menu..." x
      continue
    fi
  fi

  case $ch in
    1|4)  # Create / Overwrite (ask before replacing an existing file)
      c=y
      [ -f "$f" ] && read -p "'$f' already exists. Overwrite? (y/n): " c
      if [ "$c" = "y" ]; then
        echo "Type your text. Press Ctrl+D on a new line to save:"
        cat > "$f" && echo "[OK] File saved: $f" || echo "[X] Could not write file."
      else
        echo "Cancelled."
      fi ;;

    2)  # View
      echo "-------- $f --------"; cat "$f"; echo "-------- end --------" ;;

    3)  # Append
      echo "Type text to add. Press Ctrl+D on a new line to save:"
      cat >> "$f" && echo "[OK] Text appended." || echo "[X] Append failed." ;;

    5|15|16)  # Find & Replace / Sort / Remove duplicates (uses a temp file)
      t=$(mktemp)
      if [ "$ch" = "5" ]; then
        read -p "Word to find: " a
        read -p "Replace with: " b
        sed "s/$a/$b/g" "$f" > "$t"
      elif [ "$ch" = "15" ]; then
        sort "$f" > "$t"
      else
        sort "$f" | uniq > "$t"
      fi && cat "$t" > "$f" && echo "[OK] File updated." || echo "[X] Operation failed. File unchanged."
      rm -f "$t" ;;

    6)  # Search with line numbers
      read -p "Word to search: " w
      grep -n -i -- "$w" "$f" || echo "[X] '$w' not found." ;;

    7)  echo "Total words     : $(wc -w < "$f")" ;;
    8)  echo "Total lines     : $(wc -l < "$f")" ;;
    9)  echo "Total characters: $(wc -m < "$f")" ;;

    10|11)  # Copy / Rename
      read -p "Enter new file name: " d
      c=y
      [ -e "$d" ] && read -p "'$d' already exists. Overwrite? (y/n): " c
      if [ "$c" != "y" ]; then
        echo "Cancelled."
      elif [ "$ch" = "10" ]; then
        cp "$f" "$d" && echo "[OK] Copied to $d" || echo "[X] Copy failed."
      else
        mv "$f" "$d" && echo "[OK] Renamed to $d" || echo "[X] Rename failed."
      fi ;;

    12)  # Move
      read -p "Destination folder: " d
      mkdir -p "$d" && mv -i "$f" "$d/" && echo "[OK] Moved to $d/" || echo "[X] Move failed." ;;

    13)  # Delete with confirmation
      read -p "Delete '$f' permanently? (y/n): " c
      if [ "$c" = "y" ]; then
        rm "$f" && echo "[OK] File deleted." || echo "[X] Delete failed."
      else
        echo "Cancelled. File not deleted."
      fi ;;

    14)  # Organize files into folders by extension
      if [ ! -d "$d" ]; then
        echo "[X] Folder not found: $d"
      else
        n=0
        for x in "$d"/*; do
          [ -f "$x" ] || continue
          b=${x##*/}; e=${b##*.}
          [ "$e" = "$b" ] && e=others
          mkdir -p "$d/$e" && mv "$x" "$d/$e/" && n=$((n+1))
        done
        echo "[OK] $n file(s) organized by extension."
      fi ;;

    17)  # View permissions
      ls -l "$f"
      stat -c "Permissions: %A (octal %a)   Owner: %U   Group: %G" "$f" ;;

    18)  # Change permissions
      read -p "New permission (e.g. 644, 755): " m
      chmod "$m" "$f" && { echo "[OK] Permissions changed:"; ls -l "$f"; } || echo "[X] Invalid permission." ;;

    19)  # File information
      stat --printf="Name         : %n\nType         : %F\nSize         : %s bytes\nPermissions  : %A (%a)\nOwner        : %U\nLast modified: %y\n" "$f"
      echo "Lines        : $(wc -l < "$f")" ;;

    20)  # Timestamped backup
      b="$f.$(date +%Y%m%d_%H%M%S).bak"
      cp "$f" "$b" && echo "[OK] Backup created: $b" || echo "[X] Backup failed." ;;
  esac

  echo
  read -p "Press Enter to return to menu..." x
done
