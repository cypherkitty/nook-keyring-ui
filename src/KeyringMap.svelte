<script>
  import { Button } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card";
  import Cloud from "@lucide/svelte/icons/cloud";
  import FileLock from "@lucide/svelte/icons/file-lock";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Link from "@lucide/svelte/icons/link";
  import Loader from "@lucide/svelte/icons/loader-circle";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Plus from "@lucide/svelte/icons/plus";
  import Refresh from "@lucide/svelte/icons/refresh-cw";
  import Phone from "@lucide/svelte/icons/smartphone";
  import User from "@lucide/svelte/icons/user-round";

  let {
    copies,
    memberCount,
    transfer,
    hopDuration,
    onCreate,
    onLink,
    onReplay,
  } = $props();
  const devices = [
    { index: 0, name: "This device", icon: Laptop },
    { index: 2, name: "Second device", icon: Phone },
  ];
  const linked = $derived(memberCount === 2);
  const storageStatus = $derived(
    transfer
      ? transfer.to === 1
        ? "Receiving encrypted vault"
        : transfer.to === 2
          ? "Syncing to second device"
          : "Syncing to this device"
      : linked
        ? "Encrypted copy in sync"
        : "Syncs encrypted vault copies",
  );
</script>

<section
  id="sync-map"
  tabindex="-1"
  class="cloud-builder"
  aria-labelledby="cloud-heading"
  style={"--hop-time: " + hopDuration + "ms"}
>
  <Card.Root
    class="members rounded-none shadow-none"
    data-started={memberCount > 0}
    style={"--joined-fraction: " + memberCount / devices.length}
  >
    <Card.Header class="members-heading rounded-none">
      <h2 id="cloud-heading">Your personal cloud</h2>
      <span class="member-count" role="status" aria-atomic="true">
        {memberCount}
        {memberCount === 1 ? "device" : "devices"}
      </span>
    </Card.Header>
    <Card.Content class="members-content">
      <ul class="device-slots" aria-label="Devices in your personal cloud">
        {#each devices as device}
          {@const stored = copies[device.index] > 0}
          {@const linking = device.index === 2 && !!transfer && !linked}
          {@const active =
            !stored && device.index === (memberCount === 0 ? 0 : 2)}
          <li
            class="device-slot"
            class:stored
            class:active
            class:receiving={transfer?.to === device.index}
          >
            <span class="device-marker" aria-hidden="true">
              <device.icon strokeWidth={1.5} />
              {#if stored}<span class="vault-mark"><Lock /></span>{/if}
            </span>
            <h3>{device.name}</h3>
            <div class="device-action">
              {#if stored}
                <span class="device-status">
                  Encrypted vault<span class="sr-only">
                    , version {copies[device.index]}
                  </span>
                </span>
              {:else if linking}
                <span class="device-status linking">
                  <Loader class="spinner" aria-hidden="true" />Linking…
                </span>
              {:else if active}
                <Button
                  id={device.index === 0 ? "create-vault" : "link-device"}
                  class="build-action rounded-none"
                  onclick={device.index === 0 ? onCreate : onLink}
                >
                  {#if device.index === 0}<Plus aria-hidden="true" />Create
                    vault{:else}<Link aria-hidden="true" />Link device{/if}
                </Button>
              {:else}
                <span class="device-status">Joins in step 2</span>
              {/if}
            </div>
          </li>
        {/each}
      </ul>
    </Card.Content>
  </Card.Root>

  <div class="storage">
    <div class="bridge" aria-hidden="true">
      {#each devices as device}
        <span
          class="wire"
          class:right={device.index === 2}
          class:connected={copies[1] > 0 && copies[device.index] > 0}
          class:moving={transfer?.from === device.index ||
            transfer?.to === device.index}
        >
          {#if transfer?.from === device.index || transfer?.to === device.index}
            <span class="packet" class:outbound={transfer.from === 1}>
              <FileLock />
            </span>
          {/if}
        </span>
      {/each}
      <span
        class="storage-marker"
        class:stored={copies[1] > 0}
        class:receiving={transfer?.to === 1}
      >
        <Cloud strokeWidth={1.55} /><span class="account-mark"><User /></span>
      </span>
    </div>
    <h3>Your cloud account</h3>
    <p class="storage-status" role="status" aria-atomic="true">
      {#if copies[1]}<Lock aria-hidden="true" />{/if}{storageStatus}
      {#if copies[1]}<span class="sr-only">
          , vault version {copies[1]}
        </span>{/if}
    </p>
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
</section>
