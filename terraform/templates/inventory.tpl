[all:vars]
ansible_ssh_common_args = "-F ./ssh_config.local"

[control_plane]
%{ for ip in control_plane ~}
${ip}
%{ endfor ~}

[data_plane]
%{ for ip in data_plane ~}
${ip}
%{ endfor ~}

[storage]
%{ for ip in storage ~}
${ip}
%{ endfor ~}

