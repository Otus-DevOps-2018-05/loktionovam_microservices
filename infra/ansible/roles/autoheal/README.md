autoheal
=========

Build and run openshift autoheal docker container

Requirements
------------

none

Role Variables
--------------

- Role environment (local/stage/prod)

```yaml
env: local
```

- Additional packages and python modules which used to build and run autoheal docker image

```yaml
autoheal_prerequisite_packages:
  - make

autoheal_python_modules:
  - { module: docker, version: 3.4.1 }
```

- Branch to checkout autoheal repo

```yaml
autoheal_repo_version: monitoring-2
```

- Image version to start

```yaml
autoheal_image_version: 4.0.0-0.9.0
```

- Path to autoheal credendials `autoheal_awx_username`, `autoheal_awx_password`

```yaml
autoheal_credentials: ~/.ansible/autoheal_credentials.yml
```

- AWX address

```yaml
autoheal_awx_address: http://localhost/api
```

- Define this variables in the `autoheal_credentials` file

```yaml
autoheal_awx_username: "{{ mandatory }}"
autoheal_awx_password: "{{ mandatory }}"
```

- Main autoheal configuration

```yaml
autoheal_config:
  awx:
    address: "{{ autoheal_awx_address }}"
    credentials:
      username: "{{ autoheal_awx_username }}"
      password: "{{ autoheal_awx_password }}"
    project: otus
  rules:
    - metadata:
        name: start-services
      labels:
        alertname: ".*InstanceDown.*"
      awxJob:
        template: "run_microservices"
```

Dependencies
------------

- geerlingguy.docker

- geerlingguy.pip

Example Playbook
----------------

```yaml
    - hosts: servers
      roles:
         - { role: autoheal, autoheal_awx_address: http://awx.example.com/api }
```

License
-------

BSD

Author Information
------------------

Aleksandr Loktionov
