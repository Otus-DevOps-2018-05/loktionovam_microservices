gitlab
=========

gitlab omnibus role

Requirements
------------

docker-ce, docker-compose

Role Variables
--------------

* Gitlab url configuration

```yaml
gitlab_hostname: "{{ inventory_hostname }}"
gitlab_domain: localdomain
gitlab_external_url: http://{{ gitlab_hostname }}.{{ gitlab_domain }}
```

* Gilab volumes directory

```yaml
gitlab_dir: /srv/gitlab
gitlab_config_dir: "{{ gitlab_dir }}/config"
gitlab_data_dir: "{{ gitlab_dir }}/data"
gitlab_log_dir: "{{ gitlab_dir }}/logs"
```

* docker-compose configuration variable which will be saved as docker-compose.yml file

```yaml
gitlab_docker_compose:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: '{{ gitlab_hostname }}'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url '{{ gitlab_external_url }}'
    ports:
      - '80:80'
      - '443:443'
      - '2222:22'
    volumes:
      - '{{ gitlab_config_dir }}:/etc/gitlab'
      - '{{ gitlab_log_dir }}:/var/log/gitlab'
      - '{{ gitlab_data_dir }}:/var/opt/gitlab'
```

Dependencies
------------

docker_host

Example Playbook
----------------

```yaml
    - hosts: gitlab-servers
      roles:
         - { role: gitlab_omnibus, gitlab_domain: example.com }
```

License
-------

BSD

Author Information
------------------

Aleksandr Loktionov
