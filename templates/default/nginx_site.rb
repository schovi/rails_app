upstream <%= @application_name %>_server {
  server 127.0.0.1:<%= @unicorn_port %> fail_timeout=0;
}

server {
  listen 80 <%= @default ? "default" : "" %>;
  server_name <%= @default ? "_" : @application_name %>;

  client_max_body_size 4G;
  keepalive_timeout 5;
  root /var/www/apps/<%= @application_name %>/current/public;
  try_files $uri/index.html $uri.html $uri @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://<%= @application_name %>_server;
  }

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /var/www/apps/sample/current/public;
  }
}
