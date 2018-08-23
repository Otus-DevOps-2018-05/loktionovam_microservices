FROM hashicorp/terraform:light

RUN apk add --update ansible
ENV USER root

ENTRYPOINT ["/bin/terraform"]
