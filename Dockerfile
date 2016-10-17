FROM fedora:24
MAINTAINER Jonathan Lebon <jlebon@redhat.com>

RUN dnf install -y \
		git \
		gcc \
		sudo \
		docker \
		python-devel \
		redhat-rpm-config \
		python-pip \
		nmap-ncat && \
	dnf clean all

RUN pip install \
		python-novaclient \
		awscli \
		PyYAML \
		jinja2

# There's a tricky bit here. We mount $PWD at $PWD in the
# container so that when we do the nested docker run in the
# main script, the paths the daemon receives will still be
# correct from the host perspective.

# Sadly, we have to mount / so that we can access the ssh
# keyfile.

LABEL RUN="/usr/bin/docker run --rm --privileged \
             -v /run/docker.sock:/run/docker.sock \
             -v \$PWD:\$PWD \
             -v /:/host \
             --net=host \
             --workdir \$PWD \
             -e github_repo \
             -e github_branch \
             -e github_pull_id \
             -e github_commit \
             -e github_token \
             -e os_keyname \
             -e os_keyfile \
             -e os_network \
             -e os_floating_ip_pool \
             -e s3_prefix \
             -e OS_AUTH_URL \
             -e OS_TENANT_ID \
             -e OS_USERNAME \
             -e OS_PASSWORD \
             -e AWS_ACCESS_KEY_ID \
             -e AWS_SECRET_ACCESS_KEY \
             -e BUILD_ID \
             \${OPT1} \
             \${IMAGE}"

COPY . /redhat-ci

CMD ["/redhat-ci/utils/docker-helper.sh"]
