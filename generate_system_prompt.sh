#!/bin/bash

# Interactive System Prompt Generator
# Only asks questions for underscore fields in the template

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
TEMPLATE_FILE="system_prompt_template.md"
COLLECTION_DIR="collection"
TEMP_FILE=$(mktemp)

print_color() {
    printf "${1}${2}${NC}\n"
}

print_header() {
    echo
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
    print_color "$WHITE" "  $1"
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
    echo
}

get_input() {
    local prompt=$1
    local var_name=$2
    local allow_empty=${3:-false}
    local input
    
    while true; do
        printf "${YELLOW}${prompt}${NC} "
        read -r input
        
        if [[ -n "$input" ]] || [[ "$allow_empty" == "true" ]]; then
            eval "$var_name='$input'"
            break
        else
            print_color "$RED" "❌ This field is required. Please enter a value." >&2
        fi
    done
}

get_yes_no() {
    local input
    
    while true; do
        read -r input
        
        case "${input:-y}" in
            [Yy]|[Yy][Ee][Ss]) echo "true"; return ;;
            [Nn]|[Nn][Oo]) echo "false"; return ;;
            *) print_color "$RED" "❌ Please enter 'y' for yes or 'n' for no." ;;
        esac
    done
}


check_prerequisites() {
    [[ -f "$TEMPLATE_FILE" ]] || { print_color "$RED" "❌ Template file '$TEMPLATE_FILE' not found!" >&2; exit 1; }
    mkdir -p "$COLLECTION_DIR"
    command -v claude &> /dev/null || { print_color "$RED" "❌ Claude CLI not found!" >&2; exit 1; }
}

create_filename() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '_'
}

main() {
    print_header "🚀 System Prompt Generator"
    print_color "$BLUE" "This script creates customized system prompts from a template."
    print_color "$BLUE" "You'll be asked to provide:"
    echo "  • Primary & secondary roles"
    echo "  • Expertise level & communication style" 
    echo "  • Thinking level (Think/Think hard/Think harder [default]/Ultrathink)"
    echo "  • Custom requirements (optional)"
    echo "  • Output filename"
    echo
    
    check_prerequisites
    
    # Collect underscore field information
    print_header "📝 Role Information"
    get_input "🎭 Primary role:" primary_role
    get_input "🎭 Secondary role (optional):" secondary_role true
    get_input "🎓 Expertise level:" expertise_level
    get_input "💬 Communication style:" communication_style
    
    print_header "🧠 Thinking Level"
    echo "  1. Think (basic)"
    echo "  2. Think hard (deeper)"
    print_color "$GREEN" "  3. Think harder (comprehensive) *[DEFAULT]*"
    echo "  4. Ultrathink (maximum)"
    
    while true; do
        printf "${YELLOW}Select thinking level - Enter choice (1-4) [default: 3]:${NC} "
        read -r choice
        
        if [[ -z "$choice" ]]; then
            choice=3
        fi
        
        if [[ "$choice" =~ ^[1-4]$ ]]; then
            thinking_level=$((choice - 1))
            break
        else
            print_color "$RED" "❌ Please enter a number between 1 and 4."
        fi
    done
    
    print_header "🎨 Custom Requirements"
    get_input "📝 Custom requirement 1 (optional):" custom_req1 true
    get_input "📝 Custom requirement 2 (optional):" custom_req2 true
    
    # Generate filename
    filename=$(create_filename "$primary_role")
    print_color "$BLUE" "Suggested filename: ${filename}.md"
    get_input "📁 Filename (without .md, or press Enter for suggested):" custom_filename true
    
    if [[ -n "$custom_filename" ]]; then
        filename="$custom_filename"
    fi
    
    output_file="$COLLECTION_DIR/${filename}.md"
    
    if [[ -f "$output_file" ]]; then
        printf "${YELLOW}⚠️ File '$output_file' exists. Overwrite? [Y/n]:${NC} "
        overwrite=$(get_yes_no)
        if [[ "$overwrite" != "true" ]]; then
            print_color "$RED" "❌ Cancelled."
            exit 1
        fi
    fi
    
    # Create customized template
    print_header "🔧 Processing Template"
    cp "$TEMPLATE_FILE" "$TEMP_FILE"
    
    # Replace underscore fields
    sed -i.bak "s/- \\*\\*Primary role:\\*\\* ___________________________/- **Primary role:** $primary_role/" "$TEMP_FILE"
    sed -i.bak "s/- \\*\\*Secondary role (if any):\\*\\* ___________________________/- **Secondary role:** ${secondary_role:-N\/A}/" "$TEMP_FILE"
    sed -i.bak "s/- \\*\\*Expertise level:\\*\\* ___________________________/- **Expertise level:** $expertise_level/" "$TEMP_FILE"
    sed -i.bak "s/- \\*\\*Communication style:\\*\\* ___________________________/- **Communication style:** $communication_style/" "$TEMP_FILE"
    
    # Handle custom requirements
    if [[ -n "$custom_req1" ]]; then
        sed -i.bak "s/- Custom requirement 1: ___________________________/- Custom requirement 1: $custom_req1/" "$TEMP_FILE"
    else
        sed -i.bak "/- Custom requirement 1: ___________________________/d" "$TEMP_FILE"
    fi
    
    if [[ -n "$custom_req2" ]]; then
        sed -i.bak "s/- Custom requirement 2: ___________________________/- Custom requirement 2: $custom_req2/" "$TEMP_FILE"
    else
        sed -i.bak "/- Custom requirement 2: ___________________________/d" "$TEMP_FILE"
    fi
    
    # Update thinking level selection
    sed -i.bak 's/- \[x\] Think harder (comprehensive analysis) \*\[DEFAULT\]\*/- [ ] Think harder (comprehensive analysis)/' "$TEMP_FILE"
    case $thinking_level in
        0) sed -i.bak 's/- \[ \] Think (basic reasoning)/- [x] Think (basic reasoning) *[SELECTED]*/' "$TEMP_FILE" ;;
        1) sed -i.bak 's/- \[ \] Think hard (deeper analysis)/- [x] Think hard (deeper analysis) *[SELECTED]*/' "$TEMP_FILE" ;;
        2) sed -i.bak 's/- \[ \] Think harder (comprehensive analysis)/- [x] Think harder (comprehensive analysis) *[SELECTED]*/' "$TEMP_FILE" ;;
        3) sed -i.bak 's/- \[ \] Ultrathink (maximum depth reasoning)/- [x] Ultrathink (maximum depth reasoning) *[SELECTED]*/' "$TEMP_FILE" ;;
    esac
    
    rm -f "$TEMP_FILE.bak"
    
    # Generate with Claude
    print_header "🤖 Generate with Claude"
    printf "${YELLOW}🚀 Generate system prompt with Claude now? [Y/n]:${NC} "
    generate_prompt=$(get_yes_no)
    
    if [[ "$generate_prompt" == "true" ]]; then
        print_color "$BLUE" "🔄 Processing with Claude..."
        claude_command="claude 'You are a system prompt generator. Convert the template @$TEMPLATE_FILE into a complete, actionable system prompt. Output ONLY the final system prompt in markdown format - do not ask for permission, do not explain what you are doing, just create the prompt directly. Include all the role details, features, and requirements specified in the template.'"
        
        if eval "$claude_command" > "$output_file"; then
            print_color "$GREEN" "✅ System prompt generated!"
        else
            print_color "$RED" "❌ Claude failed. Saving template instead."
            cp "$TEMP_FILE" "$output_file"
        fi
    else
        cp "$TEMP_FILE" "$output_file"
        print_color "$GREEN" "✅ Template saved."
    fi
    
    rm -f "$TEMP_FILE"
    
    # Summary
    print_header "🎉 Complete"
    print_color "$GREEN" "📁 File: $output_file"
    print_color "$BLUE" "🎭 Role: $primary_role"
    case $thinking_level in
        0) level_name="Think" ;;
        1) level_name="Think hard" ;;
        2) level_name="Think harder" ;;
        3) level_name="Ultrathink" ;;
    esac
    print_color "$BLUE" "🧠 Level: $level_name"
}

trap 'print_color "$RED" "❌ Interrupted. Cleaning up..." >&2; rm -f "$TEMP_FILE" "$TEMP_FILE.bak"; exit 1' INT TERM

main "$@"