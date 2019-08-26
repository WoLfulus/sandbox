
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
