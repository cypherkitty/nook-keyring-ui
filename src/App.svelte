<script>
  import { onDestroy, tick } from "svelte";
  import { Button } from "$lib/components/ui/button";
  import Check from "@lucide/svelte/icons/check";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import KeyringMap from "./KeyringMap.svelte";

  // Device, storage account, second device. A positive revision is a vault copy.
  let copies = $state([0, 0, 0]);
  let transfer = $state(null);
  let timers = [];
  const hopDuration = 1050;
  const created = $derived(copies[0] > 0);
  const linked = $derived(copies[2] > 0);
  const memberCount = $derived(Number(created) + Number(linked));
  const revision = $derived(Math.max(...copies));

  const stages = [
    {
      title: "Build your personal cloud",
      description:
        "Your devices form your cloud. Each keeps an encrypted password vault, and your own storage account keeps them in sync.",
    },
    {
      title: "Add your second device",
      description:
        "This device now holds your vault. Link another through your own cloud storage to give it an encrypted copy.",
    },
    {
      title: "Your cloud is ready",
      description:
        "Both devices keep your encrypted vault. Your storage account holds the only online copy and keeps them in sync.",
    },
  ];
  const steps = ["Create vault", "Link device"];

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
    document.getElementById("create-vault")?.focus();
  }

  async function createVault() {
    if (created) return;
    copies[0] = 1;
    await tick();
    document.getElementById("link-device")?.focus({ preventScroll: true });
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
  <section class="hero" aria-labelledby="setup-heading">
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

    <div class="setup-intro">
      <ol class="stepper" aria-label="Setup steps">
        {#each steps as step, i}
          <li
            aria-current={memberCount === i ? "step" : undefined}
            class:done={memberCount > i}
          >
            <span class="step-number" aria-hidden="true">
              {#if memberCount > i}<Check />{:else}{i + 1}{/if}
            </span>
            <span>
              {step}<span class="sr-only">
                {memberCount > i ? ", complete" : ""}
              </span>
            </span>
          </li>
        {/each}
      </ol>
      <h1 id="setup-heading">{stages[memberCount].title}</h1>
      <p class="intro-copy">{stages[memberCount].description}</p>
    </div>

    <KeyringMap
      {copies}
      {memberCount}
      {transfer}
      {hopDuration}
      onCreate={createVault}
      onLink={linkDevice}
      onReplay={replaySync}
    />
  </section>
</main>
