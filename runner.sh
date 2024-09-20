#!/bin/bash

clear
echo "==============================="
echo "Script Written by: Madiha Sehar 22BSCYS022"
echo "This tool compares the execution times of 'int 0x80' and 'syscall'."
echo "==============================="

# Ask the user to enter the file names for program1 and program2
read -p "Enter the filename for program1 (int 0x80, e.g., program1.asm): " program1
read -p "Enter the filename for program2 (syscall, e.g., program2.asm): " program2

# Check if the files exist
if [ ! -f "$program1" ]; then
    echo "Error: $program1 not found!"
    exit 1
fi

if [ ! -f "$program2" ]; then
    echo "Error: $program2 not found!"
    exit 1
fi

# Assemble and link the programs
nasm -f elf64 "$program1" -o "${program1%.asm}.o"
if [ $? -ne 0 ]; then
    echo "Error: Failed to assemble $program1"
    exit 1
fi

nasm -f elf64 "$program2" -o "${program2%.asm}.o"
if [ $? -ne 0 ]; then
    echo "Error: Failed to assemble $program2"
    exit 1
fi

ld -o "${program1%.asm}" "${program1%.asm}.o"
ld -o "${program2%.asm}" "${program2%.asm}.o"

# Initialize result files
> result_program1.txt
> result_program2.txt

# Run each program 10 times and save the results
for i in {1..10}
do
    echo "Running cycle $i..."
    (time ./"${program1%.asm}" > /dev/null) 2>> result_program1.txt
    (time ./"${program2%.asm}" > /dev/null) 2>> result_program2.txt
done

# Extract user times from result files
user_time_program1=$(grep 'user' result_program1.txt | awk '{print $2}' | sed 's/[^0-9.]//g' | awk '{s+=$1} END {print s}')
user_time_program2=$(grep 'user' result_program2.txt | awk '{print $2}' | sed 's/[^0-9.]//g' | awk '{s+=$1} END {print s}')

# Check if the times are empty and handle the error
if [ -z "$user_time_program1" ]; then
    echo "Error: No user time found for ${program1%.asm}"
    exit 1
fi

if [ -z "$user_time_program2" ]; then
    echo "Error: No user time found for ${program2%.asm}"
    exit 1
fi

# Calculate average user time
avg_user_time_program1=$(echo "scale=3; $user_time_program1 / 10" | bc)
avg_user_time_program2=$(echo "scale=3; $user_time_program2 / 10" | bc)

# Display user times and averages
echo "User time for ${program1%.asm} (int 0x80): $avg_user_time_program1 seconds"
echo "User time for ${program2%.asm} (syscall): $avg_user_time_program2 seconds"

# Calculate percentage difference
if [ $(echo "$avg_user_time_program2 > $avg_user_time_program1" | bc) -eq 1 ]; then
    faster_program="${program1%.asm} (int 0x80)"
    slower_program="${program2%.asm} (syscall)"
    
    diff=$(echo "scale=3; (($avg_user_time_program2 - $avg_user_time_program1)  * 100) / $avg_user_time_program2" | bc)
else
    faster_program="${program2%.asm} (syscall)"
    slower_program="${program1%.asm} (int 0x80)"
    diff=$(echo "scale=3; (($avg_user_time_program1 - $avg_user_time_program2) * 100) / $avg_user_time_program1" | bc)
fi

# Display percentage difference
echo "$faster_program is $(echo "scale=2; $diff" | bc)% faster than $slower_program"

