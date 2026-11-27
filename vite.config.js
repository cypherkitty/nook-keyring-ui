import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import { optimizeCss, optimizeImports } from "carbon-preprocess-svelte";

export default defineConfig({
  plugins: [svelte({ preprocess: optimizeImports() }), optimizeCss()],
});
