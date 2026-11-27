<script>
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Phone from "@lucide/svelte/icons/smartphone";
  import UserRound from "@lucide/svelte/icons/user-round";

  let { vault, account, device, onActivate } = $props();

  const stops = $derived([
    {
      id: "vault",
      label: "This device",
      role: "Local copy",
      icon: Laptop,
      saved: !!vault,
      active: !vault,
      action: "Create a vault on this device",
    },
    {
      id: "cloud",
      label: "Your cloud account",
      role: "Encrypted sync copy",
      icon: Cloud,
      saved: !!account,
      active: !!vault && !account,
      action: "Connect your own cloud account",
    },
    {
      id: "device",
      label: device || "Second device",
      role: "Local copy",
      icon: Phone,
      saved: !!device,
      active: !!account && !device,
      action: "Open the second-device preview",
    },
  ]);
  const members = $derived(Number(!!vault) + Number(!!device));
</script>

{#snippet terminal(stop)}
  <span class="port" aria-hidden="true">
    <stop.icon strokeWidth={1.65} />
    {#if stop.id === "cloud"}<span class="account-owner">
        <UserRound strokeWidth={1.8} />
      </span>{/if}
    {#if stop.saved}<i><Check strokeWidth={3} /></i>{/if}
  </span>
  <strong>{stop.label}</strong>
{/snippet}

<figure
  class="studio"
  aria-labelledby="keyring-title"
  aria-describedby="keyring-description"
>
  <figcaption class="studio-heading">
    <strong id="keyring-title">Your keyring</strong>
    <span class="device-count">
      {members}
      {members === 1 ? "device" : "devices"}
    </span>
  </figcaption>
  <span class="sr-only" id="keyring-description">
    Each linked device keeps an encrypted local copy of the same vault. Changes
    sync in both directions through your own cloud account.
  </span>

  <div class="specimen">
    <div class="photograph">
      <picture>
        <source media="(max-width: 680px)" srcset="/keyring/vault-ring.webp" />
        <img
          src="/keyring/keyring-original.png"
          width="1448"
          height="1086"
          fetchpriority="high"
          alt="A steel keyring holding an orange keyhole tag and two metal tags."
        />
      </picture>
      <!-- The device callouts touch the orange and graphite tags. Storage sits between the devices on the sync line. -->
      <span
        class="leader local-leader"
        class:next={!vault}
        class:joined={!!vault}
        aria-hidden="true"
      >
        <svg viewBox="0 0 100 100" preserveAspectRatio="none">
          <path d="M100 0 L76 25 H0 V100" />
        </svg>
      </span>
      <span
        class="leader peer-leader"
        class:next={!!account && !device}
        class:joined={!!device}
        aria-hidden="true"
      >
        <svg viewBox="0 0 100 100" preserveAspectRatio="none">
          <path d="M0 0 L37 24 H100 V100" />
        </svg>
      </span>
    </div>

    <div class="network">
      {#each [account, device] as destination, index}
        <span
          class="wire"
          class:second={index === 1}
          class:live={!!destination}
          aria-hidden="true"
        >
          {#if destination}
            {#key destination}
              <span class="packet"><Lock /></span>
            {/key}
          {/if}
        </span>
      {/each}
      <ol class="stops" role="list" aria-label="Where your vault lives">
        {#each stops as stop (stop.id)}
          <li
            data-stop={stop.id}
            class:active={stop.active}
            class:saved={stop.saved}
            aria-current={stop.active ? "location" : undefined}
          >
            {#if stop.active}
              <button
                type="button"
                class="terminal"
                aria-label={stop.action}
                aria-haspopup="dialog"
                onclick={(event) => onActivate(stop.id, event.currentTarget)}
              >
                {@render terminal(stop)}
              </button>
            {:else}
              <div class="terminal">{@render terminal(stop)}</div>
            {/if}
            <span class="copy-role">
              {#if stop.id !== "cloud"}<Lock aria-hidden="true" />{/if}
              <span>{stop.role}</span><span class="sr-only">
                {stop.saved ? ", saved" : ", planned"}
              </span>
            </span>
          </li>
        {/each}
      </ol>
    </div>
  </div>
</figure>
