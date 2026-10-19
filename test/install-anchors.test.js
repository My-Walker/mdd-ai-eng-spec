"use strict";

const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const {
  PACKAGE_ID,
  START,
  END,
  findHostRoot,
  installAnchors,
} = require("../scripts/install-anchors.js");

function tempDir() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "mdd-ai-eng-"));
}

function read(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

const specsDir = path.join(__dirname, "..", "ai-engineering-specs");

const freshHost = tempDir();
const fresh = installAnchors(freshHost, specsDir);
assert.strictEqual(fresh.cursor.action, "write");
assert.strictEqual(fresh.kilo.action, "write");
assert.ok(fresh.agentsRel.includes("ai-engineering-specs/AGENTS.md"));
const cursorText = read(fresh.cursor.filePath);
const kiloText = read(fresh.kilo.filePath);
assert.ok(cursorText.includes(START) && cursorText.includes(END));
assert.ok(kiloText.startsWith(START));
assert.ok(kiloText.includes(fresh.agentsRel));
assert.ok(cursorText.includes("必须先用读取工具完整加载"));
assert.ok(kiloText.includes("必须先用读取工具完整加载"));
assert.ok(!cursorText.includes("原子实体文件"));
assert.ok(!kiloText.includes("原子实体文件"));

const again = installAnchors(freshHost, specsDir);
assert.strictEqual(again.cursor.action, "skip");
assert.strictEqual(again.kilo.action, "skip");
assert.strictEqual(read(fresh.cursor.filePath), cursorText);
assert.strictEqual(read(fresh.kilo.filePath), kiloText);

const customHost = tempDir();
const customCursor = path.join(customHost, ".cursor", "rules", `${PACKAGE_ID}.mdc`);
fs.mkdirSync(path.dirname(customCursor), { recursive: true });
fs.writeFileSync(customCursor, "keep-me\n", "utf8");
fs.writeFileSync(path.join(customHost, ".kilocoderrules"), "原有项目说明\n", "utf8");
const custom = installAnchors(customHost, specsDir);
assert.strictEqual(custom.cursor.action, "update");
assert.ok(read(customCursor).includes(custom.agentsRel));
assert.ok(!read(customCursor).includes("keep-me"));
assert.strictEqual(custom.kilo.action, "update");
const customKilo = read(custom.kilo.filePath);
assert.ok(customKilo.startsWith(START));
assert.ok(customKilo.includes(END));
assert.ok(customKilo.endsWith("原有项目说明\n"));

const staleHost = tempDir();
fs.mkdirSync(path.join(staleHost, ".cursor", "rules"), { recursive: true });
fs.writeFileSync(
  path.join(staleHost, ".cursor", "rules", `${PACKAGE_ID}.mdc`),
  "old-cursor\n",
  "utf8"
);
fs.writeFileSync(
  path.join(staleHost, ".kilocoderrules"),
  `${START}\n旧路径\n${END}\n项目说明\n`,
  "utf8"
);
const stale = installAnchors(staleHost, specsDir);
assert.strictEqual(stale.cursor.action, "update");
assert.strictEqual(stale.kilo.action, "update");
const staleKilo = read(stale.kilo.filePath);
assert.ok(staleKilo.includes(stale.agentsRel));
assert.ok(!staleKilo.includes("旧路径"));
assert.ok(staleKilo.endsWith("项目说明\n"));

const linkedHost = tempDir();
const linkedAgents = path.join(
  linkedHost,
  "node_modules",
  "@mdd-ai-eng",
  "specs",
  "ai-engineering-specs",
  "AGENTS.md"
);
fs.mkdirSync(path.dirname(linkedAgents), { recursive: true });
fs.writeFileSync(linkedAgents, "# installed\n", "utf8");
const linked = installAnchors(linkedHost, specsDir);
assert.strictEqual(
  linked.agentsRel,
  "./node_modules/@mdd-ai-eng/specs/ai-engineering-specs/AGENTS.md"
);

const installedRoot = path.join(tempDir(), "node_modules", "@mdd-ai-eng", "specs");
const previousInit = process.env.INIT_CWD;
process.env.INIT_CWD = path.join(tempDir(), "consumer-app");
assert.strictEqual(findHostRoot(installedRoot), path.resolve(process.env.INIT_CWD));
if (previousInit === undefined) {
  delete process.env.INIT_CWD;
} else {
  process.env.INIT_CWD = previousInit;
}

console.log("install-anchors 单元测试通过");
