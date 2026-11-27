<script>
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import UserRound from "@lucide/svelte/icons/user-round";

  let { vault, account, linkedDevice } = $props();

  const locations = $derived([
    {
      kind: "laptop",
      name: "This device",
      copy: "Local copy",
      stored: !!vault,
      current: !vault,
    },
    {
      kind: "cloud",
      name: "Your cloud account",
      copy: "Encrypted sync copy",
      stored: !!account,
      current: !!vault && !account,
    },
    {
      kind: "phone",
      name: linkedDevice || "Second device",
      copy: "Local copy",
      stored: !!linkedDevice,
      current: !!account && !linkedDevice,
    },
  ]);
</script>

{#snippet vaultTag(outline = false)}
  <span class="vault-tag" class:outline aria-hidden="true"><i></i></span>
{/snippet}

<figure
  class="sync-view"
  aria-labelledby="sync-title"
  aria-describedby="sync-direction"
>
  <figcaption class="sync-caption">
    <strong id="sync-title">
      {linkedDevice ? "Your keyring" : "How your vault syncs"}
    </strong>
    <span class="vault-legend">{@render vaultTag()}Encrypted vault</span>
  </figcaption>
  <span class="sr-only" id="sync-direction">
    Each device keeps a local vault. Changes sync in both directions through
    your own cloud account.
  </span>

  <ol class="locations" role="list" aria-label="Vault locations">
    {#each locations as location, i (location.kind)}
      <li
        class="location"
        data-kind={location.kind}
        class:stored={location.stored}
        class:current={location.current}
        aria-current={location.current ? "location" : undefined}
      >
        <div class="object-stage" aria-hidden="true">
          {#if i < locations.length - 1}
            <span class="sync-leg" class:connected={locations[i + 1].stored}>
              <span class="outbound"></span>
              <span class="inbound"></span>
              {#if locations[i + 1].stored}
                {#key location.kind === "laptop" ? account : linkedDevice}
                  <span class="moving-vault">{@render vaultTag()}</span>
                {/key}
              {/if}
            </span>
          {/if}
          {#if location.kind === "laptop"}
            <span class="laptop">
              <span class="screen">{@render vaultTag(!location.stored)}</span>
              <span class="keyboard-deck"></span>
            </span>
          {:else if location.kind === "cloud"}
            <span class="cloud-object">
              <Cloud
                class="cloud-shell"
                viewBox="0 3 24 18"
                strokeWidth={0.85}
              />
              {@render vaultTag(!location.stored)}
              <span class="account-mark"><UserRound /></span>
            </span>
          {:else}
            <span class="phone">{@render vaultTag(!location.stored)}</span>
          {/if}
        </div>
        <strong class="location-name">{location.name}</strong>
        <span class="copy-role">
          <span>
            {#if location.stored}<Check
                aria-hidden="true"
              />{/if}{location.copy}
          </span>
          <span class="sr-only">
            {location.stored ? ", saved" : ", planned"}
          </span>
        </span>
      </li>
    {/each}
  </ol>
</figure>

<style>
  .sync-view {
    --laptop-width: clamp(64px, 21cqw, 132px);
    --cloud-width: clamp(59px, 19cqw, 120px);
    --phone-width: clamp(28px, 8.6cqw, 52px);
    --tag-size: clamp(17px, 4.7cqw, 30px);
    --travel-delay: 140ms;
    --travel-time: 560ms;
    margin: 0;
    padding: clamp(17px, 4.4cqw, 29px) clamp(8px, 2.7cqw, 19px)
      clamp(18px, 3.6cqw, 25px);
    background:
      radial-gradient(ellipse at 48% 45%, #45404340, transparent 68%),
      linear-gradient(115deg, #242123, #1a1a1d 80%);
  }

  .sync-caption,
  .vault-legend {
    display: flex;
    align-items: center;
  }
  .sync-caption {
    justify-content: space-between;
    gap: 8px 16px;
    padding-inline: clamp(4px, 1.6cqw, 12px);
  }
  #sync-title {
    margin: 0;
    font-size: clamp(1rem, 3.7cqw, 1.48rem);
    font-weight: 555;
    line-height: 1.2;
    letter-spacing: -0.042em;
    color: #f6f2ed;
  }
  .vault-legend {
    --tag-size: 14px;
    flex: none;
    gap: 9px;
    color: #d6cec8;
    font: 400 0.8125rem/1.35 var(--mono);
  }
  .locations {
    position: relative;
    isolation: isolate;
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    grid-template-rows: auto auto auto;
    grid-auto-flow: column;
    margin: clamp(10px, 2.1cqw, 17px) 0 0;
    padding: 0;
    list-style: none;
  }
  .locations::before {
    content: "";
    position: absolute;
    z-index: -1;
    inset: 0 0 30%;
    background: radial-gradient(#b3a1963d 0.75px, transparent 0.9px) center /
      12px 12px;
    mask-image: radial-gradient(ellipse at center, black 25%, transparent 76%);
    pointer-events: none;
  }
  .location {
    min-width: 0;
    display: grid;
    grid-template-rows: subgrid;
    grid-row: 1 / span 3;
    justify-items: center;
    text-align: center;
  }
  .object-stage {
    position: relative;
    width: 100%;
    height: clamp(70px, 20cqw, 123px);
    display: grid;
    place-items: center;
  }
  .location-name {
    min-width: 0;
    align-self: start;
    margin-inline: 3px;
    color: #e8e3df;
    font-size: clamp(0.875rem, 2.9cqw, 1.0625rem);
    font-weight: 570;
    line-height: 1.23;
    letter-spacing: -0.028em;
    overflow-wrap: anywhere;
    text-wrap: balance;
  }
  .copy-role {
    align-self: start;
    max-width: 100%;
    margin: 4px 2px 0;
    color: #b9b2af;
    font: 400 0.8125rem/1.32 var(--mono);
    text-wrap: balance;
  }
  .copy-role :global(svg) {
    display: inline-block;
    width: 12px;
    height: 12px;
    margin-inline-end: 4px;
    vertical-align: -0.1em;
    color: #ffae73;
  }
  .current .location-name,
  .stored .copy-role {
    color: #fbc7a4;
  }

  /* The same keyhole tag appears in the legend, inside each copy, and in transit. */
  .vault-tag {
    --cutout: #51270f;
    position: relative;
    display: inline-block;
    flex: none;
    font-size: var(--tag-size);
    width: 1em;
    height: 1.06em;
    border: 1px solid #ffb36d;
    border-radius: 0.075em;
    transform: rotate(-9deg);
    background: linear-gradient(133deg, #ffb55e, #ff822b 54%, #ce570e);
    box-shadow:
      inset 0.04em 0.035em 0 #ffd6a3,
      0.085em 0.055em 0 #aaa298,
      0.15em 0.12em 0 #3e3939;
  }
  .vault-tag::before {
    content: "";
    position: absolute;
    left: 0.1em;
    top: 0.09em;
    width: 0.12em;
    height: 0.12em;
    border-radius: 50%;
    background: var(--cutout);
  }
  .vault-tag i {
    position: absolute;
    left: 50%;
    top: 22%;
  }
  .vault-tag i::before,
  .vault-tag i::after {
    content: "";
    position: absolute;
    left: 0;
    transform: translateX(-50%);
    background: var(--cutout);
  }
  .vault-tag i::before {
    width: 0.34em;
    height: 0.34em;
    border-radius: 50%;
  }
  .vault-tag i::after {
    top: 0.26em;
    width: 0.28em;
    height: 0.3em;
    clip-path: polygon(32% 0, 68% 0, 100% 100%, 0 100%);
  }
  .vault-tag.outline {
    --cutout: #bcaa9b;
    border: 1px dashed #b7a697;
    background: #322e2b;
    box-shadow: 0.09em 0.075em 0 #4a4240;
    outline: none;
  }
  .current .vault-tag.outline {
    --cutout: #ffc294;
    background: #4c3529;
    border-color: #ffaf74;
  }

  .laptop,
  .phone,
  .cloud-object {
    position: relative;
    filter: drop-shadow(0 4px 4px #07070888);
  }
  .laptop {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: var(--laptop-width);
    aspect-ratio: 1.62;
  }
  .screen,
  .phone {
    display: grid;
    place-items: center;
    border: clamp(2px, 0.53cqw, 3px) solid #aba7a8;
    background: linear-gradient(
      148deg,
      #484448,
      #28272b 45%,
      #17171a 78%,
      #343135
    );
    box-shadow:
      inset 0 0 0 2px #171619,
      inset 0 0 0 3px #77737855;
  }
  .screen {
    position: relative;
    flex: 1;
    width: 89%;
    border-bottom-color: #78767a;
  }
  .screen::before,
  .phone::before,
  .phone::after {
    content: "";
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    background: #101012;
  }
  .screen::before {
    top: 0;
    width: 4px;
    height: 2px;
  }
  .keyboard-deck {
    height: 10%;
    min-height: 4px;
    width: 100%;
    background: linear-gradient(#d4d0cf, #a49fa1 45%, #767277 50%, #4e4b50);
    clip-path: polygon(6% 0, 94% 0, 100% 58%, 98% 95%, 2% 95%, 0 58%);
  }
  .cloud-object {
    display: grid;
    place-items: center;
    width: var(--cloud-width);
    aspect-ratio: 4 / 3;
  }
  .cloud-object :global(.cloud-shell) {
    position: absolute;
    width: 100%;
    height: 100%;
    color: #b4aeb0;
    fill: #373438;
    filter: drop-shadow(1px 2px 0 #676165);
  }
  .cloud-object .vault-tag {
    margin-top: 7%;
  }
  .account-mark {
    position: absolute;
    right: 1%;
    bottom: 5%;
    display: grid;
    place-items: center;
    width: clamp(14px, 3.5cqw, 23px);
    aspect-ratio: 1;
    border: 1px solid #8b8487;
    background: #292629;
    color: #e3dad3;
  }
  .account-mark :global(svg) {
    width: 76%;
    height: 76%;
  }
  .phone {
    --tag-size: clamp(13px, 3.45cqw, 21px);
    width: var(--phone-width);
    aspect-ratio: 0.55;
    border-radius: 4px;
  }
  .phone::before {
    top: 1px;
    width: 32%;
    height: 3px;
  }
  .phone::after {
    bottom: 3px;
    width: 33%;
    height: 2px;
    background: #8a8487;
  }
  .current .screen,
  .current .phone {
    border-color: #eeb089;
  }
  .current .cloud-object :global(.cloud-shell) {
    color: #eeb089;
  }

  .location[data-kind="laptop"] {
    --from: var(--laptop-width);
    --to: var(--cloud-width);
  }
  .location[data-kind="cloud"] {
    --from: var(--cloud-width);
    --to: var(--phone-width);
  }
  .sync-leg {
    position: absolute;
    top: 50%;
    left: calc(50% + var(--from) / 2 + 4px);
    width: calc(100% - (var(--from) + var(--to)) / 2 - 8px);
    height: 10px;
    transform: translateY(-50%);
    color: #9a918c;
  }
  .outbound,
  .inbound {
    position: absolute;
    left: 0;
    right: 0;
    border-top: 1px dashed;
  }
  .outbound {
    top: 1px;
  }
  .inbound {
    bottom: 1px;
  }
  .outbound::after,
  .inbound::before {
    content: "";
    position: absolute;
    top: -3px;
    width: 5px;
    height: 5px;
    border-top: 1px solid;
    border-right: 1px solid;
  }
  .outbound::after {
    right: 0;
    transform: rotate(45deg);
  }
  .inbound::before {
    left: 0;
    transform: rotate(-135deg);
  }
  .connected {
    color: #ed9a61;
  }
  .connected > .outbound,
  .connected > .inbound {
    border-top-style: solid;
  }
  .moving-vault {
    --tag-size: clamp(10px, 2.7cqw, 16px);
    position: absolute;
    z-index: 1;
    top: 1px;
    left: 0;
    display: grid;
    opacity: 0;
    transform: translate(-50%, -50%);
  }
  @media (prefers-reduced-motion: no-preference) {
    .moving-vault {
      animation: carry-copy var(--travel-time) var(--travel-delay) ease-in-out;
    }
    .cloud-object,
    .phone {
      --arrival-delay: calc(var(--travel-delay) + var(--travel-time));
    }
    .stored .object-stage > :is(.laptop, .cloud-object, .phone) .vault-tag {
      animation: seat-copy 240ms var(--arrival-delay, 0ms) ease-out backwards;
    }
  }
  @keyframes carry-copy {
    0% {
      left: 0;
      opacity: 0;
    }
    18%,
    82% {
      opacity: 1;
    }
    100% {
      left: 100%;
      opacity: 0;
    }
  }
  @keyframes seat-copy {
    from {
      opacity: 0.4;
      transform: translateY(-3px) rotate(-9deg) scale(0.85);
    }
    to {
      opacity: 1;
      transform: rotate(-9deg);
    }
  }
  @container (max-width: 420px) {
    .vault-legend {
      --tag-size: 12px;
      gap: 6px;
      font-size: 0.75rem;
    }
    .copy-role {
      font-size: 0.75rem;
    }
    .copy-role :global(svg) {
      width: 10px;
      height: 10px;
      margin-inline-end: 2px;
    }
  }
  @container (max-width: 335px) {
    .sync-caption {
      flex-wrap: wrap;
      row-gap: 7px;
    }
    #sync-title {
      flex: none;
    }
  }
</style>
