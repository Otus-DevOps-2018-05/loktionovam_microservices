reddit_monolith
=========

Deploy reddit monolith application via docker compose

Requirements
------------

- docker-ce
- docker-compose

Role Variables
--------------

- Define `reddit_monolith_docker_registry_user` in the `reddit_monolith_credentials` file

```yaml
reddit_monolith_credentials: ~/.ansible/reddit_monolith_credentials.yml
reddit_monolith_docker_registry_user: "{{ mandatory }}"
```

- Docker image repository and tag

```yaml
reddit_monolith_docker_version: latest

reddit_monolith_docker_image: "{{ reddit_monolith_docker_registry_user }}/reddit:{{ reddit_monolith_docker_version }}"
```

- Reddit application port

```yaml
reddit_monolith_port: 9292
```

- Docker compose configuration which used by docker_service ansible module

```yaml
reddit_monolith_docker_compose:
  version: '3'
  services:
    post_db:
      image: mongo:3.2
      volumes:
        - post_db:/data/db
      networks:
        - back_net
    reddit:
      image: "{{ reddit_monolith_docker_image }}"
      restart: always
      ports:
        - "{{ reddit_monolith_port }}:{{ reddit_monolith_port }}/tcp"
      networks:
        - back_net
        - front_net
      environment:
        DATABASE_URL: 'post_db://mongo/user_posts'
  volumes:
    post_db:
  networks:
    back_net:
    front_net:
```

Dependencies
------------

- docker_host

Example Playbook
----------------

```yaml

    - hosts: docker-servers
      roles:
         - { role: reddit_monolith, reddit_monolith_docker_version: gitlab-ci-2-dev }
```

License
-------

BSD

Author Information
------------------

Aleksandr Loktionov
