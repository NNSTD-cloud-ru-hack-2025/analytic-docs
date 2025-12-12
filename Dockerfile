# Build and run instructions
# Build: docker build -t slidev-presentation .
# Run: docker run -p 3030:3030 slidev-presentation
# Then open http://localhost:3030 in browser

FROM node:20-alpine

WORKDIR /app

RUN npm install -g @slidev/cli @slidev/theme-default vite

COPY presentation.md ./
COPY demo/demo.mp4 ./demo/
COPY resources/main_slide.jpg ./resources/

RUN slidev build presentation.md

EXPOSE 3030

ENV __VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS="*"

CMD ["vite","preview","--port","3030","--host","0.0.0.0"]