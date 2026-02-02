import { createOpenAPI } from "fumadocs-openapi/server";

export const openapi = createOpenAPI({
  input: ["./content/docs/api-reference/openapi.json"],
  // Interactive playground disabled - requires valid API key
  // Users can test with curl/Postman using examples in docs
  // proxyUrl: "/api/proxy",
  shikiOptions: {
    themes: {
      dark: "vesper",
      light: "vitesse-light",
    },
  },
});
