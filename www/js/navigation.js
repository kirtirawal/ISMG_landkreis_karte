// ============================================================
// Module Card Navigation
// ============================================================

$(document).on("click", ".navigation-card", function () {

    const target = $(this).data("target");

    if (!target) return;

    Shiny.setInputValue(
        "navigation_target",
        target,
        {
            priority: "event"
        }
    );

});


// ============================================================
// Logo Navigation → Landing Page
// ============================================================

$(document).on("click", "#home_logo", function (e) {

    e.preventDefault();

    Shiny.setInputValue(
        "navigation_target",
        "landing",
        {
            priority: "event"
        }
    );

});

// ============================================================
// Gallery — Prototype Selection
// ============================================================

$(document).on("click", ".gallery-wrap .sel-btn", function (e) {
  e.preventDefault();

  const $btn  = $(this);
  const $root = $btn.closest(".gallery-wrap");

  if (!$root.length) return;

  const p = String($btn.data("p") || "");
  if (!p) return;

  // 1. Reset every button inside this gallery instance
  $root.find(".sel-btn").each(function () {
    $(this)
      .removeClass("active-sel")
      .text("Select →")
      .attr("aria-pressed", "false");
  });

  // 2. Highlight the chosen one
  $btn
    .addClass("active-sel")
    .text("✓ Selected")
    .attr("aria-pressed", "true");

  // 3. Show the banner
  const $banner = $root.find(".sel-banner").first();
  if ($banner.length) {
    $banner.addClass("visible");

    // 4. Write the label directly (no server needed)
    const labels = {
      "1": "Prototype 01 — Multi-line trend chart",
      "2": "Prototype 02 — Diverging bar chart",
      "3": "Prototype 03 — Heatmap (region × year)",
      "4": "Prototype 04 — Bubble chart (3 variables)",
      "5": "Prototype 05 — Slope chart",
      "7": "Prototype 06 — Small multiples",
      "8": "Prototype 07 — North–south ranked bar"
    };

    // The banner markup is: <div class="sel-banner"><span class="sel-banner-label">…</span><div id="...selected_label">…</div></div>
    // We write into the shiny-output div if it exists; otherwise append a span.
    let $slot = $banner.find(".shiny-html-output, [id$='selected_label']").first();
    if (!$slot.length) {
      $slot = $("<span>").appendTo($banner);
    }
    $slot.html(
      '<span style="color:#1e7a5e;font-weight:700;font-size:0.95rem;">' +
      (labels[p] || ("Prototype " + p)) +
      "</span>"
    );

    // 5. Smooth-scroll it into view
    $banner[0].scrollIntoView({ behavior: "smooth", block: "nearest" });
  }

  // 6. OPTIONAL — tell Shiny so R can log / tally the vote
  //    (uncomment if you want server-side awareness)
  // Shiny.setInputValue(
  //   "gallery_prototype_selected",
  //   { prototype: p, ts: Date.now() },
  //   { priority: "event" }
  // );
});