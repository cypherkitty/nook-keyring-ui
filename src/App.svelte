<script>
  import { tick } from "svelte";
  import Check from "@lucide/svelte/icons/check";
  import ArrowRight from "@lucide/svelte/icons/arrow-right";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import KeyringScene from "./KeyringScene.svelte";
  import SetupDialog from "./SetupDialog.svelte";

  // Only the setup labels live in this preview session.
  let vault = $state("");
  let account = $state("");
  let device = $state("");
  let vaultName = $state("Personal vault");
  let email = $state("you@example.com");
  let dialogOpen = $state(false);
  let dialogKind = $state("device");
  let dialogValue = $state("");
  let opener;
  let heading;

  const stage = $derived(
    !vault ? "ready" : !account ? "local" : !device ? "cloud" : "linked",
  );
  const story = {
    ready: {
      title: "Build your keyring.",
      hint: "Save passwords here. Sync an encrypted copy through your own cloud.",
    },
    local: {
      title: "Your vault is on this device.",
      hint: "Connect your own cloud so your next device can get an encrypted copy.",
    },
    cloud: {
      title: "Your cloud has an encrypted copy.",
      hint: "Open Nook on your second device with the same cloud account to join.",
    },
    linked: { title: "Your devices are in sync." },
  };

  async function showResult() {
    await tick();
    heading?.focus({ preventScroll: true });
    if (heading && heading.getBoundingClientRect().top < 0) {
      heading.scrollIntoView({ block: "start", behavior: "instant" });
    }
  }

  function createVault(event) {
    event.preventDefault();
    const name = vaultName.trim();
    if (stage !== "ready" || !name) return;
    vault = name;
    showResult();
  }

  function connectAccount(event) {
    event.preventDefault();
    if (stage !== "local") return;
    account = email.trim();
    showResult();
  }

  function openSetup(kind, trigger) {
    dialogKind = kind;
    dialogValue = kind === "device" ? "My phone" : account;
    opener = trigger;
    dialogOpen = true;
  }

  function closeSetup(value) {
    if (value === null) {
      opener?.focus();
      return;
    }
    if (dialogKind === "device") device = value;
    else account = value;
    showResult();
  }

  function restart() {
    vault = "";
    account = "";
    device = "";
    vaultName = "Personal vault";
    email = "you@example.com";
    showResult();
  }
</script>

<header class="masthead">
  <div class="header-inner">
    <div class="brand">
      <span class="wordmark">
        <img src="/nook.svg" alt="" width="23" height="23" />nook
      </span>
      <span class="brand-purpose">Local-first password manager</span>
    </div>
    {#if vault}
      <Button
        variant="ghost"
        class="restart rounded-none"
        aria-label="Restart preview"
        onclick={restart}
      >
        <Restart aria-hidden="true" /><span>
          Restart<span class="preview-word"> preview</span>
        </span>
      </Button>
    {:else}
      <span class="preview-label">Setup preview</span>
    {/if}
  </div>
</header>

<main class="workbench" data-stage={stage} aria-labelledby="setup-heading">
  <ol class="chapters" aria-label="Keyring setup progress">
    <li
      class:current={!vault}
      class:done={!!vault}
      aria-current={!vault ? "step" : undefined}
    >
      <span class="chapter-mark">
        {#if vault}<Check aria-label="Completed" />{:else}1{/if}
      </span>
      {vault ? "Vault created" : "Create vault"}
    </li>
    <li
      class:current={!!vault && !device}
      class:done={!!device}
      aria-current={vault && !device ? "step" : undefined}
    >
      <span class="chapter-mark">
        {#if device}<Check aria-label="Completed" />{:else}2{/if}
      </span>
      {device ? "Device linked" : "Link a device"}
    </li>
  </ol>
  <div class="story">
    <h1
      id="setup-heading"
      bind:this={heading}
      tabindex="-1"
      aria-describedby={story[stage].hint ? "journey-hint" : undefined}
    >
      {story[stage].title}
    </h1>
    {#if story[stage].hint}<p id="journey-hint">{story[stage].hint}</p>{/if}
  </div>

  <KeyringScene
    {vault}
    {account}
    {device}
    {stage}
    onEdit={(trigger) => openSetup("cloud", trigger)}
  >
    {#snippet controls()}
      {#if stage === "ready"}
        <form
          class="inline-form"
          onsubmit={createVault}
          aria-label="Create a vault on this device"
        >
          <label for="vault-name">Vault name</label>
          <div class="input-action">
            <Input
              id="vault-name"
              class="setup-input rounded-none"
              bind:value={vaultName}
              pattern={".*\\S.*"}
              title="Enter a vault name"
              required
              autocomplete="off"
            />
            <Button type="submit" class="action rounded-none">
              Create vault<ArrowRight aria-hidden="true" />
            </Button>
          </div>
        </form>
      {:else if stage === "local"}
        <form
          class="inline-form"
          onsubmit={connectAccount}
          aria-label="Connect your cloud account"
        >
          <label for="cloud-email">Account email</label>
          <div class="input-action">
            <Input
              id="cloud-email"
              class="setup-input rounded-none"
              type="email"
              bind:value={email}
              required
              placeholder="you@example.com"
              autocomplete="off"
              autocapitalize="none"
              spellcheck={false}
            />
            <Button type="submit" class="action rounded-none">
              Connect<ArrowRight aria-hidden="true" />
            </Button>
          </div>
        </form>
      {:else if stage === "cloud"}
        <Button
          class="action join-action rounded-none"
          aria-haspopup="dialog"
          onclick={(event) => openSetup("device", event.currentTarget)}
        >
          Preview second device<ArrowRight aria-hidden="true" />
        </Button>
      {/if}
    {/snippet}
  </KeyringScene>
</main>

<SetupDialog
  bind:open={dialogOpen}
  kind={dialogKind}
  bind:value={dialogValue}
  {vault}
  {account}
  onReturn={closeSetup}
/>
