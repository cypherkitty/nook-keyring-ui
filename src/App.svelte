<script>
  import { onDestroy, tick } from "svelte";
  import {
    Accordion,
    AccordionItem,
    Button,
    ProgressIndicator,
    ProgressStep,
  } from "carbon-components-svelte";
  import { Link2, Plus, RefreshCw, RotateCcw } from "lucide-svelte";
  import KeyringMap from "./KeyringMap.svelte";

  // Zero denotes a planned location. Positive values are copies of a demo revision.
  let copies = $state([0, 0, 0]);
  let transfer = $state(null);
  let primaryButton = $state();
  let storageOpen = $state(true);
  let timers = [];
  const created = $derived(copies[0] > 0);
  const linked = $derived(copies[2] > 0);
  const revision = $derived(Math.max(...copies));
  const nextSource = $derived(linked && revision % 2 === 0 ? 2 : 0);
  const stepIndex = $derived(Number(created) + Number(linked));
  const actionLabel = $derived(
    transfer
      ? "Syncing vault"
      : !created
        ? "Create local vault"
        : !linked
          ? "Link another device"
          : "Preview a change",
  );
  const actionIcon = $derived(!created ? Plus : !linked ? Link2 : RefreshCw);
  const status = $derived(
    transfer
      ? transfer.to === 1
        ? "Saving to your cloud account"
        : transfer.to === 0
          ? "Updating this device"
          : "Updating your other device"
      : linked
        ? "All three copies in sync"
        : "Saved on this device",
  );

  function clearTimers() {
    timers.forEach(clearTimeout);
    timers = [];
  }
  onDestroy(clearTimers);

  async function reset() {
    clearTimers();
    transfer = null;
    copies = [0, 0, 0];
    storageOpen = true;
    await tick();
    primaryButton?.focus();
  }

  function sendCopy(source, target, version) {
    const receive = () => {
      copies[target] = version;
      transfer = null;
      timers = [];
    };
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      copies[1] = version;
      receive();
      return;
    }
    transfer = { source, from: source, to: 1 };
    timers = [
      setTimeout(() => {
        copies[1] = version;
        transfer = { source, from: 1, to: target };
      }, 650),
      setTimeout(receive, 1300),
    ];
  }

  function advance() {
    if (transfer) return;
    if (!created) {
      copies[0] = 1;
    } else if (!linked) {
      sendCopy(0, 2, copies[0]);
    } else {
      const source = nextSource;
      const version = revision + 1;
      copies[source] = version;
      sendCopy(source, 2 - source, version);
    }
  }
</script>

<header class="masthead">
  <div class="masthead-inner">
    <div class="identity">
      <div class="wordmark" aria-label="Nook">
        <img src="/nook.svg" alt="" />nook
      </div>
      <span class="product-type">Local-first password manager</span>
    </div>
    <div class="preview-controls">
      {#if created}
        <Button
          kind="ghost"
          size="sm"
          class="reset-button"
          icon={RotateCcw}
          on:click={reset}
        >
          Reset preview
        </Button>
      {:else}
        <span class="preview-label">Interactive preview</span>
      {/if}
    </div>
  </div>
</header>

<main class="workspace">
  <div class="workbench">
    <section class="setup" aria-labelledby="setup-title">
      <div
        role="progressbar"
        aria-label="Vault setup"
        aria-valuemin="0"
        aria-valuemax="2"
        aria-valuenow={stepIndex}
        aria-valuetext={linked
          ? "Setup complete"
          : created
            ? "Step 2 of 2, link another device"
            : "Step 1 of 2, create a local vault"}
      >
        <ProgressIndicator
          currentIndex={stepIndex}
          spaceEqually
          preventChangeOnClick
          inert
        >
          <ProgressStep
            label="Local vault"
            description="Create a vault on this device"
            complete={created}
          />
          <ProgressStep
            label="Link device"
            description="Link another device through your cloud account"
            complete={linked}
          />
        </ProgressIndicator>
      </div>

      <div class="step-content">
        {#if !created}
          <h1 id="setup-title">Start on <span>this device.</span></h1>
          <p>
            Create an encrypted vault for the passwords you save here. You can
            link a second device whenever you’re ready.
          </p>
        {:else if !linked}
          <h1 id="setup-title">Link another <span>device.</span></h1>
          <p>
            Connect both devices to the same cloud account. Each device keeps an
            encrypted copy of your vault.
          </p>
        {:else}
          <h1 id="setup-title">Your devices <span>are linked.</span></h1>
          <p>
            Preview a password change on {(transfer?.source ?? nextSource) === 0
              ? "this device"
              : "your other device"}. Follow the update through your cloud
            account.
          </p>
        {/if}
        <Button
          class="main-action"
          icon={actionIcon}
          loading={!!transfer}
          bind:ref={primaryButton}
          on:click={advance}
        >
          {actionLabel}
        </Button>
      </div>
    </section>

    <section
      class="visual"
      class:has-vault={created}
      aria-labelledby="keyring-title"
    >
      <img
        class="vault-art"
        src="/keyring/vault-ring.webp"
        alt=""
        fetchpriority="high"
      />
      <div class="visual-bar">
        <h2 id="keyring-title">Your keyring</h2>
        <span class="device-count" class:has-copy={created}>
          {stepIndex}
          {stepIndex === 1 ? "device" : "devices"}
        </span>
      </div>
      <div
        class="vault-readout"
        role="status"
        aria-live="polite"
        aria-atomic="true"
      >
        {#if created}
          <span class="revision">Vault v{revision}</span>
          <span>{status}</span>
        {/if}
      </div>
    </section>

    <KeyringMap {copies} {transfer} />

    <aside class="ownership" aria-label="Cloud storage">
      <Accordion align="end">
        <AccordionItem
          title="Who stores the synced vault?"
          bind:open={storageOpen}
        >
          <p>
            With Nook, <strong>your own cloud account</strong> holds the encrypted
            copy. A hosted password manager keeps that copy on its servers.
          </p>
        </AccordionItem>
      </Accordion>
    </aside>
  </div>
</main>
