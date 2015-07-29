map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream websocket {
    server 127.0.0.1:8888;
}

upstream django {
    server 127.0.0.1:8000;
#     server unix:///bakkle/run/bakkle.sock;
}

server {
        listen 80;
        server_name *.bakkle.com;
        root /bakkle/www;
	charset	utf-8;
        index index.html;
        
        location / {
                return 301 https://$server_name$request_uri;
        }

        location /ws {
                proxy_pass http://localhost:8000/ws;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-proto http;
        }

	error_page 502	/static/502.html;
}

server {
        listen 443;
        server_name *.bakkle.com;
        root /bakkle/www;
	charset	utf-8;
        index index.html;

        ssl on;
        ssl_certificate     /etc/ssl/com.bakkle/com.bakkle.pem;
        ssl_certificate_key /etc/ssl/com.bakkle/com.bakkle.key;

        ssl_session_timeout 5m;

        ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
        ssl_prefer_server_ciphers on;

        location / {
                proxy_pass http://localhost:8000;
		#uwsgi_pass django;
#		uwsgi_param  QUERY_STRING       $query_string;
#		uwsgi_param  REQUEST_METHOD     $request_method;
#		uwsgi_param  CONTENT_TYPE       $content_type;
#		uwsgi_param  CONTENT_LENGTH     $content_length;
#
#		uwsgi_param  REQUEST_URI        $request_uri;
#		uwsgi_param  PATH_INFO          $document_uri;
#		uwsgi_param  DOCUMENT_ROOT      $document_root;
#		uwsgi_param  SERVER_PROTOCOL    $server_protocol;
#		uwsgi_param  HTTPS              $https if_not_empty;
#
#		uwsgi_param  REMOTE_ADDR        $remote_addr;
#		uwsgi_param  REMOTE_PORT        $remote_port;
#		uwsgi_param  SERVER_PORT        $server_port;
#		uwsgi_param  SERVER_NAME        $server_name;
        }

        location /ws {
                proxy_pass http://localhost:8000/ws;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-proto https;
        }

        location /p1 {
                try_files $uri $uri/ =404;
        }

        location /img {
                try_files $uri $uri/ =404;
        }

	error_page 502	/static/502.html;
}

