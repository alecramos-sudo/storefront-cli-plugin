document.addEventListener('DOMContentLoaded', () => {
  // --- Terminal Typing Animation ---

  const terminalOutput = document.getElementById('terminal-output');
  const cursor = document.getElementById('cursor');

  const lines = [
    { text: '$ claude', type: 'input' },
    { text: '> /plugin marketplace add alecramos-sudo/storefront-cli-plugin', type: 'input' },
    { text: '  \u2713 Added marketplace: storefront-cli-plugin', type: 'output' },
    { text: '> /plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugin', type: 'input' },
    { text: '  \u2713 Installed: shopify-cli-admin v1.0.0', type: 'output' },
    { text: '> /shopify-cli-admin:shopify-query list all products with prices', type: 'input' },
    { text: '  Running query against Admin API...', type: 'output' },
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
});
