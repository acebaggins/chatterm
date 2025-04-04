### CHAT FUNCTIONALITY - DO NOT MODIFY

temp_file=$(mktemp -p /tmp)
CHATTERM_DEFAULT_MODEL="llama3.2"

show_chaterm_chat(){
  echo "$(cat $temp_file)"
}

clear_chatterm_chat(){
  echo -n "" > $temp_file
}

process_quoted_text() {
  local job_control_state=$(set -o | grep 'monitor' | awk '{print $2}')
  set +m
  local quoted_text="$1"

  # Remove the surrounding quotes
  quoted_text="${quoted_text#\"}"
  quoted_text="${quoted_text%\"}"
    
  # Set up spinner frames
  local -a spinner_frames
  spinner_frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  local frames=${#spinner_frames[@]}
  
  local output_file=$(mktemp -p /tmp);

  local evaluated_text=$(bash -c "echo \"$quoted_text\"")

  echo -e "\nHuman: $evaluated_text" >> "$temp_file"
  local conversation=$(cat $temp_file)

  local model=${CHATTERM_MODEL:-$CHATTERM_DEFAULT_MODEL}

  (ollama run "$model" "$(cat $temp_file)" > "$output_file" 2>/dev/null) &
  local ollama_pid=$!

  # hides the cursor
  echo -ne "\n\033[?25l"

  while kill -0 $ollama_pid 2>/dev/null; do
    echo -ne "\r${spinner_frames[$i]}"
    sleep 0.1
    i=$(( (i+1) % frames ))
  done
  
  local final_output=$(cat "$output_file")
  echo "Assistant: $final_output" >> $temp_file
  
  rm -f "$output_file"

  # clear cursor to the end of the line
  echo -ne "\r\033[K"

  # the trailing \n is important because without it the output just disappears, or the last line, anyway.
  echo -e "$final_output\n"
  
  # show cursor
  echo -ne "\033[?25h"

  if [[ "$job_control_state" == "on" ]]; then
    set -m
  fi
}

HIST_TEMP=""

handle_quotes() {
  local buffer="$BUFFER"
  
  # Check if it's a quoted text for Ollama
  if [[ "$buffer" =~ ^\" ]]; then
    # Create temp history file to prevent saving to main history
    HIST_TEMP=$(mktemp -p /tmp history.XXXXXX)
    # Redirect history to temp file
    fc -p "$HIST_TEMP"
    
    # If already a complete quote, process it
    if [[ "$buffer" =~ \"$ && ! "$buffer" =~ [^\\]\".*\" ]]; then
      zle -I  # Clear the line
      process_quoted_text "$buffer"
      BUFFER=""
    else
      # If incomplete quote, add closing quote and process
      if [[ ! "$buffer" =~ \"$ ]]; then
        buffer="${buffer}\""
      fi
      zle -I  # Clear the line
      process_quoted_text "$buffer"
      BUFFER=""
    fi
    
    # Restore normal history
    fc -P
    # Clean up temp file
    [[ -f "$HIST_TEMP" ]] && rm -f "$HIST_TEMP"
    HIST_TEMP=""
    
    return 0
  else
    # Not a quoted command, continue with normal execution
    zle .accept-line
  fi
}

# Create widget for quote handling on Enter
zle -N accept-line handle_quotes

# Bind to Enter key
bindkey "^M" accept-line


