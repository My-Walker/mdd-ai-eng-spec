#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const PACKAGE_ID = "mdd-ai-eng";
const START = `<!-- ${PACKAGE_ID}:start -->`;
const END = `<!-- ${PACKAGE_ID}:end -->`;
const packageRoot = path.resolve(__dirname, "..");
const specsDir = path.join(packageRoot, "ai-engineering-specs");

function findHostRoot(rootDir = packageRoot) {
  const parts = rootDir.split(path.sep);
  const nodeModulesIndex = parts.lastIndexOf("node_modules");
  if (nodeModulesIndex !== -1) {
    if (process.env.INIT_CWD) {
      return path.resolve(process.env.INIT_CWD);
    }
    return parts.slice(0, nodeModulesIndex).join(path.sep);
  }
  return rootDir;
}

function toPosixRelative(fromDir, targetFile) {
  let relativePath = path.relative(fromDir, targetFile);
  if (!relativePath.startsWith(".")) {
    relativePath = `.${path.sep}${relativePath}`;
  }
  return relativePath.split(path.sep).join("/");
}

function anchorBody(agentsRel) {
  return [
    `# ${PACKAGE_ID} 激活锚点`,
    "",
    `会话开始或接到任何任务时，必须先用读取工具完整加载 \`${agentsRel}\`。该文件是最高行动准则。禁止用本锚点代替该文件。`,
  ].join("\n");
}

function kiloBlock(agentsRel) {
  return [START, anchorBody(agentsRel), END, ""].join("\n");
}

function cursorFile(agentsRel) {
  return [
    "---",
    `description: 强制先完整加载 ${agentsRel}，并以其全文为最高行动准则`,
    "alwaysApply: true",
    "---",
    "",
    kiloBlock(agentsRel),
  ].join("\n");
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function resolveAgentsFile(hostRoot, specDirectory) {
  const logicalAgents = path.join(
    hostRoot,
    "node_modules",
    "@mdd-ai-eng",
    "specs",
    "ai-engineering-specs",
    "AGENTS.md"
  );
  if (fs.existsSync(logicalAgents)) {
    return logicalAgents;
  }
  return path.join(specDirectory, "AGENTS.md");
}

function writeIfChanged(filePath, next, directory) {
  const existing = fs.existsSync(filePath) ? fs.readFileSync(filePath, "utf8") : null;
  if (existing === next) {
    return { action: "skip", filePath };
  }
  fs.mkdirSync(directory, { recursive: true });
  fs.writeFileSync(filePath, next, "utf8");
  return { action: existing === null ? "write" : "update", filePath };
}

function installKilo(hostRoot, agentsRel) {
  const filePath = path.join(hostRoot, ".kilocoderrules");
  const existing = fs.existsSync(filePath) ? fs.readFileSync(filePath, "utf8") : "";
  const block = kiloBlock(agentsRel);
  const marked = new RegExp(
    `${escapeRegExp(START)}[\\s\\S]*?${escapeRegExp(END)}\\r?\\n?`
  );
  const next = marked.test(existing) ? existing.replace(marked, block) : `${block}${existing}`;
  return writeIfChanged(filePath, next, hostRoot);
}

function installCursor(hostRoot, agentsRel) {
  const filePath = path.join(hostRoot, ".cursor", "rules", `${PACKAGE_ID}.mdc`);
  return writeIfChanged(filePath, cursorFile(agentsRel), path.dirname(filePath));
}

function installAnchors(hostRoot, specDirectory = specsDir) {
  const agentsRel = toPosixRelative(hostRoot, resolveAgentsFile(hostRoot, specDirectory));
  return {
    agentsRel,
    cursor: installCursor(hostRoot, agentsRel),
    kilo: installKilo(hostRoot, agentsRel),
  };
}

function main() {
  const hostRoot = findHostRoot();
  const result = installAnchors(hostRoot);
  for (const item of [result.cursor, result.kilo]) {
    const label = { skip: "跳过", update: "更新", write: "写入" }[item.action];
    console.log(`[${label}] ${item.filePath}`);
  }
}

module.exports = {
  PACKAGE_ID,
  START,
  END,
  findHostRoot,
  installAnchors,
};

if (require.main === module) {
  main();
}
