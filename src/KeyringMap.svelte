<script>
  import { Cloud, Laptop, LockKeyhole, Smartphone } from "lucide-svelte";

  let { copies, transfer } = $props();
  const nextLocation = $derived(transfer?.to ?? (copies[0] ? 2 : 0));
  const locations = [
    { name: "This device", icon: Laptop, planned: "Local vault" },
    { name: "Your cloud account", icon: Cloud, planned: "Encrypted copy" },
    { name: "Other device", icon: Smartphone, planned: "Local vault" },
  ];
</script>

<section class="route" aria-labelledby="route-title">
  <div class="route-heading">
    <h2 id="route-title">Sync path</h2>
    <span><LockKeyhole size={13} aria-hidden="true" />Encrypted</span>
  </div>
  <ol class="route-stops">
    {#each locations as place, i}
      <li
        class:stored={copies[i] > 0}
        class:upcoming={copies[i] === 0 && nextLocation === i}
      >
        {#if i < locations.length - 1}
          <span
            class="wire"
            class:connected={copies[i] > 0 && copies[i + 1] > 0}
            aria-hidden="true"
          >
            {#if transfer && Math.min(transfer.from, transfer.to) === i}
              <i class:reverse={transfer.from > transfer.to}></i>
            {/if}
          </span>
        {/if}
        <span class="socket" aria-hidden="true">
          <place.icon size={21} strokeWidth={1.6} />
        </span>
        <span class="place-name">{place.name}</span>
        <span class="copy-status">
          {copies[i] ? "Vault v" + copies[i] : place.planned}
        </span>
      </li>
    {/each}
  </ol>
</section>
