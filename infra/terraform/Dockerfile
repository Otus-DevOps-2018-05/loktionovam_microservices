FROM hashicorp/terraform:light

RUN apk add --update ansible \
                    py-crypto \
                    py-libcloud \
                    py-requests \
                    python
ENV USER root

ENTRYPOINT ["/bin/terraform"]
