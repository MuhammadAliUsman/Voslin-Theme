// /var/www/paymenter/themes/voslintheme/vite.config.js
import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";
import path from "path";
import tailwindcss from "tailwindcss";

export default defineConfig({
  plugins: [
    laravel({
      input: [
        "themes/voslintheme/css/app.css",
        "themes/voslintheme/js/app.js"
      ],
      buildDirectory: "voslintheme/",
    }),
    {
      name: "blade",
      handleHotUpdate({ file, server }) {
        if (file.endsWith(".blade.php")) {
          server.ws.send({ type: "full-reload", path: "*" });
        }
      },
    },
  ],
  css: {
    postcss: {
      plugins: [tailwindcss({ config: path.resolve("./themes/voslintheme/tailwind.config.js") })],
    },
  },
});
