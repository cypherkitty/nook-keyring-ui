<script>
  import { Button } from "$lib/components/ui/button";
  import Cloud from "@lucide/svelte/icons/cloud";
  import FileLock from "@lucide/svelte/icons/file-lock";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Refresh from "@lucide/svelte/icons/refresh-cw";
  import Phone from "@lucide/svelte/icons/smartphone";
  import User from "@lucide/svelte/icons/user-round";

  let { copies, transfer, hopDuration, onReplay } = $props();
  const locations = [
    { name: "This device", icon: Laptop, planned: "Create here" },
    { name: "Your cloud account", icon: Cloud, planned: "Sync storage" },
    { name: "Other device", icon: Phone, planned: "Not linked" },
  ];
  const linked = $derived(copies[2] > 0);
  const status = $derived(
    transfer
      ? transfer.to === 1
        ? "Saving to your cloud"
        : transfer.to === 2
          ? "Updating other device"
          : "Updating this device"
      : linked
        ? "All copies in sync"
        : copies[0]
          ? "Saved on this device"
          : "Ready for setup",
  );
</script>

<section
  id="sync-map"
  tabindex="-1"
  class="network"
  aria-labelledby="sync-title"
  style={"--hop-time: " + hopDuration + "ms"}
>
  <div class="network-heading">
    <h2 id="sync-title"><Lock aria-hidden="true" />Encrypted sync</h2>
    <div class="network-actions">
      <span
        class="network-status"
        role="status"
        aria-live="polite"
        aria-atomic="true"
      >
        {status}{#if linked && !transfer}<span class="sr-only">
            , vault version {copies[0]}
          </span>{/if}
      </span>
      {#if linked}
        <Button
          variant="ghost"
          size="sm"
          class="replay rounded-none"
          aria-label="Replay encrypted sync"
          title="Replay encrypted sync"
          disabled={!!transfer}
          onclick={onReplay}
        >
          <Refresh aria-hidden="true" /><span>Replay sync</span>
        </Button>
      {/if}
    </div>
  </div>
  <ol class="locations" aria-label="Encrypted vault sync path">
    {#each locations as place, i}
      <li
        class="location"
        class:stored={copies[i] > 0}
        class:receiving={transfer?.to === i}
      >
        {#if i < locations.length - 1}
          <span
            class="connection"
            class:connected={copies[i] > 0 && copies[i + 1] > 0}
            aria-hidden="true"
          >
            {#if transfer && Math.min(transfer.from, transfer.to) === i}
              <span class="packet" class:reverse={transfer.from > transfer.to}>
                <FileLock />
              </span>
            {/if}
          </span>
        {/if}
        <span class="node-tag" aria-hidden="true">
          <place.icon class="node-icon" strokeWidth={1.6} />
          {#if i === 1}<span class="account-mark"><User /></span>{/if}
        </span>
        <h3>{place.name}</h3>
        <span class="copy-status">
          {#if copies[i]}
            <Lock aria-hidden="true" />Encrypted<span class="sr-only">
              copy, version {copies[i]}
            </span>
          {:else}
            {place.planned}
          {/if}
        </span>
      </li>
    {/each}
  </ol>
</section>
