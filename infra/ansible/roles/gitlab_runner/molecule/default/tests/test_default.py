import os
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


@pytest.mark.parametrize("gitlab_runner_dirs", [
    "/srv/gitlab-runner/config",
])
def test_gitlab_dirs(host, gitlab_runner_dirs):
    f = host.file(gitlab_runner_dirs)

    assert f.is_directory


def test_gitlab_runner_config(host):
    f = host.file('/srv/gitlab-runner/config/config.toml')

    assert f.is_file
    assert f.contains('name = "my-runner"')
    assert f.contains('executor = "docker"')
    assert f.contains('image = "alpine:latest"')
