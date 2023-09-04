#!/bin/bash

fetch_available_services() {
    local server_config_root service_name service_path services
    server_config_root=$(realpath $(dirname $(dirname $(dirname "$0"))))

    services=()
    find "$server_config_root/docker-configs" -type f -name "*.yaml" | while read -r service_path; do
        // strip the .yaml extension
        service_name="${service_path%.yaml}"
        // strip the path prefix
        service_name="${service_name##*/}"
        services+=("$service_name")
    done

    echo "${services[@]}"
}

_cm_completions()
{
    local cur_word prev_word type_list service_list

    # COMP_WORDS is an array of words in the current command line.
    # COMP_CWORD is the index of the current word (the one the cursor is
    # in). So COMP_WORDS[COMP_CWORD] is the current word.
    cur_word="${COMP_WORDS[COMP_CWORD]}"

    # Previous word on the command line.
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    # Commands for cm
    COMPREPLY=() # Array variable storing the possible completions.
    if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
        # Completing the command after "cm"
        type_list="up enable disable logs"
        COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )
    elif [[ ${#COMP_WORDS[@]} -ge 3 ]]; then
        # Completing the service after "cm up" or similar command
        service_list=$(fetch_available_services)

        COMPREPLY=( $(compgen -W "${service_list}" -- ${cur_word}) )
    fi

    # Generate possible matches and store them in the array variable COMPREPLY
    COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )
}

# Register our completion function.
complete -F _cm_completions cm

