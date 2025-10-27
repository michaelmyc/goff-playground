import "./assets/styles.css";
import "highlight.js/styles/github.css";

import { createApp } from "vue";
import App from "./App.vue";
import hljsVuePlugin from "@highlightjs/vue-plugin";

const app = createApp(App);
app.use(hljsVuePlugin);
app.mount("#app");
