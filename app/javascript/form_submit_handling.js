function findSubmitButton(form) {
  return (
    form.querySelector("button[type='submit']") ||
    form.querySelector("input[type='submit']") ||
    form.querySelector(".kv-primary-button")
  );
}

function setButtonLoading(btn) {
  if (!btn || btn.dataset.loading === "true") return;
  if (btn.dataset.noLoading === "true") return;

  btn.dataset.loading = "true";

  if (btn.tagName === "BUTTON") {
    btn.dataset.originalText = btn.textContent;
  } else if (btn.tagName === "INPUT") {
    btn.dataset.originalText = btn.value;
  }

  const original = btn.dataset.originalText || "";
  let loadingText = "Loading…";

  const lower = original.toLowerCase();
  if (lower.includes("ask")) {
    loadingText = "Asking…";
  } else if (lower.includes("upload")) {
    loadingText = "Uploading…";
  } else if (lower.includes("connect")) {
    loadingText = "Connecting…";
  } else if (lower.includes("save")) {
    loadingText = "Saving…";
  }

  if (btn.tagName === "BUTTON") {
    btn.textContent = loadingText;
  } else if (btn.tagName === "INPUT") {
    btn.value = loadingText;
  }

  btn.classList.add("kv-button-loading");
  btn.disabled = true;
}

function clearButtonLoading(btn) {
  if (!btn || btn.dataset.loading !== "true") return;

  const original = btn.dataset.originalText;

  if (original) {
    if (btn.tagName === "BUTTON") {
      btn.textContent = original;
    } else if (btn.tagName === "INPUT") {
      btn.value = original;
    }
  }

  btn.classList.remove("kv-button-loading");
  btn.disabled = false;
  delete btn.dataset.loading;
  delete btn.dataset.originalText;
}

function restoreAllLoadingButtons() {
  document
    .querySelectorAll("[data-loading='true']")
    .forEach((btn) => clearButtonLoading(btn));
}

function attachFormSubmitHandling() {
  document.addEventListener("submit", function (event) {
    const form = event.target;
    if (!(form instanceof HTMLFormElement)) return;

    const btn = findSubmitButton(form);
    if (!btn) return;

    if (btn.dataset.loading === "true") {
      // Prevent double-submit if somehow triggered again
      event.preventDefault();
      return;
    }

    setButtonLoading(btn);
  });

  // For Turbo responses that render validation errors on the same page,
  // make sure buttons become clickable again.
  document.addEventListener("turbo:submit-end", function () {
    restoreAllLoadingButtons();
  });

  // Before Turbo caches the page (navigating away), clean up state.
  document.addEventListener("turbo:before-cache", function () {
    restoreAllLoadingButtons();
  });
}

// Initialize on first load
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", attachFormSubmitHandling);
} else {
  attachFormSubmitHandling();
}

// When the browser restores a page from the back/forward cache (bfcache),
// clear any loading state that was set before the user navigated away.
// This covers full-page navigations (data-turbo="false") where
// turbo:before-cache never fires.
window.addEventListener("pageshow", function (event) {
  if (event.persisted) {
    restoreAllLoadingButtons();
  }
});

