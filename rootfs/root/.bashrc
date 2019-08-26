
export PS1="\\e[32m\\u@\\w $ \\e[0m"
export DIRENV_LOG_FORMAT=

eval "$(direnv hook bash)"

_sandbox_hook() {
  local previous_exit_status=$?;
  if [ -f .envrc ]; then
    envrc_path=$(realpath .envrc)
    envrc_hash=$({ echo "${envrc_path}" ; cat "${envrc_path}" ; } | sha256sum | awk '{print $1}')
    envrc_allow="/root/.config/direnv/allow"
    if ! [ -d "${envrc_allow}" ]; then
      mkdir -p "${envrc_allow}"
    fi
    echo "${envrc_path}" > "${envrc_allow}/${envrc_hash}"
  fi
  return $previous_exit_status;
};

if ! [[ "${PROMPT_COMMAND:-}" =~ _sandbox_hook ]]; then
  PROMPT_COMMAND="_sandbox_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi

function retry {
  local retries=$1
  shift
  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** $count))
    count=$(($count + 1))
    if [ $count -lt $retries ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  return 0
}

export -f retry
