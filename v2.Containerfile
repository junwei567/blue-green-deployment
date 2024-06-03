FROM nginxinc/nginx-unprivileged 

COPY green.html  /usr/share/nginx/html/index.html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]