import os
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


@pytest.mark.parametrize("gitlab_dirs", [
    "/srv/gitlab/config",
    "/srv/gitlab/data",
    "/srv/gitlab/logs"
])
def test_gitlab_dirs(host, gitlab_dirs):
    f = host.file(gitlab_dirs)

    assert f.is_directory


def test_gitlab_docker_compose_file(host):
    f = host.file('/srv/gitlab/docker-compose.yml')

    assert f.is_file
    assert f.contains('image: gitlab/gitlab-ce:latest')
