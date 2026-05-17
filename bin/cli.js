#!/usr/bin/env node

'use strict';

const fs   = require('fs');
const path = require('path');

const pkg = require('../package.json');

// ---------------------------------------------------------------------------
// CLI entry — accept `init` subcommand (or no args) to start the installer
// ---------------------------------------------------------------------------
const arg = process.argv[2];
if (arg !== undefined && arg !== 'init') {
  console.error(`\nUnknown command: ${arg}`);
  console.error(`Usage: autonomousguy init\n`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Frontmatter parser — no external deps
// ---------------------------------------------------------------------------
function parseFrontmatter(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const match   = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return { name: path.basename(filePath, '.md'), short: '', description: '' };
  const fm = {};
  for (const line of match[1].split('\n')) {
    const sep = line.indexOf(':');
    if (sep === -1) continue;
    const key = line.slice(0, sep).trim();
    const val = line.slice(sep + 1).trim().replace(/^['"]|['"]$/g, '');
    fm[key] = val;
  }
  return fm;
}

// ---------------------------------------------------------------------------
// Directory helpers
// ---------------------------------------------------------------------------
function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    entry.isDirectory() ? copyDir(s, d) : fs.copyFileSync(s, d);
  }
}

function loadSkillCategories(skillsDir) {
  return fs.readdirSync(skillsDir, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => {
      const catDir  = path.join(skillsDir, e.name);
      const skills  = fs.readdirSync(catDir)
        .filter(f => f.endsWith('.md'))
        .map(f => ({ file: f, ...parseFrontmatter(path.join(catDir, f)) }));
      return { category: e.name, skills };
    });
}

// ---------------------------------------------------------------------------
// Tool install-path registry
// ---------------------------------------------------------------------------
const TOOLS = [
  { name: 'Claude Code',    dir: '.claude'    },
  { name: 'GitHub Copilot', dir: '.github'    },
  { name: 'Cursor',         dir: '.cursor'    },
  { name: 'Gemini CLI',     dir: '.gemini'    },
  { name: 'ChatGPT Codex',  dir: '.agents'    },
  { name: 'OpenCode',       dir: '.opencode'  },
  { name: 'JetBrains AI',   dir: '.idea'      },
  { name: 'General Agent',  dir: '.autonomousguy' },
];

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
  // Lazy-load @inquirer/prompts after dependency check
  let prompts;
  try {
    prompts = require('@inquirer/prompts');
  } catch {
    console.error(
      '\nError: @inquirer/prompts is not installed.\n' +
      'Run: npm install  (inside the autonomousguy package directory)\n'
    );
    process.exit(1);
  }
  const { select, checkbox, confirm } = prompts;

  console.log(`\nautonomousguy v${pkg.version}`);
  console.log('AI skill prompts for embedded automotive engineers\n');

  // 1. Local or global
  const scope = await select({
    message: 'Install skills locally (this project) or globally (your user profile)?',
    choices: [
      { name: 'Local  — installs into the current directory', value: 'local' },
      { name: 'Global — installs into your home directory',   value: 'global' },
    ],
  });

  const baseDir = scope === 'global' ? require('os').homedir() : process.cwd();

  // 2. Which tools
  const selectedTools = await checkbox({
    message: 'Which AI tool(s) are you setting up for? (space to select, a to toggle all)',
    choices: TOOLS.map(t => ({ name: t.name, value: t, checked: false })),
    validate: v => v.length > 0 || 'Select at least one tool.',
  });

  // 3. Which skills
  const skillsDir    = path.join(__dirname, '..', 'skills');
  const categories   = loadSkillCategories(skillsDir);
  const totalCount   = categories.reduce((n, c) => n + c.skills.length, 0);

  const installAll = await confirm({
    message: `Install all ${totalCount} skills? (No = pick categories)`,
    default: true,
  });

  let selectedCategories = categories;

  if (!installAll) {
    const pickedCats = await checkbox({
      message: 'Which skill categories?',
      choices: categories.map(c => ({
        name: `${c.category.padEnd(22)} (${c.skills.length} skills)`,
        value: c,
        checked: true,
      })),
      validate: v => v.length > 0 || 'Select at least one category.',
    });

    // Per-category skill selection
    selectedCategories = [];
    for (const cat of pickedCats) {
      const allInCat = await confirm({
        message: `Install all ${cat.skills.length} skills in [${cat.category}]?`,
        default: true,
      });

      if (allInCat) {
        selectedCategories.push(cat);
      } else {
        const pickedSkills = await checkbox({
          message: `Select skills from [${cat.category}]:`,
          choices: cat.skills.map(s => ({
            name: `${(s.name || s.file).padEnd(36)} ${s.short}`,
            value: s,
            checked: true,
          })),
        });
        if (pickedSkills.length > 0) {
          selectedCategories.push({ ...cat, skills: pickedSkills });
        }
      }
    }
  }

  // 4. Copy
  console.log('\nInstalling...\n');
  let copiedTotal = 0;

  for (const tool of selectedTools) {
    const destBase = path.join(baseDir, tool.dir, 'skills', 'autonomousguy');
    for (const cat of selectedCategories) {
      const srcCat  = path.join(skillsDir, cat.category);
      const destCat = path.join(destBase, cat.category);
      fs.mkdirSync(destCat, { recursive: true });
      for (const skill of cat.skills) {
        fs.copyFileSync(path.join(srcCat, skill.file), path.join(destCat, skill.file));
        copiedTotal++;
      }
    }
    const rel = scope === 'global'
      ? path.join('~', tool.dir, 'skills', 'autonomousguy')
      : path.join(tool.dir, 'skills', 'autonomousguy');
    console.log(`  ✓ ${tool.name.padEnd(18)} → ${rel}`);
  }

  // 5. Summary
  const skillCount = selectedCategories.reduce((n, c) => n + c.skills.length, 0);
  console.log(`\nInstalled ${skillCount} skills across ${selectedTools.length} tool(s).`);
  console.log('\nTo use a skill: paste its contents into your AI tool of choice,');
  console.log('or invoke it by name if your tool supports skill discovery.\n');

  if (selectedCategories.some(c => c.category === 'workspace')) {
    console.log('Tip: run the [codebase-analysis] skill first in a new project to');
    console.log('generate .autonomousguy/CODEBASE_MAP.md — all other skills will');
    console.log('reference it automatically.\n');
  }
}

main().catch(err => {
  console.error('\nError:', err.message);
  process.exit(1);
});
