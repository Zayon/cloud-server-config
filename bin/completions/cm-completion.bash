#!/bin/bash

# Exit on error, uninitialized variable, or error in a pipeline.
set -euo pipefail

fetch_available_services() {
    local service_name service_path
    local -a services # Declare services as an indexed array

    if [[ -z "${SERVER_CONFIG_ROOT:-}" ]]; then
        echo "SERVER_CONFIG_ROOT is not set"
        return 1
    fi

    while read -r service_path; do
        # strip the .yaml extension
        service_name="${service_path%.yaml}"
        # strip the path prefix
        service_name="${service_name##*/}"
        services+=("$service_name")
    done < <(find "$SERVER_CONFIG_ROOT/docker-configs" -type f -name "*.yaml")

    echo "${services[@]}"
}


_cm_completions()
{
    local cur_word prev_word type_list service_list

    # Initialize COMPREPLY array
    COMPREPLY=()

    # COMP_WORDS is an array of words in the current command line.
    cur_word="${COMP_WORDS[COMP_CWORD]}"

    # Previous word on the command line.
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    # Commands for cm
    if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
        # Completing the command after "cm"
        type_list="up enable disable logs"
        COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )
    elif [[ ${#COMP_WORDS[@]} -ge 3 ]]; then
        # If SERVER_CONFIG_ROOT is not set, return without doing anything.
        if [[ -z "${SERVER_CONFIG_ROOT:-}" ]]; then
            return 0
        fi

        service_list=$(fetch_available_services)
        # Completing the service after "cm up" or similar command
        COMPREPLY=( $(compgen -W "${service_list}" -- ${cur_word}) )
    fi
}

# Register our completion function.
complete -F _cm_completions cm

