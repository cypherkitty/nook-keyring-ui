<script>
  let { stage, attach = false } = $props();
  const artwork = import.meta.env.BASE_URL + "keyring/";
  const frames = [
    { stage: "ready", src: artwork + "ready.webp" },
    { stage: "local", src: artwork + "local-vault.webp" },
    { stage: "cloud", src: artwork + "cloud-copy.webp" },
    { stage: "linked", src: artwork + "keyring-original.png" },
  ];
</script>

<figure
  class="photo-stack"
  class:assembling={attach}
  role="img"
  aria-label={stage === "ready"
    ? "An empty steel ring with the first orange device tag waiting beside it."
    : stage === "local"
      ? "The orange tag is now attached to the ring. Your first device holds the encrypted vault."
      : stage === "cloud"
        ? "A silver tag has joined the orange tag. Your own cloud holds an encrypted sync copy."
        : "The complete keyring. The two device tags and silver cloud copy are together on the ring."}
>
  {#each frames as frame (frame.stage)}
    <picture
      class="frame"
      class:shown={stage === frame.stage}
      data-frame={frame.stage}
      aria-hidden="true"
    >
      {#if frame.stage === "linked"}<source
          media="(max-width: 680px)"
          srcset={artwork + "vault-ring.webp"}
        />{/if}
      <img
        src={frame.src}
        width="1448"
        height="1086"
        alt=""
        fetchpriority={frame.stage === "ready"
          ? "high"
          : frame.stage === "linked"
            ? "low"
            : "auto"}
        draggable="false"
      />
    </picture>
  {/each}
  {#if stage === "local" && attach}
    <div class="first-attachment" aria-hidden="true">
      <!-- Separate the amber acrylic from the neutral studio backdrop while the tag moves. -->
      <svg width="0" height="0" focusable="false">
        <defs>
          <filter id="loose-tag" color-interpolation-filters="sRGB">
            <feColorMatrix
              type="matrix"
              values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  8 0 -8 0 -.09"
            />
          </filter>
          <filter id="empty-studio" color-interpolation-filters="sRGB">
            <feColorMatrix
              type="matrix"
              values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  -8 0 8 0 1.09"
            />
          </filter>
        </defs>
      </svg>
      <i class="still-ring"></i><i class="travelling-tag"></i>
    </div>
  {/if}
</figure>
