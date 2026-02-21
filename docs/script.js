document.addEventListener('DOMContentLoaded', () => {
  // --- Terminal Typing Animation ---

  const terminalOutput = document.getElementById('terminal-output');
  const cursor = document.getElementById('cursor');

  const lines = [
    { text: '> /shopify-cli-admin:shopify-query list all products with prices', type: 'input' },
    { text: '  Running query against Admin API...', type: 'output' },
    { text: '  ┌─────────────────────┬────────┐', type: 'output' },
    { text: '  │ Title               │ Price  │', type: 'output' },
    { text: '  ├─────────────────────┼────────┤', type: 'output' },
    { text: '  │ Classic Tee         │ $29.00 │', type: 'output' },
    { text: '  │ Everyday Hoodie     │ $65.00 │', type: 'output' },
    { text: '  └─────────────────────┴────────┘', type: 'output' },
    { text: '> /shopify-cli-admin:shopify-bulk-export products to CSV', type: 'input' },
    { text: '  ✓ Exported 1,247 products → products_export.csv', type: 'output' },
    { text: '> /shopify-cli-admin:shopify-dev-store-init', type: 'input' },
    { text: '  ✓ Created 50 products with images and inventory', type: 'output' },
  ];

  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async function typeLine(text) {
    for (let i = 0; i < text.length; i++) {
      terminalOutput.textContent += text[i];
      await sleep(40);
    }
  }

  async function printLine(text) {
    terminalOutput.textContent += text;
    await sleep(150);
  }

  async function runAnimation() {
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      if (line.type === 'input') {
        await typeLine(line.text);
      } else {
        await printLine(line.text);
      }

      // Add newline unless it's the last line
      if (i < lines.length - 1) {
        terminalOutput.textContent += '\n';
        await sleep(500);
      }
    }

    // Stop cursor blinking after animation completes
    if (cursor) {
      cursor.style.animationIterationCount = 'infinite';
    }
  }

  if (terminalOutput) {
    runAnimation();
  }

  // --- Copy-to-Clipboard ---

  const copyButtons = document.querySelectorAll('.copy-btn');

  copyButtons.forEach(btn => {
    btn.addEventListener('click', async () => {
      const text = btn.getAttribute('data-copy');
      if (!text) return;

      const iconCopy = btn.querySelector('.icon-copy');
      const iconCheck = btn.querySelector('.icon-check');

      try {
        await navigator.clipboard.writeText(text);

        if (iconCopy) iconCopy.style.display = 'none';
        if (iconCheck) iconCheck.style.display = 'inline';

        setTimeout(() => {
          if (iconCopy) iconCopy.style.display = 'inline';
          if (iconCheck) iconCheck.style.display = 'none';
        }, 2000);
      } catch {
        // Clipboard API not available — fail silently
      }
    });
  });

  // --- Tab ARIA Sync (progressive enhancement) ---

  const tabRadios = document.querySelectorAll('.tab-radio');
  const tabLabels = document.querySelectorAll('.tab-label');

  tabRadios.forEach(radio => {
    radio.addEventListener('change', () => {
      tabLabels.forEach(label => {
        label.setAttribute('aria-selected', label.getAttribute('for') === radio.id ? 'true' : 'false');
      });
    });
  });
});
