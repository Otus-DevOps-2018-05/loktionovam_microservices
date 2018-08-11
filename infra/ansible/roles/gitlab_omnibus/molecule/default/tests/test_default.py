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

@pytest.mark.parametrize("gitlab_ports", [
    "tcp://80",
    "tcp://443",
    "tcp://2222"
])
def test_gitlab_ports(host, gitlab_ports):
    p = host.socket(gitlab_ports)

    assert p.is_listening
