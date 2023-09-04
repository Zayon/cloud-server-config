#!/bin/bash

_cm_completions()
{
    local cur_word prev_word type_list

    # COMP_WORDS is an array of words in the current command line.
    # COMP_CWORD is the index of the current word (the one the cursor is
    # in). So COMP_WORDS[COMP_CWORD] is the current word.
    cur_word="${COMP_WORDS[COMP_CWORD]}"

    # Previous word on the command line.
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    # Commands for cm
    COMPREPLY=() # Array variable storing the possible completions.
    case "${prev_word}" in
        cm)
            type_list="up logs"
            ;;
        *)
            type_list=""
            ;;
    esac

    # Generate possible matches and store them in the array variable COMPREPLY
    COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )
}

# Register our completion function.
complete -F _cm_completions cm
