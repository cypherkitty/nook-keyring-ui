<script>
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Pencil from "@lucide/svelte/icons/pencil";
  import User from "@lucide/svelte/icons/user-round";
  import { Button } from "$lib/components/ui/button";
  import KeyringScene from "./KeyringScene.svelte";

  let { stage, vault, account, device, onEdit, children } = $props();
  let board;
  let copy;

  // Measure the actual stations so the same transfer follows the line on either layout.
  $effect(() => {
    if (stage !== "cloud" && stage !== "linked") return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const source = stage === "cloud" ? ".notebook-lid" : ".cloud-drive .vault-tag";
    const destination = stage === "cloud" ? ".cloud-drive .vault-tag" : ".handset .vault-tag";
    const origin = board.getBoundingClientRect();
    function position(selector) {
      const rect = board.querySelector(selector).getBoundingClientRect();
      const x = rect.left - origin.left + (rect.width - copy.offsetWidth) / 2;
      const y = rect.top - origin.top + (rect.height - copy.offsetHeight) / 2;
      return `translate(${x}px, ${y}px)`;
    }
    const transfer = copy.animate([
      { transform: position(source), opacity: 0 },
      { offset: 0.14, opacity: 1 },
      { offset: 0.85, opacity: 1 },
      { transform: position(destination), opacity: 0 },
    ], { duration: 720, easing: "ease-in-out" });
    return () => transfer.cancel();
  });

  const locations = $derived([
    {
      id: "vault",
      name: "This device",
      use: vault ? "Available offline" : "Offline vault",
      value: vault,
      current: stage === "ready",
      prompt: "Step 1 of 2. Create the encrypted vault on this device.",
    },
    {
      id: "cloud",
      name: "Your cloud account",
      use: account ? "Syncs an encrypted copy" : "Will sync an encrypted copy",
      value: account,
      current: stage === "local",
      prompt: "Step 2 of 2. Your local vault is ready. Connect your own cloud account.",
    },
    {
      id: "device",
      name: "Second device",
      use: device ? "Available offline" : "Will keep an offline copy",
      value: device,
      current: stage === "cloud",
      prompt: "Step 2 of 2. Your cloud copy is ready. Link a device through the same account.",
    },
  ]);
</script>

{#snippet vaultTag()}
  <span class="vault-tag"></span>
{/snippet}

<div class="keyring-board" bind:this={board}>
  <ol
    class="stations"
    role="list"
    aria-label="This device syncs its encrypted vault with a second device through your own cloud account"
  >
    {#each locations as location, i (location.id)}
      <li
        data-location={location.id}
        data-status={location.value ? "done" : location.current ? "current" : "waiting"}
        aria-current={location.current ? "true" : undefined}
      >
        <div class="station-scene" aria-hidden="true">
          <span
            class="wire incoming"
            class:absent={i === 0}
            class:connected={i > 0 && !!location.value}
          ></span>
          {#if location.id === "vault"}
            <div class="notebook">
              <div class="notebook-lid"><KeyringScene {stage} /></div>
              <div class="notebook-base"></div>
            </div>
          {:else if location.id === "cloud"}
            <div class="cloud-drive">
              <Cloud class="cloud-shell" viewBox="1 4 22 16" strokeWidth={0.32} />
              {@render vaultTag()}
              <span class="account-mark"><User strokeWidth={1.6} /></span>
            </div>
          {:else}
            <div class="handset">
              {@render vaultTag()}
            </div>
          {/if}
          <span
            class="wire outgoing"
            class:absent={i === locations.length - 1}
            class:connected={!!locations[i + 1]?.value}
          ></span>
        </div>
        <div class="station-console">
          <div class="station-heading">
            <h2 tabindex="-1" aria-describedby={"role-" + location.id + " state-" + location.id}>
              {location.name}
            </h2>
            {#if location.value}<Check class="done-mark" aria-label="Complete" />{/if}
          </div>
          <div class="storage-role" id={"role-" + location.id}>
            <Lock aria-hidden="true" />{location.use}
          </div>
          <span class="sr-only" id={"state-" + location.id}>
            {location.current ? location.prompt : location.value ? "Ready." : "Planned."}
          </span>
          {#if location.current}
            <div class="station-action">{@render children()}</div>
          {:else if location.id === "cloud" && account}
            {#if !device}
              <Button
                variant="link"
                class="identity-edit rounded-none"
                aria-label="Change cloud account"
                aria-describedby="sync-account-identity"
                aria-haspopup="dialog"
                title={account}
                onclick={(event) => onEdit(event.currentTarget)}
              >
                <span id="sync-account-identity">{account}</span><Pencil aria-hidden="true" />
              </Button>
            {:else}
              <span class="identity" title={account}>{account}</span>
            {/if}
          {:else if location.id === "device" && device}
            <span class="identity" title={device}>{device}</span>
          {/if}
        </div>
      </li>
    {/each}
  </ol>
  <span class="transfer-copy" aria-hidden="true" bind:this={copy}>{@render vaultTag()}</span>
</div>
