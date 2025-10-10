#!/bin/bash
target="audio"
targeta=(a u d i o)
success=0

validate_guess() {
    if [ ${#1} -ne 5 ]; then  # if length != 5
        echo 1
    else
        if [ "$1" = "" ]; then
            echo 1
        else
            check=$(grep -iwx $1 ./targets)  # if it's in the targets
            if [ "$check" = "$1" ]; then
                echo 0    # success
            else
                echo 1    # not found
            fi
        fi
    fi
}

create_hints() {
    lettersa=(0 0 0 0 0)
    targetchk=(0 0 0 0 0)
    for i in {0..4}; do
        if  [ ${guessa[$i]} = ${targeta[$i]} ]; then
            lettersa[$i]=1
            targetchk[$i]=3
        fi
    done
    for j in {0..4}; do
        if [ ${lettersa[$j]} -eq 0 ]; then      # if the letter is does not exactly map, check it
            brk=0
            k=0
            while (($k < 5)) && (($brk == 0)); do       # constraints for the word
                if [ ${targetchk[$k]} -ne 3 ]; then     # if this is comparing to an index in the target that has not been satisfied yet
                    if [ ${guessa[$j]} == ${targeta[$k]} ]; then     # and the values are the same
                        lettersa[j]=2       # assign a 2
                        targetchk[k]=3      # mark the target index as satisfied 
                        brk=$((brk+1))      # break
                    fi
                fi
                k=$((k+1))
            done
        fi
    done
}

render_hint() {
    hint=""
    YELLOW="\033[1;33m"
    GREEN="\033[1;32m"
    NONE="\033[0m"
    for i in {0..4}; do
        if [ ${lettersa[$i]} -eq 1 ]; then
            hint="${hint}${GREEN}${guessa[$i]}${NONE}"
        elif [ ${lettersa[$i]} -eq 2 ]; then
            hint="${hint}${YELLOW}${guessa[$i]}"
        else
            hint="${hint}${NONE}${guessa[$i]}"
        fi
    done
        echo -e "\e[1A\e[K${hint}"
}

game() {
    #generate the word
    for i in {0..4}; do
        read guess
        while [ $(validate_guess "$guess") -eq 1 ]; do
            read guess
        done    
        guessa=(${guess:0:1} ${guess:1:1} ${guess:2:1} ${guess:3:1} ${guess:4:1})
        if [ "$guess" = "$target" ]; then  # if the guess is correct
            create_hints
            render_hint
            success=1
            break
        else
            create_hints
            render_hint
        fi
    done
    if [ $success -ne 1 ]; then
        echo -e "The word was ${target}"
    fi
}
game