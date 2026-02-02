import * as OpenAPI from "fumadocs-openapi";
import { rimraf } from "rimraf";

const out = "./content/docs/api-reference/(generated)";

export async function generateDocs() {
  await rimraf(out, {
    filter(v) {
      return !v.endsWith("meta.json");
    },
  });

  await OpenAPI.generateFiles({
    input: "./content/docs/api-reference/openapi.json",
    output: out,
    per: "operation",
    includeDescription: true,
    groupBy: "tag",
  });
}

// Execute the function when script is run directly
if (import.meta.main) {
  await generateDocs();
}
