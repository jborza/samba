FROM alpine
LABEL MAINTAINER jborza

# Install samba
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash samba shadow tini && \
    file="/etc/samba/smb.conf" && \
    sed -i 's|^;* *\(log file = \).*|   \1/dev/stdout|' $file && \
    sed -i 's|^;* *\(load printers = \).*|   \1no|' $file && \
    sed -i 's|^;* *\(printcap name = \).*|   \1/dev/null|' $file && \
    sed -i 's|^;* *\(printing = \).*|   \1bsd|' $file && \
    sed -i 's|^;* *\(unix password sync = \).*|   \1no|' $file && \
    sed -i 's|^;* *\(preserve case = \).*|   \1yes|' $file && \
    sed -i 's|^;* *\(short preserve case = \).*|   \1yes|' $file && \
    sed -i 's|^;* *\(default case = \).*|   \1lower|' $file && \
    sed -i '/Share Definitions/,$d' $file && \
    echo '   pam password change = yes' >>$file && \
    echo '   map to guest = bad user' >>$file && \
    echo '   usershare allow guests = yes' >>$file && \
    echo '   create mask = 0777' >>$file && \
    echo '   force create mode = 0777' >>$file && \
    echo '   directory mask = 0777' >>$file && \
    echo '   force directory mode = 0777' >>$file && \
    echo '   force user = root' >>$file && \
    echo '   force group = users' >>$file && \
    echo '   follow symlinks = yes' >>$file && \
    echo '   load printers = no' >>$file && \
    echo '   printing = bsd' >>$file && \
    echo '   printcap name = /dev/null' >>$file && \
    echo '   disable spoolss = yes' >>$file && \
    echo '   socket options = TCP_NODELAY' >>$file && \
    echo '   strict locking = no' >>$file && \
    echo '   min protocol = SMB2' >>$file && \
    echo '' >>$file && \
    rm -rf /tmp/*

COPY samba.sh /usr/bin/

RUN dos2unix /usr/bin/samba.sh

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=60s --timeout=15s \
             CMD smbclient -L '\\localhost\' -U 'guest%' -m SMB3

VOLUME ["/etc/samba"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/samba.sh"]
