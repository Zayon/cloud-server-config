#!/bin/bash

fetch_available_services() {
    local service_name service_path
    local -a services # Declare services as an indexed array

    if [[ -z "${SERVER_CONFIG_ROOT:-}" ]]; then
        echo "SERVER_CONFIG_ROOT is not set"
        exit 1
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
    local cur_word prev_word command_list service_list

    cur_word="${COMP_WORDS[COMP_CWORD]}"
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    COMPREPLY=()

    # Commands for cm
    if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
        # Completing the command after "cm"
        command_list="up edit dir logs"
        COMPREPLY=( $(compgen -W "${command_list}" -- ${cur_word}) )
        return 0
    fi

    if [[ ${#COMP_WORDS[@]} -ge 3 ]]; then
        service_list=$(fetch_available_services)
        COMPREPLY=( $(compgen -W "${service_list}" -- ${cur_word}) )

        return 0
    fi
}

# Register our completion function.
complete -F _cm_completions cm

