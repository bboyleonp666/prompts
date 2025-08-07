#!/bin/bash

# Test script to demonstrate the system prompt generator
# This script provides sample inputs to show how the generator works

echo "🧪 Running System Prompt Generator Demo..."
echo "📋 This will demonstrate the generator with sample inputs:"
echo "   • Primary role: system design interview master"
echo "   • Secondary role: best system design article searcher"
echo "   • Expertise level: professional"
echo "   • Communication style: educator"
echo "   • Thinking level: default (Think harder)"
echo "   • Custom requirements: none"
echo "   • Generate with Claude: yes"
echo
echo "🚀 Starting demo in 3 seconds..."
sleep 3

# Use heredoc to provide inputs to the script
./generate_system_prompt.sh << EOF
system design interview master
best system design article searcher
professional
educator
3


demo_system_design_master

EOF

echo
echo "✅ Demo completed!"
echo "📁 Check the generated file in collection/demo_system_design_master.md"