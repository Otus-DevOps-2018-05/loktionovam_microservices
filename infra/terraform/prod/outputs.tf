output "docker_host_external_ip" {
  value = "${module.docker_host.docker_host_external_ip}"
}

output "mgmt_host_external_ip" {
  value = "${module.mgmt_host.mgmt_host_external_ip}"
}
