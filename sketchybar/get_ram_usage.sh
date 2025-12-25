#!/bin/bash

# Get total physical memory in bytes
TOTAL_MEM=$(sysctl -n hw.memsize)

# Get page size 
PAGE_SIZE=$(vm_stat | head -1 | awk -F '[(/)]' '{print $2}' | awk '{print $4}')
PAGES_FREE=$(vm_stat | grep "Pages free:" | awk '{print $3}' | sed 's/\.//')
PAGES_WIRED=$(vm_stat | grep "Pages wired down:" | awk '{print $4}' | sed 's/\.//')
PAGES_ACTIVE=$(vm_stat | grep "Pages active:" | awk '{print $3}' | sed 's/\.//')
PAGES_INACTIVE=$(vm_stat | grep "Pages inactive:" | awk '{print $3}' | sed 's/\.//')

# Calculate used memory in bytes
FREE_MEM=$((PAGES_FREE * PAGE_SIZE))
WIRED_MEM=$((PAGES_WIRED * PAGE_SIZE))
ACTIVE_MEM=$((PAGES_ACTIVE * PAGE_SIZE))
INACTIVE_MEM=$((PAGES_INACTIVE * PAGE_SIZE))
USED_MEM=$((WIRED_MEM + ACTIVE_MEM + INACTIVE_MEM))

# Calculate RAM usage percentage
RAM_PERCENT=$(echo "$USED_MEM $TOTAL_MEM" | awk '{printf "%.0f", ($1 / $2) * 100}')

# Echo the result
echo "RAM Usage: $RAM_PERCENT%"