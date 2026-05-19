# Validation Strategy

## Validation tiers

- Tier 1: Fast syntax checks for touched scripts
- Tier 2: Shell linting for touched shell files
- Tier 3: Broader install/uninstall smoke checks in a safe environment

## Concrete commands

- Tier 1: `bash -n install.sh uninstall.sh`
- Tier 2: `shellcheck install.sh uninstall.sh .terminal terminal/*.sh` (if available)
- Tier 3: Run `./install.sh` and `./uninstall.sh` in a container/VM for risky or cross-cutting changes
