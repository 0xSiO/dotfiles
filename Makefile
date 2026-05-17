.PHONY: apply check lint vault deps

apply:
	ansible-playbook playbooks/site.yml -K

check:
	ansible-playbook playbooks/site.yml -K --check --diff

lint:
	ansible-lint playbooks/site.yml

vault:
	ansible-vault edit inventory/group_vars/all/vault.yml

deps:
	ansible-galaxy collection install -r requirements.yml
