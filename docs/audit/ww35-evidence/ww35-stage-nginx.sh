# ww35: serve the branch's nginx/lupp.us.conf with almanta's own nginx
# (1.20.1), unprivileged, on 127.0.0.1:18035, over the branch's dist/. The
# lupp.us server block is taken verbatim except: listen -> the loopback port,
# the four TLS lines dropped, root -> this lane's dist, logs -> this lane.
# The http-level settings are almanta's /etc/nginx/nginx.conf's.
set -eu
L=$HOME/lanes/ww35
N=$L/ngx
mkdir -p $N/tmp
CONF=$L/web/nginx/lupp.us.conf
python3 - "$CONF" "$N/site.conf" "$L/web/dist" "$N" <<'PY'
import re, sys
src, out, root, n = sys.argv[1:]
text = open(src).read()
blocks, depth, cur = [], 0, []
for line in text.split("\n"):
    if depth == 0 and line.startswith("server {"):
        cur = [line]; depth = 1; continue
    if depth:
        cur.append(line)
        depth += line.count("{") - line.count("}")
        if depth == 0: blocks.append("\n".join(cur))
site = [b for b in blocks if re.search(r"^\s*server_name lupp\.us;", b, re.M)]
assert len(site) == 1, len(site)
b = site[0]
b = re.sub(r"^\s*listen 443 ssl http2;\n", "    listen 127.0.0.1:18035;\n", b, flags=re.M)
b = re.sub(r"^\s*listen \[::\]:443 ssl http2;\n", "", b, flags=re.M)
for pat in [r"ssl_certificate\s", r"ssl_certificate_key\s", r"include /etc/letsencrypt/", r"ssl_dhparam\s"]:
    b, k = re.subn(r"^\s*" + pat + r".*\n", "", b, flags=re.M); assert k == 1, pat
b, k = re.subn(r"^\s*root /var/www/lupp\.us/current;", f"    root {root};", b, flags=re.M); assert k == 1
b = re.sub(r"access_log \S+;", f"access_log {n}/access.log;", b)
b = re.sub(r"error_log\s+\S+;", f"error_log {n}/error.log;", b)
open(out, "w").write(b + "\n")
PY
cat > $N/nginx.conf <<NGX
worker_processes 1;
pid $N/nginx.pid;
error_log $N/error.log;
events { worker_connections 256; }
http {
    sendfile on; tcp_nopush on; tcp_nodelay on; keepalive_timeout 65;
    types_hash_max_size 4096;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    client_body_temp_path $N/tmp/body; proxy_temp_path $N/tmp/proxy;
    fastcgi_temp_path $N/tmp/fcgi; uwsgi_temp_path $N/tmp/uwsgi; scgi_temp_path $N/tmp/scgi;
    access_log $N/access.log;
    include $N/site.conf;
}
NGX
diff <(sed -n '/server_name lupp.us;/,$p' $CONF) <(sed -n '/server_name lupp.us;/,$p' $N/site.conf) || true
/usr/sbin/nginx -p $N -c $N/nginx.conf -t
