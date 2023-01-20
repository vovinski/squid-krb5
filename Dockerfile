FROM ubuntu:focal

ENV TZ=Europe/Moscow
LABEL maintainer="Ubuntu Server team <ubuntu-server@lists.ubuntu.com>"

RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		squid ca-certificates tzdata; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		krb5-user winbind libpam-krb5 libpam-winbind libnss-winbind libsasl2-modules-gssapi-mit;\
	DEBIAN_FRONTEND=noninteractive apt-get remove --purge --auto-remove -y; \
	rm -rf /var/lib/apt/lists/*; \
	# Change default configuration to allow local network access \
	#sed -i 's/^#http_access allow localnet$/http_access allow localnet/' #/etc/squid/conf.d/debian.conf; \
	# smoketest
	/usr/sbin/squid --version; \
		# create manifest \
	mkdir -p /usr/share/rocks; \
	(echo "# os-release" && cat /etc/os-release && echo "# dpkg-query" && dpkg-query -f '${db:Status-Abbrev},${binary:Package},${Version},${source:Package},${Source:Version}\n' -W) > /usr/share/rocks/dpkg.query

EXPOSE 3128
VOLUME /var/log/squid \
	/var/spool/squid
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
COPY [ "add/", "/" ]
CMD ["-f", "/etc/squid/squid.conf", "-NYC"]


	

