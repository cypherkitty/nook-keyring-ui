<script>
  import { tick } from "svelte";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Card from "$lib/components/ui/card";
  import Check from "@lucide/svelte/icons/check";
  import CloudCheck from "@lucide/svelte/icons/cloud-check";
  import Link from "@lucide/svelte/icons/link";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Plus from "@lucide/svelte/icons/plus";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import Phone from "@lucide/svelte/icons/smartphone";
  import CloudAccount from "./CloudAccount.svelte";
  import VaultSync from "./VaultSync.svelte";

  // Only the preview's display names are kept in memory.
  let vault = $state("");
  let account = $state("");
  let linkedDevice = $state("");
  let vaultDraft = $state("Personal vault");
  let deviceDraft = $state("My phone");
  let heading;
  let panel = $state(null);
  const steps = ["Create vault", "Link device"];
  const namePattern = ".*\\S.*";
  const title = $derived(
    linkedDevice
      ? vault
      : account
        ? "New device request"
        : vault
          ? "Link another device"
          : "Create your vault",
  );

  async function focusHeading() {
    await tick();
    heading?.focus({ preventScroll: true });
    panel?.scrollIntoView({ block: "nearest" });
  }

  function createVault(event) {
    event.preventDefault();
    if (vault) return;
    vault = vaultDraft.trim();
    focusHeading();
  }

  function connectAccount(email) {
    if (account !== email) deviceDraft = "My phone";
    account = email;
  }

  function approveDevice(event) {
    event.preventDefault();
    if (!account || linkedDevice) return;
    linkedDevice = deviceDraft.trim();
    focusHeading();
  }

  async function restart() {
    vault = "";
    account = "";
    linkedDevice = "";
    vaultDraft = "Personal vault";
    deviceDraft = "My phone";
    await tick();
    const input = document.getElementById("vault-name");
    input?.focus();
    input?.select();
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
    {#if vault}
      <Button
        variant="ghost"
        size="sm"
        class="restart rounded-none"
        onclick={restart}
      >
        <Restart aria-hidden="true" />Restart preview
      </Button>
    {:else}
      <span class="preview-label">Setup preview</span>
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

    <Card.Root bind:ref={panel} class="setup-panel rounded-none shadow-none">
      <Card.Header class="panel-header rounded-none">
        <VaultSync {vault} {account} {linkedDevice} />
      </Card.Header>

      <Card.Content class="panel-body">
        {#if linkedDevice}
          <div class="keyring-bar">
            <Check aria-hidden="true" />2 devices in sync
          </div>
        {:else}
          <ol class="stepper" aria-label="Setup steps">
            {#each steps as step, i}
              {@const current = i === (vault ? 1 : 0)}
              {@const done = !!vault && i === 0}
              <li aria-current={current ? "step" : undefined} class:done>
                <span class="step-number" aria-hidden="true">
                  {#if done}<Check />{:else}{i + 1}{/if}
                </span>
                <span>
                  {step}{#if done}<span class="sr-only">, complete</span>{/if}
                </span>
              </li>
            {/each}
          </ol>
        {/if}
        <h1 id="setup-heading" bind:this={heading} tabindex="-1">{title}</h1>
        {#if !vault}
          <form class="setup-form" onsubmit={createVault}>
            <div class="field">
              <label for="vault-name">Vault name</label>
              <Input
                id="vault-name"
                class="setup-input rounded-none"
                bind:value={vaultDraft}
                autocomplete="off"
                required
                pattern={namePattern}
                title="Enter a vault name"
              />
            </div>
            <Button type="submit" class="primary-action rounded-none">
              <Plus aria-hidden="true" />Create vault
            </Button>
          </form>
        {:else if linkedDevice}
          <div class="storage-record">
            <span class="row-icon"><CloudCheck aria-hidden="true" /></span>
            <div class="identity">
              <span class="small-label">Sync account</span>
              <strong>{account}</strong>
            </div>
          </div>
        {:else}
          {#if !account}
            <div class="vault-receipt">
              <span class="vault-stamp"><Lock aria-hidden="true" /></span>
              <div class="identity">
                <strong>{vault}</strong>
                <span class="receipt-detail">
                  <Check aria-hidden="true" />Created on this device
                </span>
              </div>
            </div>
          {/if}
          <CloudAccount
            {account}
            vaultName={vault}
            onConnect={connectAccount}
            focusNext={focusHeading}
          />
          {#if account}
            <form class="setup-form approval-form" onsubmit={approveDevice}>
              <div class="field">
                <label for="device-name">Name in your keyring</label>
                <div class="device-field">
                  <Phone aria-hidden="true" />
                  <Input
                    id="device-name"
                    class="setup-input rounded-none"
                    bind:value={deviceDraft}
                    autocomplete="off"
                    required
                    pattern={namePattern}
                    title="Enter a device name"
                  />
                </div>
              </div>
              <Button type="submit" class="primary-action rounded-none">
                <Link aria-hidden="true" />Add to keyring
              </Button>
            </form>
          {/if}
        {/if}
      </Card.Content>
    </Card.Root>
  </section>
</main>
