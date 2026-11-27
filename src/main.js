import { mount } from "svelte";
import "carbon-components-svelte/css/white.css";
import "@fontsource-variable/inter/wght.css";
import "@fontsource/barlow-condensed/latin-600.css";
import "@fontsource/ibm-plex-mono/latin-400.css";
import "./style.css";
import App from "./App.svelte";

mount(App, { target: document.getElementById("app") });
