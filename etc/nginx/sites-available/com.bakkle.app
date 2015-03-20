map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream websocket {
    server 127.0.0.1:8888;
}

server {
        listen 80;
        server_name app.bakkle.com;
        root /bakkle/www;
        index index.html;
        
        location / {
                return 301 https://$server_name$request_uri;
        }

        location /ws {
                proxy_pass http://localhost:8888/ws;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-proto http;
        }
}

server {
        listen 443;
        server_name app.bakkle.com;
        root /bakkle/www;
        index index.html;

        ssl on;
        ssl_certificate     /etc/ssl/com.bakkle/com.bakkle.pem;
        ssl_certificate_key /etc/ssl/com.bakkle/com.bakkle.key;

        ssl_session_timeout 5m;

        ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
        ssl_prefer_server_ciphers on;

        location / {
                proxy_pass http://localhost:8888;
                rewrite  ^/webapp/(.*)  /$1 break;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-proto https;
        }

        location /ws {
                proxy_pass http://localhost:8888/ws;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-proto https;
        }

        location /static {
                try_files $uri $uri/ =404;
        }
}

