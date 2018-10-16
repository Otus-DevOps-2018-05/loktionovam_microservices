import os
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


@pytest.mark.parametrize("pkgs", [
    "make",
])
def test_autoheal_prerequisite_packages(host, pkgs):
    pkg = host.package(pkgs)

    assert pkg.is_installed


def test_docker_python_modules(host):
    m = host.pip_package.get_packages(pip_path='/usr/bin/pip')

    assert m['docker']['version'] == '3.4.1'


def test_minikube_binary(host):
    f = host.file('/usr/local/bin/minikube')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o755


@pytest.mark.parametrize("dirs", [
    "/root/.minikube",
    "/root/.kube",
])
def test_minikube_conf_dir(host, dirs):
    d = host.file(dirs)

    assert d.exists
    assert d.is_directory


def test_docker_service(host):
    s = host.service('docker')

    assert s.is_running
    assert s.is_enabled


def test_autoheal_docker_container(host):

    assert host.check_output(
        'sudo docker inspect --format \{\{\.State\.Status\}\} autoheal'
    ) == 'running'


def test_autoheal_conf(host):
    f = host.file('/root/autoheal_config.yml')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o400
