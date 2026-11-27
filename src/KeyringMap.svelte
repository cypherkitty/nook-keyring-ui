<script>
  import { Button } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Link from "@lucide/svelte/icons/link";
  import Loader from "@lucide/svelte/icons/loader-circle";
  import Plus from "@lucide/svelte/icons/plus";
  import Refresh from "@lucide/svelte/icons/refresh-cw";

  let {
    copies,
    memberCount,
    transfer,
    hopDuration,
    onCreate,
    onLink,
    onReplay,
  } = $props();

  const linked = $derived(memberCount === 2);
  const locations = $derived([
    {
      kind: "laptop",
      control: memberCount === 0 ? "create-vault" : undefined,
      name: "This device",
      detail: copies[0] ? "Local copy" : "Create here",
    },
    {
      kind: "folder",
      name: "Your cloud account",
      detail: copies[1] ? "Sync copy" : "Sync storage",
    },
    {
      kind: "phone",
      control: memberCount === 1 && !transfer ? "link-device" : undefined,
      name: linked ? "Linked device" : "Second device",
      detail: linked
        ? "Local copy"
        : transfer
          ? "Waiting for copy"
          : memberCount
            ? "Ready to link"
            : "Link next",
    },
  ]);
  const destinations = [
    "Syncing to this device",
    "Saving to your cloud account",
    "Syncing to the second device",
  ];
  const status = $derived(
    transfer
      ? destinations[transfer.to]
      : linked
        ? "2 devices in sync"
        : memberCount
          ? "1 device in your cloud"
          : "",
  );
</script>

{#snippet vaultTag(outline = false)}
  <span class="vault-tag" class:outline-tag={outline} aria-hidden="true">
    <span class="tag-keyhole"></span>
  </span>
{/snippet}

<section
  id="sync-map"
  class="cloud-builder"
  tabindex="-1"
  aria-label="Encrypted vault sync through your own cloud account"
  style={"--hop-time: " + hopDuration + "ms"}
>
  <Card.Root class="vault-map rounded-none shadow-none">
    <Card.Content class="route-content">
      <ol class="vault-route" aria-label="Where your vault copies live">
        {#each locations as location, i}
          {@const stored = copies[i] > 0}
          <li
            class="vault-location"
            data-kind={location.kind}
            class:stored
            class:upcoming={i > 0 && !memberCount}
            class:receiving={transfer?.to === i}
          >
            <div class="scene-spot" aria-hidden="true">
              {#if i < locations.length - 1}
                {@const moving =
                  transfer && Math.min(transfer.from, transfer.to) === i}
                <div
                  class="journey-leg"
                  class:connected={stored && copies[i + 1] > 0}
                  class:moving
                >
                  <span class="sync-line"></span>
                  {#if moving}
                    <span
                      class="travelling-copy"
                      class:reverse={transfer.from > transfer.to}
                    >
                      {@render vaultTag()}
                    </span>
                  {/if}
                </div>
              {/if}
              <svelte:element
                this={location.control ? "label" : "div"}
                class="location-object"
                for={location.control}
                title={location.control
                  ? i === 0
                    ? "Create vault on this device"
                    : "Link through your cloud account"
                  : undefined}
              >
                {#if location.kind === "laptop"}
                  <span class="laptop">
                    <span class="laptop-lid">
                      <span class="screen-slot">
                        {@render vaultTag(!stored)}
                      </span>
                    </span>
                    <span class="keyboard-deck"></span>
                  </span>
                {:else if location.kind === "folder"}
                  <span class="account-folder">
                    <span class="folder-back"></span>
                    <span class="folder-inside"></span>
                    {#if stored}<span class="folder-copy">
                        {@render vaultTag()}
                      </span>{/if}
                    <span class="folder-pocket">
                      <Cloud strokeWidth={1.65} />
                    </span>
                  </span>
                {:else}
                  <span class="phone">
                    <span class="screen-slot">
                      {#if stored}{@render vaultTag()}{:else if memberCount}{@render vaultTag(
                          true,
                        )}{/if}
                    </span>
                  </span>
                {/if}
              </svelte:element>
            </div>
            <h2>{location.name}</h2>
            <p class="location-detail">
              {transfer?.to === i ? "Receiving copy" : location.detail}
              {#if stored}<span class="sr-only">
                  , encrypted vault version {copies[i]}
                </span>{/if}
            </p>
          </li>
        {/each}
      </ol>
    </Card.Content>

    <Card.Footer class="map-controls" data-local-step={memberCount === 0}>
      <div class="vault-identity">
        <span class="tag-sample" aria-hidden="true">{@render vaultTag()}</span>
        <div>
          <h3>Encrypted vault</h3>
          <p class="sync-status" role="status" aria-atomic="true">
            {status}{#if linked && !transfer}<span class="sr-only">
                , vault version {copies[0]}
              </span>{/if}
          </p>
        </div>
      </div>
      {#if !memberCount}
        <Button
          id="create-vault"
          aria-label="Create vault"
          class="map-action rounded-none"
          onclick={onCreate}
        >
          <Plus aria-hidden="true" />Create vault
        </Button>
      {:else if !linked}
        <Button
          id="link-device"
          aria-label={transfer ? "Linking…" : "Link second device"}
          class="map-action rounded-none"
          onclick={onLink}
          disabled={!!transfer}
          aria-busy={!!transfer}
        >
          {#if transfer}<Loader
              class="spinner"
              aria-hidden="true"
            />Linking…{:else}<Link aria-hidden="true" />Link second device{/if}
        </Button>
      {:else}
        <Button
          variant="outline"
          class="map-action replay rounded-none"
          aria-label="Replay encrypted sync"
          onclick={onReplay}
          disabled={!!transfer}
        >
          <Refresh aria-hidden="true" />Replay sync
        </Button>
      {/if}
    </Card.Footer>
  </Card.Root>
</section>
