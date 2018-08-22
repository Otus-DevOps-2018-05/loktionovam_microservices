import os
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


@pytest.mark.parametrize("reddit_monolith_ports", [
    'tcp://0.0.0.0:9292'
])
def test_kiwi_tcms_ports(host, reddit_monolith_ports):
    p = host.socket(reddit_monolith_ports)
    assert p.is_listening
