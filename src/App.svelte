<script>
  import { onDestroy, tick } from "svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card";
  import { Progress } from "$lib/components/ui/progress";
  import Check from "@lucide/svelte/icons/check";
  import Plus from "@lucide/svelte/icons/plus";
  import Link from "@lucide/svelte/icons/link";
  import Loader from "@lucide/svelte/icons/loader-circle";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import KeyringMap from "./KeyringMap.svelte";

  // The three entries are this device, the user's cloud, and the linked device.
  // Zero is an empty location; a positive number is a simulated vault revision.
  let copies = $state([0, 0, 0]);
  let transfer = $state(null);
  let controls = $state([null, null]);
  let timers = [];
  const hopDuration = 850;
  const created = $derived(copies[0] > 0);
  const linked = $derived(copies[2] > 0);
  const completed = $derived(Number(created) + Number(linked));
  const revision = $derived(Math.max(...copies));

  function clearTimers() {
    timers.forEach(clearTimeout);
    timers = [];
  }
  onDestroy(clearTimers);

  async function restart() {
    clearTimers();
    transfer = null;
    copies = [0, 0, 0];
    await tick();
    controls[0]?.focus({ preventScroll: true });
  }

  async function createVault() {
    if (created) return;
    copies[0] = 1;
    await tick();
    controls[1]?.focus({ preventScroll: true });
  }

  function sendCopy(source, target, version) {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      copies[1] = version;
      copies[target] = version;
      return;
    }
    transfer = { from: source, to: 1 };
    timers = [
      setTimeout(() => {
        copies[1] = version;
        transfer = { from: 1, to: target };
      }, hopDuration),
      setTimeout(() => {
        copies[target] = version;
        transfer = null;
        timers = [];
      }, hopDuration * 2),
    ];
  }

  async function linkDevice() {
    if (!created || linked || transfer) return;
    sendCopy(0, 2, copies[0]);
    await tick();
    const diagram = document.getElementById("sync-map");
    diagram.focus({ preventScroll: true });
    diagram.scrollIntoView({ block: "nearest" });
  }

  function replaySync() {
    if (!linked || transfer) return;
    const source = revision % 2 === 1 ? 0 : 2;
    const version = revision + 1;
    copies[source] = version;
    sendCopy(source, 2 - source, version);
  }

  const steps = $derived([
    {
      title: "Create your vault",
      description: "Store it on this device.",
      action: created ? "Vault created" : "Create vault",
      icon: created ? Check : Plus,
      complete: created,
      enabled: !created,
      run: createVault,
    },
    {
      title: "Link another device",
      description: "Connect your cloud account.",
      action: linked ? "Device linked" : transfer ? "Linking…" : "Link device",
      icon: linked ? Check : transfer ? Loader : Link,
      complete: linked,
      enabled: created && !linked && !transfer,
      run: linkDevice,
    },
  ]);
</script>

<header class="site-header">
  <div class="frame header-inner">
    <div class="brand">
      <span class="wordmark">
        <img src="/nook.svg" alt="" width="28" height="28" />nook
      </span>
      <span class="brand-caption">Local-first password manager</span>
    </div>
    {#if created}
      <Button
        variant="ghost"
        size="sm"
        class="restart rounded-none"
        onclick={restart}
      >
        <Restart aria-hidden="true" />Restart preview
      </Button>
    {:else}
      <span class="preview-label">Preview</span>
    {/if}
  </div>
</header>

<main class="frame">
  <div class="hero">
    <figure class="hero-art">
      <picture>
        <source media="(max-width: 680px)" srcset="/keyring/vault-ring.webp" />
        <img
          src="/keyring/keyring-original.png"
          width="1448"
          height="1086"
          fetchpriority="high"
          alt="A steel keyring holding an orange keyhole tag, a brushed silver tag, and a graphite tag."
        />
      </picture>
    </figure>

    <section class="setup" aria-labelledby="setup-heading">
      <div class="setup-intro">
        <div class="setup-progress">
          <div class="progress-label">
            <span>Vault setup</span><span>
              {completed} of 2 complete
            </span>
          </div>
          <Progress
            value={completed}
            max={2}
            class="rounded-none"
            aria-label="Vault setup progress"
            aria-valuetext={completed + " of 2 steps complete"}
          />
        </div>
        <h1 id="setup-heading">Your keyring</h1>
        <p class="intro-copy">
          Each device keeps an encrypted copy of your passwords. The only online
          copy lives in <strong>your own cloud account</strong>, where your
          devices sync changes.
        </p>
      </div>
      <ol class="steps" aria-label="Setup steps">
        {#each steps as step, i}
          <li>
            <Card.Root
              class="step-card rounded-none shadow-none"
              data-current={step.enabled}
              data-complete={step.complete}
            >
              <span class="step-number" aria-label={"Step " + (i + 1)}>
                {i + 1}
              </span>
              <Card.Header class="step-copy">
                <Card.Title><h2>{step.title}</h2></Card.Title>
                <Card.Description>{step.description}</Card.Description>
              </Card.Header>
              <Card.Footer class="step-action">
                <Button
                  bind:ref={controls[i]}
                  class="step-button rounded-none"
                  variant={step.enabled ? "default" : "outline"}
                  disabled={!step.enabled}
                  aria-busy={i === 1 && !linked && !!transfer}
                  onclick={step.run}
                >
                  <step.icon
                    class={i === 1 && !linked && transfer ? "spin" : ""}
                    aria-hidden="true"
                  />
                  {step.action}
                </Button>
              </Card.Footer>
            </Card.Root>
          </li>
        {/each}
      </ol>
    </section>
  </div>

  <KeyringMap {copies} {transfer} {hopDuration} onReplay={replaySync} />
</main>
