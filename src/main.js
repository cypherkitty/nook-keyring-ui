import { mount } from "svelte";
import "@fontsource/ibm-plex-mono/latin-400.css";
import "./theme.css";
import "./style.css";
import App from "./App.svelte";

mount(App, { target: document.getElementById("app") });
