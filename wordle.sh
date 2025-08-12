#!/bin/bash
target="audio"
targeta=(a u d i o)

validate_guess() {
    if [ "${#guess}" -ne 5 ]; then
        return 1
    else
        check=$(grep -iwx $guess ./targets)
        if [ "$check" = "$guess" ]; then
            echo 0    # success
        else
            echo 1    # not found
        fi
    fi
}

create_hints() {
    lettersa=(0 0 0 0 0)
    targetchk=(0 0 0 0 0)
    for i in {0..4}; do
        if  [ ${guessa[$i]} = ${targeta[$i]} ]; then
            lettersa[$i]=1
        fi
    done
    for j in {0..4}; do
        if [ ${lettersa[$j]} -eq 0 ]; then      # if the letter is does not exactly map, check it
            brk=0
            k=0
            while (($k < 5)) && (($brk == 0)); do       # constraints for the word
                if [ ${targetchk[$k]} -eq 0 ]; then     # if this is comparing to an index in the target that has not been satisfied yet
                    if [ ${guessa[$j]} = ${targeta[$k]} ]; then     # and the values are the same
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
        guessa=(${guess:0:1} ${guess:1:1} ${guess:2:1} ${guess:3:1} ${guess:4:1})
        while [ $(validate_guess) -eq 1 ]; do
            read guess
            echo -e "\e[1A\e[K\r"  # bugged, bugs with invalid inputs 12/08
        done
        if [ $guess = $target ]; then
            render_hint
            break
        else
            create_hints $guess
            render_hint
        fi
    done
}

game