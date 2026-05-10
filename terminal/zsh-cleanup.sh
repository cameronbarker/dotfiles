# Remove stale hooks/functions from prior versions of this file so that
# re-sourcing in an existing shell fully reverts old behavior. If a previous
# version's capture was mid-flight (stdout/stderr redirected to a tee pipe),
# restore the original fds BEFORE removing the precmd that would have done so —
# otherwise the shell would be left permanently writing to a pipe.
if [[ -n "${ZSH_VERSION:-}" ]]; then
  if [[ "${_pb_capture_active:-0}" == "1" ]]; then
    if [[ -n "${_pb_orig_stdout_fd:-}" ]]; then
      exec 1>&${_pb_orig_stdout_fd} {_pb_orig_stdout_fd}>&-
    fi
    if [[ -n "${_pb_orig_stderr_fd:-}" ]]; then
      exec 2>&${_pb_orig_stderr_fd} {_pb_orig_stderr_fd}>&-
    fi
  fi
  preexec_functions=("${(@)preexec_functions:#_pb_preexec_capture}")
  precmd_functions=("${(@)precmd_functions:#_pb_precmd_capture}")
  unfunction _pb_preexec_capture 2>/dev/null
  unfunction _pb_precmd_capture 2>/dev/null
  unset _pb_capture_active _pb_orig_stdout_fd _pb_orig_stderr_fd 2>/dev/null
fi
