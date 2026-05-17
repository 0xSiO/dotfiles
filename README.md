# luc's dotfiles

Workstation setup & config, managed with [Ansible](https://docs.ansible.com/).

Fresh machine:
```bash
curl -sL https://raw.githubusercontent.com/0xSiO/dotfiles/master/bootstrap.sh | bash
```

Make targets:
```bash
make apply # Apply configuration
make check # Dry run
make lint  # Run lints
make vault # Edit secrets
make deps  # Install Ansible deps
```
