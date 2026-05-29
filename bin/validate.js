#!/usr/bin/env node
'use strict';

const fs   = require('fs');
const path = require('path');
const glob = require('fs').readdirSync;

const REQUIRED_FM_KEYS = ['name', 'short', 'description', 'category', 'tags'];
const REQUIRED_SECTIONS = [
  '## Context',
  '## Instructions',
  '## Input expected',
  '## Output format',
  '## Example',
];

function validateFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const errors  = [];

  // Check frontmatter
  const fmMatch = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!fmMatch) {
    errors.push('missing YAML frontmatter');
  } else {
    const fm = fmMatch[1];
    for (const key of REQUIRED_FM_KEYS) {
      if (!new RegExp(`^${key}\\s*:`, 'm').test(fm)) {
        errors.push(`frontmatter missing key: ${key}`);
      }
    }
  }

  // Check sections in order
  let searchFrom = 0;
  for (const section of REQUIRED_SECTIONS) {
    const idx = content.indexOf(section, searchFrom);
    if (idx === -1) {
      errors.push(`missing section: ${section}`);
    } else {
      searchFrom = idx + section.length;
    }
  }

  return errors;
}

function findSkillFiles(dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) results.push(...findSkillFiles(full));
    else if (entry.name.endsWith('.md')) results.push(full);
  }
  return results;
}

const skillsDir = path.join(__dirname, '..', 'skills');
const files     = findSkillFiles(skillsDir);
let   failed    = 0;

for (const file of files) {
  const errors = validateFile(file);
  if (errors.length > 0) {
    const rel = path.relative(process.cwd(), file);
    for (const err of errors) {
      console.error(`FAIL  ${rel}: ${err}`);
    }
    failed++;
  }
}

if (failed > 0) {
  console.error(`\n${failed} skill file(s) failed validation.`);
  process.exit(1);
} else {
  console.log(`OK  ${files.length} skill files validated.`);
}
