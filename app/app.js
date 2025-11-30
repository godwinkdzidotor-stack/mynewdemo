// app/app.js

const http = require("http");

const PORT = process.env.PORT || 80;
const APP_NAME = process.env.APP_NAME || "mynewdemo";

const requestListener = (req, res) => {
  console.log(`Incoming request: ${req.method} ${req.url}`);

  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(
    JSON.stringify({
      message: `Hello from ${APP_NAME} running on ECS Fargate!`,
      path: req.url,
      time: new Date().toISOString(),
    })
  );
};

const server = http.createServer(requestListener);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server for ${APP_NAME} listening on port ${PORT}`);
});
