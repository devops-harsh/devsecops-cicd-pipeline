# build stage 
# define base runner
FROM node:20-alpine AS build 
# set working directory
WORKDIR /app
# copy all the dependecies to install
COPY package*.json ./
# install the dependecies
RUN npm install && npm cache clean --force 
# copy all the code in the . ( here /app)
COPY . .
# build the application binary artifacts 
RUN npm run build

# production stage
# define the base runner
FROM nginx:1.27-alpine AS production
# remove all the files from the nginx
RUN rm -rf /etc/nginx/conf.d/default.conf
RUN rm -rf /usr/share/nginx/html/*
# copy our nginx.conf 
COPY nginx.conf /etc/nginx/conf.d/
# copy the binary artifact from the build stage
COPY --from=build /app/dist/ /usr/share/nginx/html/

# best security practices changing ownership of the directory
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid 
    

# run all subsequent command as user nginx
USER nginx

# expose the application inside port on port 80
EXPOSE 80

# running the application
ENTRYPOINT ["nginx", "-g", "daemon off;"]


