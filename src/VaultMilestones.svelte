<script>
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Phone from "@lucide/svelte/icons/smartphone";
  import Pencil from "@lucide/svelte/icons/pencil";
  import Sync from "@lucide/svelte/icons/arrow-left-right";
  import { Button } from "$lib/components/ui/button";
  import { Progress } from "$lib/components/ui/progress";

  let { stage, vault, account, device, onEdit } = $props();

  const locations = $derived([
    {
      id: "vault",
      name: "This device",
      icon: Laptop,
      value: vault,
      current: stage === "ready",
      status: vault ? "Saved offline" : "Encrypted offline vault",
    },
    {
      id: "cloud",
      name: "Your cloud account",
      icon: Cloud,
      value: account,
      current: stage === "local",
      status: account ? "Encrypted copy saved" : "Encrypted sync copy",
    },
    {
      id: "device",
      name: "Second device",
      icon: Phone,
      value: device,
      current: stage === "cloud",
      status: device
        ? "Available offline"
        : account
          ? "Ready to link"
          : "Offline vault copy",
    },
  ]);
</script>

<ol
  class="milestones"
  role="list"
  aria-label="Encrypted copies on your devices and in your cloud account"
>
  {#each locations as location, i (location.id)}
    <li
      data-location={location.id}
      data-status={location.value
        ? "done"
        : location.current
          ? "current"
          : "waiting"}
      aria-current={location.current ? "true" : undefined}
    >
      <div class="milestone-heading">
        <location.icon
          class="location-icon"
          strokeWidth={1.7}
          aria-hidden="true"
        />
        <h3>{location.name}</h3>
        {#if location.value}
          <span class="done-mark" aria-hidden="true">
            <Check strokeWidth={2.8} />
          </span>
        {/if}
      </div>
      <div class="milestone-detail">
        <span class="milestone-status">{location.status}</span>
        {#if location.value}
          <span class="detail-separator" aria-hidden="true">·</span>
          {#if location.id === "cloud" && !device}
            <Button
              variant="link"
              class="identity-edit rounded-none"
              aria-label="Change cloud account"
              aria-describedby="sync-account-identity"
              aria-haspopup="dialog"
              title={location.value}
              onclick={(event) => onEdit(event.currentTarget)}
            >
              <span id="sync-account-identity">{location.value}</span><Pencil
                aria-hidden="true"
              />
            </Button>
          {:else}
            <span class="identity" title={location.value}>
              {location.value}
            </span>
          {/if}
        {/if}
      </div>
      <Progress
        class="milestone-meter rounded-none"
        value={location.value ? 1 : 0}
        max={1}
        aria-label={location.name}
        aria-valuetext={location.status}
      />
      {#if i > 0}
        <span
          class="sync-joint"
          class:connected={!!location.value}
          aria-hidden="true"
        >
          <Sync strokeWidth={1.5} />
        </span>
      {/if}
    </li>
  {/each}
</ol>
