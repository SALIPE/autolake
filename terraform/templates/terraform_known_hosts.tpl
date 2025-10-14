%{ for h in hosts ~}
${h.ip} ssh-rsa ${h.key}
%{ endfor ~}
