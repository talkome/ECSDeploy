FROM public.ecr.aws/docker/library/nginx:stable-alpine-slim
WORKDIR /usr/share/nginx/html
COPY index.html .
EXPOSE 80
