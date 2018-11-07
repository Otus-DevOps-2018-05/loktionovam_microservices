Role Name
=========

Role install AWX, configure organization, project, credentials and job template

Requirements
------------

none

Role Variables
--------------

- Define environment here (local, stage, prod)

```yaml
env: local
```

- Python modules with versions

```yaml
awx_wrapper_python_modules:
  - { module: docker, version: 3.4.1 }
  - { module: ansible-tower-cli, version: 3.3.0 }
```

- AWX version

```yaml
awx_wrapper_awx_version: 2.0.0
```

- Postgresql data directory path

```yaml
awx_wrapper_postgres_data_dir: /var/lib/pgdocker
```

- Path to role credentials file

```yaml
awx_wrapper_credentials: ~/.ansible/awx_wrapper_credentials.yml
```

- Path (on remote machine) to awx cli configuration file

```yaml
awx_cli_config: ~/.tower_cli.cfg
```

- Host parameter in tower cli configuration

```yaml
awx_wrapper_cli_host: http://localhost
```

- Setup these variables in `awx_wrapper_credentials` path

```yaml
awx_wrapper_cli_username: "{{ mandatory }}"
awx_wrapper_cli_password: "{{ mandatory }}"
awx_wrapper_gce_username: "{{ mandatory }}"
awx_wrapper_gce_project_name: "{{ mandatory }}"
```

- Main AWX configuration - organization, project, credentials, job template

```yaml
awx_wrapper_project_name: otus
awx_wrapper_project_description: homework
awx_wrapper_scm_type: git
awx_wrapper_scm_url: https://github.com/Otus-DevOps-2018-05/loktionovam_microservices.git
awx_wrapper_scm_branch: monitoring-2
awx_wrapper_tower_verify_ssl: false

awx_wrapper_organization_name: otus

awx_wrapper_gce_credential_name: gce

awx_wrapper_machine_credential_name: docker-user
awx_wrapper_machine_credential_user: docker-user

awx_wrapper_inventory_name: gce

awx_wrapper_inventory_source_name: gce
```

Dependencies
------------

- geerlingguy.awx
- geerlingguy.git
- geerlingguy.ansible
- geerlingguy.docker
- geerlingguy.pip
- geerlingguy.nodejs

Example Playbook
----------------

```yaml
    - hosts: servers
      roles:
         - { role: awx_wrapper }
```

License
-------

BSD

Author Information
------------------

Aleksandr Loktionov
