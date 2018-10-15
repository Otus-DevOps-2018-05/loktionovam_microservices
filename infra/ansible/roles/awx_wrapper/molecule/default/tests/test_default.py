import os
import testinfra.utils.ansible_runner

home = '/home/vagrant'
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_awx_cli_config(host):
    f = host.file(home + '/.tower_cli.cfg')

    assert f.exists
    assert f.mode == 0o400


def test_awx_web(host):
    a = host.ansible(
        "uri",
        "url=http://localhost follow_redirects=none",
        check=False
        )

    assert a["status"] == 200


def test_extra_vars_file(host):
    f = host.file(home + '/extra_vars.yml')
    assert f.contains("microservices_make_target: run")
