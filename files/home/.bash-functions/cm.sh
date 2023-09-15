cm() {

# Function to display usage instructions.
usage() {
    echo "cm - Container Manager"
    echo "Usage: cm COMMAND [COMMAND_OPTIONS] SERVICE(S)"
    echo "Commands:"
    echo "  help      Show this help message"
    echo "  up        Update / Start the service(s)"
    echo "  restart   Restart the service(s)"
    echo "  edit      Edit service configuration"
    echo "  dir       Move to the service directory"
    echo "  logs      Show nginx service logs (from swag)"
}

if [[ -z "${SERVER_CONFIG_ROOT:-}" ]]; then
    SERVER_CONFIG_ROOT="$(realpath $(dirname $(dirname "$0")))"
fi

if [[ -z "${CONTAINERS_DATA_DIR:-}" ]]; then
    CONTAINERS_DATA_DIR="$HOME/containers_data"
fi

###
### UP COMMAND ###
###
up_usage() {
    echo "Usage:   cm up [OPTIONS] SERVICE(S) [OPTIONS]"
    echo ""
    echo "  Update / Start the service(s)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --verbose   Show verbose output"
    echo "  -r, --recreate  Recreate the service(s)"
}

up_command() {
    local verbose=false
    local recreate=""
    local services
    local command_args=($@)

    for i in "${!command_args[@]}"; do
        if [ "${command_args[i]}" == "--help" ] || [ "${command_args[i]}" == "-h" ]; then
            up_usage
            return 0
        fi

        if [ "${command_args[i]}" == "--verbose" ] || [ "${command_args[i]}" == "-v" ]; then
            verbose=true
            unset 'command_args[i]'
        fi

        if [ "${command_args[i]}" == "--recreate" ] || [ "${command_args[i]}" == "-r" ]; then
            recreate="--force-recreate"
            unset 'command_args[i]'
        fi
    done

    services="${command_args[@]}"

    # split the services into an array
    IFS=' ' read -r -a services <<< "$services"

    for service in "${services[@]}"; do
        if [ "$verbose" == "true" ]; then
            echo "Starting service $service with command: "
            echo "docker-compose -f $SERVER_CONFIG_ROOT/docker-configs/$service.yaml up $recreate -d"
        fi

        docker compose -f "$SERVER_CONFIG_ROOT/docker-configs/$service.yaml" up $recreate -d
    done
}

###
### restart COMMAND ###
###
restart_usage() {
    echo "Usage:   cm restart [OPTIONS] SERVICE(S) [OPTIONS]"
    echo ""
    echo "  Restart the service(s)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --verbose   Show verbose output"
}

restart_command() {
    local verbose=false
    local services
    local command_args=($@)

    for i in "${!command_args[@]}"; do
        if [ "${command_args[i]}" == "--help" ] || [ "${command_args[i]}" == "-h" ]; then
            restart_usage
            return 0
        fi

        if [ "${command_args[i]}" == "--verbose" ] || [ "${command_args[i]}" == "-v" ]; then
            verbose=true
            unset 'command_args[i]'
        fi
    done

    services="${command_args[@]}"

    # split the services into an array
    IFS=' ' read -r -a services <<< "$services"

    for service in "${services[@]}"; do
        if [ "$verbose" == "true" ]; then
            echo "restarting service $service with command: "
            echo "docker-compose -f $SERVER_CONFIG_ROOT/docker-configs/$service.yaml restart $service"
        fi

        docker compose -f "$SERVER_CONFIG_ROOT/docker-configs/$service.yaml" restart "$service"
    done
}

###
### EDIT COMMAND ###
###
edit_usage() {
    echo "Usage:   cm edit [OPTIONS] SERVICE [OPTIONS]"
    echo ""
    echo "  Edit service configuration"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -s, --secrets   Edit the service secrets"
}

edit_command() {
    local command_args=($@)
    local edit_secrets=false
    local service

    for i in "${!command_args[@]}"; do
        if [ "${command_args[i]}" == "--help" ] || [ "${command_args[i]}" == "-h" ]; then
            edit_usage
            return 0
        fi

        if [ "${command_args[i]}" == "--secrets" ] || [ "${command_args[i]}" == "-s" ]; then
            edit_secrets=true
            unset 'command_args[i]'
        fi
    done

    # reindex array
    command_args=("${command_args[@]}")
    # get remaining element
    service="${command_args[0]}"

    if [ "$edit_secrets" == "true" ]; then
        sensible-editor "$SERVER_CONFIG_ROOT/docker-configs/secrets/$service.secrets"
        return 0
    fi

    sensible-editor "$SERVER_CONFIG_ROOT/docker-configs/$service.yaml"
}

###
### DIR COMMAND ###
###
dir_usage() {
    echo "Usage:   cm dir [OPTIONS] SERVICE"
    echo ""
    echo "  Move to the service directory"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
}

dir_command() {
    local service=$1

    if [ -z "$service" ]; then
        pushd "$SERVER_CONFIG_ROOT" > /dev/null
        return 0
    fi

    if [ "$service" == "--help" ] || [ "$service" == "-h" ]; then
        dir_usage
        return 0
    fi

    if [ ! -d "$CONTAINERS_DATA_DIR/$service" ]; then
        echo "Service $service does not exist"
        return 1
    fi

    pushd "$CONTAINERS_DATA_DIR/$service" > /dev/null
}

###
### LOGS COMMAND ###
###
logs_usage() {
    echo "Usage:   cm logs [OPTIONS] SERVICE [OPTIONS]"
    echo ""
    echo "  Show nginx service logs (from swag)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
}

logs_command() {
    local service
    local command_args=($@)
    local follow=""

    for i in "${!command_args[@]}"; do
        if [ "${command_args[i]}" == "--help" ] || [ "${command_args[i]}" == "-h" ]; then
            logs_usage
            return 0
        fi

        if [ "${command_args[i]}" == "--follow" ] || [ "${command_args[i]}" == "-f" ]; then
            follow="-F"
            unset 'command_args[i]'
        fi
    done

    # if command_args has more than one element left
    if [ "${#command_args[@]}" -gt 1 ]; then
        echo "Too many arguments, only 1 service supported"
        logs_usage
        return 1
    fi

    # reindex array
    command_args=("${command_args[@]}")
    # get remaining element
    service="${command_args[0]}"

    if [ service == "swag" ]; then
        docker logs swag
        return 0
    fi

    tail $follow "$CONTAINERS_DATA_DIR/swag/log/nginx/${service}_access.log" "$CONTAINERS_DATA_DIR/swag/log/nginx/${service}_error.log"
}

###
### GLOBAL SCRIPT ###
###

command=$1
shift 1
command_args=$@

# Handle commands.
case $command in
    help)
        usage
        ;;
    up)
        up_command "$command_args"
        ;;
    restart)
        restart_command "$command_args"
        ;;
    edit)
        edit_command "$command_args"
        ;;
    dir)
        dir_command "$command_args"
        ;;
    logs)
        logs_command "$command_args"
        ;;
    *)
        echo "Invalid command: $command"
        usage
        return 1
        ;;
esac

return 0
}

__cm_fetch_available_services() {
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
    local cur_word prev_word command_list service_list

    cur_word="${COMP_WORDS[COMP_CWORD]}"
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    COMPREPLY=()

    # Commands for cm
    if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
        # Completing the command after "cm"
        command_list="help up restart edit dir logs"
        COMPREPLY=( $(compgen -W "${command_list}" -- ${cur_word}) )
        return 0
    fi

    if [[ ${#COMP_WORDS[@]} -ge 3 ]]; then
        service_list=$(__cm_fetch_available_services)
        COMPREPLY=( $(compgen -W "${service_list}" -- ${cur_word}) )

        return 0
    fi
}

# Register our completion function.
complete -F _cm_completions cm

